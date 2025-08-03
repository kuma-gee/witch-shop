class_name HitBox
extends Area3D

@export var force := 0
#@export var damage := 10
@export var enabled := false

func _ready() -> void:
	body_entered.connect(func(_b): hit())

func hit():
	if not enabled: return
	
	for b in get_overlapping_bodies():
		if b is Player3D:
			b.explode(global_position, force)
	
	#for b in get_overlapping_areas():
		#var hurt_box = b as HurtBox
		#if hurt_box:
			#hurt_box.damage(damage)

func enable_hitbox():
	enabled = true
	hit()

func disable_hitbox():
	enabled = false
