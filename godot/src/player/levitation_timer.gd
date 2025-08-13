class_name LevitationTimer
extends Timer

@export var player: Player3D
@export var levitation_height := 2.0

func _ready() -> void:
	timeout.connect(func(): player.float_height = 0.0)

func start_levitate():
	player.float_height = levitation_height
	start()
