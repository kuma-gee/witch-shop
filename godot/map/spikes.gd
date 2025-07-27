extends Node3D

@onready var random_timer: RandomTimer = $RandomTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	random_timer.timeout.connect(func(): animation_player.play("spikes"))
	animation_player.animation_finished.connect(func(): random_timer.random_start())

func start():
	random_timer.random_start()
