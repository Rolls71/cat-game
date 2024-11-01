extends TileMapLayer

const SOLID = Vector2i(2,0)
const OTHER = Vector2i(1,0)
const WEAK = Vector2i(0,0)

const UP = Vector2i(0, -1)
const DOWN = Vector2i(0, 1)

const PLAYER_RANGE = 1

@export var spawn = Vector2i(0, 0)

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
		var target_pos = local_to_map(player.position) + UP
		move_to(target_pos, player)
	elif Input.is_action_just_pressed("down"):
		var target_pos = local_to_map(player.position) + DOWN
		move_to(target_pos, player)
	elif Input.is_action_just_pressed("right_up"):
		var target_pos = Hex.axial_to_oddq(Hex.axial_add(
			Hex.oddq_to_axial(local_to_map(player.position)), 
			Hex.axial_direction(1)
			))
		move_to(target_pos, player)
	elif Input.is_action_just_pressed("right_down"):
		var target_pos = Hex.axial_to_oddq(Hex.axial_add(
			Hex.oddq_to_axial(local_to_map(player.position)), 
			Hex.axial_direction(0)
			))
		move_to(target_pos, player)
	elif Input.is_action_just_pressed("left_up"):
		var target_pos = Hex.axial_to_oddq(Hex.axial_add(
			Hex.oddq_to_axial(local_to_map(player.position)), 
			Hex.axial_direction(3)
			))
		move_to(target_pos, player)
	elif Input.is_action_just_pressed("left_down"):
		var target_pos = Hex.axial_to_oddq(Hex.axial_add(
			Hex.oddq_to_axial(local_to_map(player.position)), 
			Hex.axial_direction(4)
			))
		move_to(target_pos, player)
	

				
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
			set_cell(pos, 2, atlas, weak_count)
			player.position = map_to_local(pos)
		WEAK:
			set_cell(pos, 2, atlas, 0)
			for cell in get_used_cells():
				var cell_atlas = get_cell_atlas_coords(cell)
				if cell_atlas == SOLID:
					set_cell(cell, 2, cell_atlas, 1)
			player.position = map_to_local(spawn)
		OTHER:
			player.position = map_to_local(Vector2i(pos[0], pos[1]))
