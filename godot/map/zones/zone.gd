class_name Zone
extends Node3D

const GROUP = "Zone"

@export var traps: Array[Trap] = []
@export var grid_size := Vector2i(2, 2)
@onready var grid: Grid = $Grid

var tw: Tween
var coord: Vector2i

func _ready() -> void:
	add_to_group(GROUP)

func set_open_directions(dirs: Array):
	grid.set_open_directions(dirs)

func move_to(pos: Vector3, delete = false, time = 2.0):
	if tw and tw.is_running(): return
	
	tw = create_tween()
	tw.tween_property(self, "position", pos, time)
	
	if delete:
		tw.finished.connect(func(): queue_free())
	
	return tw

func is_moving():
	return tw and tw.is_running()

func get_spawn_point():
	return grid.spawn_point.global_position
