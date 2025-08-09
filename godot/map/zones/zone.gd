class_name Zone
extends Node3D

const GROUP = "Zone"

@export var grid_size := Vector2i(2, 2)
@export var obstacle_timer: ObstacleTimer
@onready var grid: Grid = $Grid

var tw: Tween
var coord: Vector2i

func _ready() -> void:
	add_to_group(GROUP)

func start():
	if obstacle_timer:
		obstacle_timer.start()
	
func stop():
	if obstacle_timer:
		obstacle_timer.stop()

func set_open_directions(dirs: Array):
	grid.set_open_directions(dirs)

func move_to(pos: Vector3, delete = false):
	if tw and tw.is_running(): return
	
	tw = create_tween()
	tw.tween_property(self, "position", pos, 2.0)
	
	if delete:
		tw.finished.connect(func(): queue_free())

func is_moving():
	return tw and tw.is_running()

func get_spawn_point():
	return grid.spawn_point.global_position
