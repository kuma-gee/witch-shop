class_name Interactable3D
extends Area3D

signal interacted(hand: Hand3D)

var pickupable := false
var interactable := true

func interact(hand: Hand3D):
	interacted.emit(hand)

func action(hand: Hand3D, pressed: bool):
	pass

func reset():
	pass

func try_pickup(hand: Hand3D, type: GridItem.Type, data = {}):
	if not pickupable:
		return false
		
	if hand.is_holding_item():
		print("Player is holding an item, but shouldn't be possible")
		return false

	hand.hold_item(GridItem.new(type, data), global_position)
	queue_free()
	return true
