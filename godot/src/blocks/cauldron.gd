class_name Cauldron
extends Interactable3D

@export var chargeable: Chargeable
@export var icon: ActionIcon
@export var ingredients: Sprite3D
@export var label: Label
@export var label_3d: Label3D

@onready var smoke: GPUParticles3D = $Smoke
@onready var explosion_area: Area3D = $ExplosionArea

var items := []:
	set(v):
		items = v
		_update_ingredients()
var last_hand: Hand3D

func _ready():
	reset()
	
	chargeable.charged.connect(func():
		var potion = PotionItem.find_recipe(items)
		items.clear()
		_update_ingredients()
		
		if not potion:
			print("Failed to mix potion")
			smoke.emitting = true
			for body in explosion_area.get_overlapping_bodies():
				body.explode(global_position, 50)
			return
		
		if PotionItem.is_potion(potion) and last_hand != null:
			last_hand.hold_item(PotionItem.new(potion))
			return
		
		items.append(PotionItem.new(potion))
		_update_ingredients()
	)
	chargeable.charging_started.connect(func(): icon.show())
	chargeable.charging_stopped.connect(func(): icon.hide())

func interact(hand: Hand3D):
	if pickupable:
		try_pickup(hand, GridItem.Type.CAULDRON, {"items": items})
		return
	
	if is_someone_else_working(hand):
		print("Someone is already working on it")
		return
	
	if not hand.is_holding_item():
		try_pickup(hand, GridItem.Type.CAULDRON, {"items": items})
		return
	
	items.append(hand.take_item())
	_update_ingredients()

func _update_ingredients():
	label.text = "%sx" % items.size()
	label_3d.text = ", ".join(items.map(func(x): return x.get_name()))

func is_someone_else_working(hand: Hand3D):
	return last_hand != null and last_hand != hand

func action(hand: Hand3D, pressed: bool):
	if pickupable:
		print("In pickup mode")
		return
	
	if is_someone_else_working(hand):
		print("Someone is already working on it")
		return
	
	if items.is_empty():
		print("No items in cauldron")
		return
	
	if hand.is_holding_item():
		print("Cannot mix cauldron with items on the hand")
		return
	
	if pressed:
		last_hand = hand
		chargeable.start()
	else:
		chargeable.stop()
		last_hand = null

func reset():
	items = []
	icon.hide()
	ingredients.hide()
