class_name PotionEffect
extends Area3D

const EXPLOSION_VFX = preload("res://src/vfx/explosion_vfx.tscn")

@onready var life_time: Timer = $LifeTime

var type: PotionItem.Type

func _ready() -> void:
	body_entered.connect(func(b): apply_effect_to_body(b))
	life_time.timeout.connect(func(): queue_free())
	
	var node = EXPLOSION_VFX.instantiate()
	node.global_position = global_position
	get_tree().current_scene.add_child(node)

func apply_effect_to_body(body):
	match type:
		PotionItem.Type.POTION_BLUE: body.freeze()
		PotionItem.Type.POTION_RED: body.explode(global_position)
		PotionItem.Type.POTION_GREEN: body.freeze()
