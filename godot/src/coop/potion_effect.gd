class_name PotionEffect
extends Area3D

@onready var life_time: Timer = $LifeTime

var type: PotionItem.Type

func _ready() -> void:
	body_entered.connect(func(b): apply_effect_to_body(b))
	life_time.timeout.connect(func(): queue_free())

func apply_effect_to_body(body):
	match type:
		PotionItem.Type.POTION_BLUE: body.freeze()
		PotionItem.Type.POTION_RED: body.explode(global_position)
		PotionItem.Type.POTION_GREEN: body.freeze()
