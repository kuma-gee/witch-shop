class_name HitBox
extends Area3D

@export var damage := 10
@export var enabled := false

func _ready() -> void:
	area_entered.connect(func(): hit())

func hit():
	if not enabled: return
	
	for b in get_overlapping_areas():
		var hurt_box = b as HurtBox
		if hurt_box:
			hurt_box.damage(damage)

func enable_hitbox():
	enabled = true
	hit()

func disable_hitbox():
	enabled = false
