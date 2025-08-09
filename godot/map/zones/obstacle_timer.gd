class_name ObstacleTimer
extends RandomTimer

@export var obstacles: Array[Trap] = []

func _ready() -> void:
	one_shot = true
	timeout.connect(func():
		var obstacle = obstacles.pick_random() as Trap
		obstacle.start()
		await obstacle.finished
		random_start()
	)
