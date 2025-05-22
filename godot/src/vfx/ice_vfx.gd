extends Area3D

func _ready() -> void:
	body_entered.connect(func(b):
		if b.has_method("freeze_body"):
			b.freeze_body()
	)
