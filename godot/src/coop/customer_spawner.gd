class_name CustomerSpawner
extends Interactable3D

signal order_failed()
signal order_success(type: PotionItem)

@onready var order: Sprite3D = $Order
@onready var order_timer: Timer = $OrderTimer
@onready var chargeable: Chargeable = $Chargeable

var last_hand

var current_order:
	set(v):
		current_order = v
		order.visible = v != null
		if v:
			order.modulate = PotionItem.get_color(v)

func _ready() -> void:
	current_order = null
	chargeable.charged.connect(func():
		if current_order == null and not pickupable:
			new_customer_order()
	)
	order_timer.timeout.connect(func(): failed_order())
	pickup_changed.connect(func(): current_order = null)

func interact(hand: Hand3D):
	if pickupable:
		try_pickup(hand, GridItem.Type.CUSTOMER_SPAWN)
		return
		
	if hand.is_holding_item() and hand.item is PotionItem and hand.item.type == current_order:
		finished_order(hand.take_item())

func action(hand: Hand3D, pressed: bool):
	if pickupable:
		print("In pickup mode")
		return
	
	if last_hand != null and hand != last_hand:
		print("Someone else is working on it")
		return
	
	if pressed:
		if last_hand == null and not chargeable.is_charging and current_order == null:
			chargeable.start()
			last_hand = hand
	else:
		if last_hand == hand:
			chargeable.stop()
			last_hand = null

func new_customer_order():
	if current_order != null:
		print("An active order exists")
		return
	
	current_order = GameManager.get_menu().pick_random()
	order_timer.start()

func failed_order():
	if current_order == null:
		print("No order to fail")
		return
	
	current_order = null
	order_failed.emit()

func finished_order(item: PotionItem):
	current_order = null
	GameManager.finished_order(item)
	order_success.emit(item)

func reset():
	current_order = null
	last_hand = null
