class_name CustomerSpawner
extends Interactable3D

signal order_failed()
signal order_success(type: PotionItem)

@export var min_time := 10.0
@export var max_time := 100.0
@export var max_orders := 8.0
@export var order_container: Control
@export var order_scene: PackedScene
@onready var order_timer: Timer = $OrderTimer

#@onready var new_order_timer: RandomTimer = $NewOrderTimer
# @onready var chargeable: Chargeable = $Chargeable
# @onready var action_icon: ActionIcon = $ActionIcon

var current_orders := []

# var last_hand
# var new_order_arrived := false:
# 	set(v):
# 		new_order_arrived = v
# 		action_icon.hide_on_stopped = not v

func _ready() -> void:
	# new_order_arrived = false
	# chargeable.charged.connect(func(): new_customer_order())
	# new_order_timer.timeout.connect(func(): new_order_arrived = true)
	order_timer.timeout.connect(func(): new_customer_order())

	GameManager.shop_state_changed.connect(func():
		if GameManager.shop_open:
			order_timer.start()
		else:
			order_timer.stop()
	)

func interact(hand: Hand3D):
	if pickupable:
		try_pickup(hand, GridItem.Type.CUSTOMER_SPAWN)
		return
	
	if hand.is_holding_item() and hand.item is PotionItem:
		finished_order(hand)

func action(hand: Hand3D, pressed: bool):
	return

	# if pickupable:
	# 	print("In pickup mode")
	# 	return
	
	# if last_hand != null and hand != last_hand:
	# 	print("Someone else is working on it")
	# 	return
	
	# if pressed:
	# 	if last_hand == null and not chargeable.is_charging and new_order_arrived:
	# 		chargeable.start()
	# 		last_hand = hand
	# else:
	# 	if last_hand == hand:
	# 		chargeable.stop()
	# 		last_hand = null

func new_customer_order():
	# if not new_order_arrived: return
	
	var order_node = order_scene.instantiate()
	order_node.order = GameManager.get_menu().pick_random()
	order_node.failed.connect(func():
		remove_order(order_node)
		order_failed.emit()
	)
	order_container.add_child(order_node)
	
	current_orders.append(order_node)
	# new_order_arrived = false

	var order_count = current_orders.size()
	var order_time = min_time + (max_time - min_time) * (order_count / max_orders)
	order_timer.start(order_time)

func finished_order(hand: Hand3D):
	var order = _find_matching_order(hand.item)
	if order:
		order_success.emit(hand.take_item())
		remove_order(order)

func remove_order(order: Order):
	order.queue_free()
	current_orders.erase(order)

func _find_matching_order(item: PotionItem):
	for order in current_orders:
		if order.order == item.type:
			return order

func has_order():
	return not current_orders.is_empty()

func reset():
	current_orders = []
	#last_hand = null
