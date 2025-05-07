class_name CustomerSpawner
extends Node3D

signal order_failed()
signal order_success()

@onready var interactable_3d: Interactable3D = $Interactable3D
@onready var order: Sprite3D = $Order
@onready var order_timer: Timer = $OrderTimer
@onready var chargeable: Chargeable = $Chargeable

var is_started := false
var menu := [PotionItem.Type.POTION_RED]
var last_hand

var current_order:
	set(v):
		current_order = v
		order.visible = v != null
		if v:
			order.modulate = PotionItem.get_color(v)

func _ready() -> void:
	current_order = null
	interactable_3d.action_start.connect(func(hand):
		if last_hand == null and not chargeable.is_charging and is_started and current_order == null:
			chargeable.start()
			last_hand = hand
	)
	interactable_3d.action_end.connect(func(hand):
		if last_hand == hand:
			chargeable.stop()
			last_hand = null
	)
	interactable_3d.interacted.connect(func(hand: Hand3D):
		if hand.is_holding_item() and hand.item == current_order:
			finished_order()
	)
	chargeable.charged.connect(func():
		if current_order == null and is_started:
			new_customer_order()
	)
	order_timer.timeout.connect(func(): failed_order())

	
func new_customer_order():
	if current_order != null:
		print("An active order exists")
		return
	
	current_order = menu.pick_random()
	order_timer.start()

func failed_order():
	if current_order == null:
		print("No order to fail")
		return
	
	current_order = null
	order_failed.emit()

func finished_order():
	current_order = null
	order_success.emit()

func start():
	is_started = true
func stop():
	is_started = false
	current_order = null
