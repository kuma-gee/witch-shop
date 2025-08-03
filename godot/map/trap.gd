class_name Trap
extends Node3D

signal finished()

@export var anim_name := "start"
@export var connected_trap: Trap
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.animation_finished.connect(func(anim):
		if anim == anim_name:
			finished.emit()
	)

func start():
	animation_player.play(anim_name)
	if connected_trap:
		connected_trap.start()
