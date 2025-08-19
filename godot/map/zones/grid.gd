class_name Grid
extends Node3D

@onready var wall_top: Node3D = $WallTop
@onready var wall_right: Node3D = $WallRight
@onready var wall_bot: Node3D = $WallBot
@onready var wall_left: Node3D = $WallLeft
@onready var spawn_point: Marker3D = $SpawnPoint

@onready var direction_map := {
	Vector2.UP: wall_top,
	Vector2.RIGHT: wall_right,
	Vector2.LEFT: wall_left,
	Vector2.DOWN: wall_bot,
}

func _ready() -> void:
	for v in direction_map.values():
		if not v.visible:
			v.queue_free()

func set_open_directions(dirs: Array):
	for dir in dirs:
		var actual_dir = dir.rotated(global_rotation.y)
		var wall = direction_map[actual_dir]
		if not is_instance_valid(wall): continue
		wall.queue_free()
	
	if not Vector2.DOWN in dirs:
		direction_map[Vector2.DOWN.rotated(global_rotation.y)].hide()
