extends TileMapLayer

const SOLID = Vector2i(2,0)
const OTHER = Vector2i(1,0)
const WEAK = Vector2i(0,0)

const PLAYER_RANGE = 1

const SPAWN = Vector2i(1, -1)

func _init() -> void:
	for cell in get_used_cells():
		var atlas = get_cell_atlas_coords(cell)
		if atlas != OTHER:
			set_cell(cell, 2, atlas, 1)
		

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("primary_click"):
		var mouse_pos = get_global_mouse_position()
		var pos_clicked = local_to_map(to_local(mouse_pos))
		var player: Node2D = get_node("Player")
		var a = Hex.oddq_to_axial(local_to_map(player.position))
		var b = Hex.oddq_to_axial(pos_clicked)
		if Hex.axial_distance(a, b) > PLAYER_RANGE:
			return
		var atlas = get_cell_atlas_coords(pos_clicked)
		match atlas:
			SOLID:
				var weak_count = 0
				for direction in Hex.axial_directions:
					var neighbour = (Hex.axial_to_oddq(Hex.axial_add(Hex.oddq_to_axial(pos_clicked), direction)))
					if get_cell_source_id(neighbour) != -1:
						if get_cell_atlas_coords(neighbour) == WEAK:
							weak_count += 1
				if weak_count >= 1:
					weak_count += 1
				set_cell(pos_clicked, 2, atlas, weak_count)
				player.position = map_to_local(pos_clicked)
			WEAK:
				set_cell(pos_clicked, 2, atlas, 0)
				for cell in get_used_cells():
					var cell_atlas = get_cell_atlas_coords(cell)
					if cell_atlas == SOLID:
						set_cell(cell, 2, cell_atlas, 1)
				player.position = map_to_local(SPAWN)
			OTHER:
				player.position = map_to_local(pos_clicked)
				
			
			
			
			
	#if Input.is_action_just_pressed("secondary_click"):
		#var global_clicked = event.position
		#var pos_clicked = local_to_map(to_local(global_clicked))
		#var axial_pos = Hex.oddq_to_axial(pos_clicked)
		#var neighbours = []
		#for direction in Hex.axial_directions:
			#var neighbour = (Hex.axial_to_oddq(Hex.axial_add(axial_pos, direction)))
			#var n_vec = Vector2i(neighbour[0], neighbour[1])
			#if get_cell_source_id(n_vec) != -1:
				#neighbours.append(n_vec)
		#neighbours.append(Vector2i(pos_clicked[0], pos_clicked[1]))
		#for n_vec in neighbours:
			#var atlas = get_cell_atlas_coords(n_vec)
			#if atlas.x < 2:
				#atlas.x += 1
				#set_cell(n_vec, 2, atlas)
			
		
		
