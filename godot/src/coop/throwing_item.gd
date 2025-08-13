class_name ThrowableItem
extends CharacterBody3D

const POTION_EFFECT = preload("res://src/coop/potion_effect.tscn")

const EXPLOSION_VFX = preload("res://src/vfx/explosion_vfx.tscn")
const ICE_VFX = preload("res://src/vfx/ice_vfx.tscn")
const LEVITATION_VFX = preload("res://magic/levitation_vfx.tscn")

const EFFECT = {
	PotionItem.Type.POTION_BLUE: ICE_VFX,
	PotionItem.Type.POTION_RED: EXPLOSION_VFX,
	PotionItem.Type.POTION_WHITE: LEVITATION_VFX,
}

@export var friction := 5.
@onready var interactable_3d: Interactable3D = $Interactable3D
@onready var hit_area: Area3D = $HitArea

var gravity := 0.9
var item: PotionItem
var collided := false

func _ready() -> void:
	interactable_3d.interacted.connect(func(hand: Hand3D): pick_up(hand))
	hit_area.body_entered.connect(func(_b):
		_on_collision()
	)

func pick_up(hand: Hand3D):
	hand.hold_item(item)
	queue_free()

func throw_at(throw_dir: Vector3):
	velocity = throw_dir

func _physics_process(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, friction * delta)
	velocity.z = move_toward(velocity.z, 0, friction * delta)
	
	if is_on_floor():
		velocity = Vector3.ZERO
	else:
		velocity.y -= gravity
	
	if move_and_slide() and is_potion() and not collided:
		collided = true
		_on_collision()

func is_potion():
	return PotionItem.is_potion(item.type)

func _on_collision():
	if not is_potion(): return
	
	if item.type in EFFECT:
		var node = EFFECT[item.type].instantiate()
		node.position = global_position
		get_tree().current_scene.call_deferred("add_child", node)
	
	queue_free()
