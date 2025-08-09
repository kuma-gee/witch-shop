class_name Grid
extends Node3D

enum Direction {
	NORTH,
	EAST,
	WEST,
	SOUTH,
}

@onready var wall_top: Node3D = $WallTop
@onready var wall_right: Node3D = $WallRight
@onready var wall_bot: Node3D = $WallBot
@onready var wall_left: Node3D = $WallLeft
@onready var spawn_point: Marker3D = $SpawnPoint

@onready var direction_map := {
	Direction.NORTH: wall_top,
	Direction.EAST: wall_right,
	Direction.WEST: wall_left,
	Direction.SOUTH: wall_bot,
}

func set_open_directions(dirs: Array):
	for dir in dirs:
		var wall = direction_map[dir]
		if not is_instance_valid(wall): continue
		direction_map[dir].queue_free()
	
	if not Direction.SOUTH in dirs:
		direction_map[Direction.SOUTH].hide()
