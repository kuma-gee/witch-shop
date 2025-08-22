class_name FloorTile
extends Node3D

@onready var original_position = global_position

func move_tile(offset: Vector3, duration: float = 3.0):
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	var target = original_position + offset
	tween.tween_property(self, "global_position", target, duration)

func reset_tile():
	move_tile(Vector3.ZERO)
