class_name PreviewBlock
extends Node3D

@export var body: Node3D
@onready var grid: ShopGridMap = get_tree().get_first_node_in_group("grid")

func update_position(pos: Vector3):
	if visible:
		var player_pos = get_grid_position(pos)
		global_position = grid.map_to_local(Vector3i(player_pos.x, grid.floor_layer, player_pos.z))

func get_grid_position(pos: Vector3) -> Vector3i:
	var face_dir = _get_face_dir() * grid.cell_size
	return grid.local_to_map(pos + face_dir)

func _get_face_dir():
	var quat = body.basis.get_euler() as Vector3
	return Vector3.FORWARD.rotated(Vector3.UP, quat.y)
