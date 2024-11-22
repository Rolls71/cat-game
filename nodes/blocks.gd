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
	for cell in get_used_cells():
		var atlas = get_cell_atlas_coords(cell)
		if atlas != OTHER:
			set_cell(cell, 2, atlas, 1)

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
	
	
			
