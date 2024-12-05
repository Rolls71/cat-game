extends TileMapLayer

const SOLID = Vector2i(2,0)
const OTHER = Vector2i(1,0)
const WEAK = Vector2i(0,0)

const UP = Vector2i(0, -1)
const DOWN = Vector2i(0, 1)

const PLAYER_RANGE = 1
const PLAYER_LUCK_MULTIPLIER = 0.7
const PLAYER_LUCK_INITIAL = 1

@export var spawn = Vector2i(0, 0)

var player_luck = PLAYER_LUCK_INITIAL
var is_jumping = false

func _init() -> void:
	var randomised_cells = []
	for cell in get_used_cells():
		var atlas = get_cell_atlas_coords(cell)
		if atlas != OTHER:
			set_cell(cell, 2, atlas, 1)
		elif get_cell_alternative_tile(cell) == 0:
			randomised_cells.append(cell)
	
	# Find each group of adjacent cells
	var randomised_groups = []
	var break_flag = false
	for cell in randomised_cells:
		for group in randomised_groups:
			# After appending a cell to a group, we want to skip to the next cell
			if break_flag:
				break
			for g_cell in group:
				if Hex.is_oddq_adjacent(cell, g_cell):
					group.append(cell)
					break_flag = true
					break
		if not break_flag:
			randomised_groups.append([cell])
		break_flag = false
	print(randomised_groups)
	
	# Find random fitting pattern to substitute in
	for group in randomised_groups:
		var fitting_patterns = []
		for i in range(tile_set.get_patterns_count()):
			var pattern_cells = tile_set.get_pattern(i).get_used_cells()
			if len(pattern_cells) != len(group):
				print("mismatch", group, pattern_cells)
				continue
			
			var least_cell = Vector2i.MAX
			for cell in group:
				if cell < least_cell:
					least_cell = cell
			var sort_group = []
			for cell in group:
				sort_group.append(cell - least_cell)
			sort_group.sort()
					
			var least_p_cell = Vector2i.MAX
			for p_cell in pattern_cells:
				if p_cell < least_p_cell:
					least_p_cell = p_cell
			var sort_pattern = []
			for p_cell in pattern_cells:
				sort_pattern.append(p_cell - least_p_cell)
			sort_pattern.sort()
			
			for j in range(len(sort_group)):
				if sort_group[j] != sort_pattern[j]:
					break
				if j == len(sort_group)-1:
					fitting_patterns.append(i)
		
			print(group, pattern_cells)
		if len(fitting_patterns) > 0:
			set_pattern(group[0], tile_set.get_pattern(randi() % len(fitting_patterns)))
		print("Error: No fitting patterns for", group)
		# TODO Fix pattern matching error with multiple pattern shapes
	
	# Hide new randomised cells
	for cell in randomised_cells:
		var atlas = get_cell_atlas_coords(cell)
		if atlas != OTHER:
			set_cell(cell, 2, atlas, 1)
		else:
			print("unchosen cell at", cell)
			
		
		

# TODO Move to separate script in parent node
func _input(_event: InputEvent) -> void:
	var player: Node2D = get_node("Player")
	
	if Input.is_action_just_pressed("primary_click"):
		var mouse_pos = get_global_mouse_position()
		var pos_clicked = local_to_map(to_local(mouse_pos))
		var current_pos = Hex.oddq_to_axial(local_to_map(player.position))
		var target_pos = Hex.oddq_to_axial(pos_clicked)
		if Hex.axial_distance(current_pos, target_pos) > PLAYER_RANGE:
			return
		move_to(pos_clicked, player)
	elif Input.is_action_just_pressed("up"):
		var dir_vec = UP
		if is_jumping:
			dir_vec *= 2
		var target_pos = local_to_map(player.position) + dir_vec
		move_to(target_pos, player)
	elif Input.is_action_just_pressed("down"):
		var dir_vec = DOWN
		if is_jumping:
			dir_vec *= 2
		var target_pos = local_to_map(player.position) + dir_vec
		move_to(target_pos, player)
	elif Input.is_action_just_pressed("right_up"):
		var dir_vec = Hex.axial_direction(1)
		if is_jumping:
			dir_vec = Hex.axial_add(dir_vec, dir_vec)
		var target_pos = Hex.axial_to_oddq(Hex.axial_add(
			Hex.oddq_to_axial(local_to_map(player.position)), 
			dir_vec
			))
		move_to(target_pos, player)
	elif Input.is_action_just_pressed("right_down"):
		var dir_vec = Hex.axial_direction(0)
		if is_jumping:
			dir_vec = Hex.axial_add(dir_vec, dir_vec)
		var target_pos = Hex.axial_to_oddq(Hex.axial_add(
			Hex.oddq_to_axial(local_to_map(player.position)), 
			dir_vec
			))
		move_to(target_pos, player)
	elif Input.is_action_just_pressed("left_up"):
		var dir_vec = Hex.axial_direction(3)
		if is_jumping:
			dir_vec = Hex.axial_add(dir_vec, dir_vec)
		var target_pos = Hex.axial_to_oddq(Hex.axial_add(
			Hex.oddq_to_axial(local_to_map(player.position)), 
			dir_vec
			))
		move_to(target_pos, player)
	elif Input.is_action_just_pressed("left_down"):
		var dir_vec = Hex.axial_direction(4)
		if is_jumping:
			dir_vec = Hex.axial_add(dir_vec, dir_vec)
		var target_pos = Hex.axial_to_oddq(Hex.axial_add(
			Hex.oddq_to_axial(local_to_map(player.position)), 
			dir_vec
			))
		move_to(target_pos, player)
	elif Input.is_action_just_pressed("jump"):
		is_jumping = !is_jumping
		print(is_jumping)
	

				
func move_to(pos: Vector2i, player: Node2D):
	var atlas = get_cell_atlas_coords(pos)
	if get_cell_atlas_coords(pos) == Vector2i(-1, -1):
		return
	match atlas:
		SOLID:
			var weak_count = 0
			for direction in Hex.axial_directions:
				var neighbour = (Hex.axial_to_oddq(Hex.axial_add(Hex.oddq_to_axial(pos), direction)))
				if get_cell_source_id(neighbour) != -1:
					if get_cell_atlas_coords(neighbour) == WEAK:
						weak_count += 1
			if weak_count >= 1:
				weak_count += 1
			if is_jumping && weak_count > 0:
				kill_player(player)
			else:
				set_cell(pos, 2, atlas, weak_count)
				player.position = map_to_local(pos)
		WEAK:
			set_cell(pos, 2, atlas, 0)
			push_luck(player)
		OTHER:
			player.position = map_to_local(Vector2i(pos[0], pos[1]))
			
	# Reset
	is_jumping = false
	
func push_luck(player):
	if randf() > player_luck:
		# Fail
		kill_player(player)
		return false
	else:
		# Succeed
		player_luck *= PLAYER_LUCK_MULTIPLIER
		
		# TODO add visual representation
		print("Luck: " + str(player_luck))
		return true
		
func kill_player(player):
	player_luck = PLAYER_LUCK_INITIAL
	player.position = map_to_local(spawn)
	_init()
	
	
			
