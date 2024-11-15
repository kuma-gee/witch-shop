extends CharacterBody3D

const POTION_EFFECT = preload("res://src/coop/potion_effect.tscn")

@export var friction := 5.
@onready var interactable_3d: Interactable3D = $Interactable3D
@onready var hit_area: Area3D = $HitArea

var gravity := 0.9
var item: PotionItem

func _ready() -> void:
	interactable_3d.interacted.connect(func(hand: Hand3D):
		hand.hold_item(item)
		queue_free()
	)
	
	hit_area.body_entered.connect(func(_b):
		print(_b)
		_on_collision()
	)

func throw_at(throw_dir: Vector3):
	velocity = throw_dir
	print("Throwing to %s" % throw_dir)

func _physics_process(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, friction * delta)
	velocity.z = move_toward(velocity.z, 0, friction * delta)
	
	if is_on_floor():
		velocity = Vector3.ZERO
	else:
		velocity.y -= gravity
	
	if move_and_slide() and is_potion():
		_on_collision()

func is_potion():
	return PotionItem.is_potion(item.type)

func _on_collision():
	if is_potion():
		var eff = POTION_EFFECT.instantiate()
		eff.type = item.type
		eff.global_position = global_position
		get_tree().current_scene.add_child(eff)
		
		queue_free()
