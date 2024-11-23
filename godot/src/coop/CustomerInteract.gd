class_name CustomerInteract
extends Interactable3D

signal order_started(order)
signal order_received()

@export var enabled := false
@onready var order_chargeable: Chargeable = $"../OrderChargeable"

var current_order: PotionItem.Type = -1

func _ready() -> void:
	order_chargeable.charged.connect(func():
		current_order = GameManager.menu.pick_random()
		order_started.emit(current_order)
	)

func interact(hand: Hand3D):
	if current_order < 0:
		print("Customer has not ordered yet")
		return
	
	if not hand.is_holding_item():
		print("Not holding any items to give customer")
		return

	if hand.item.type != current_order:
		print("Wrong order")
		return
	
	var item = hand.take_item()
	GameManager.money += item.get_price()
	order_received.emit()

func action(hand: Hand3D, pressed: bool):
	if not enabled: return
	
	if current_order < 0:
		if pressed:
			order_chargeable.start()
		else:
			order_chargeable.stop()
		return
