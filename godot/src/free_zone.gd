extends Area3D

func _ready() -> void:
	body_entered.connect(func(b): b.queue_free())
