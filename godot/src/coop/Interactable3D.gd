class_name Interactable3D
extends Area3D

signal interacted(hand: Hand3D)
signal action_start(hand: Hand3D)
signal action_end(hand: Hand3D)
signal pickup_changed()

var pickupable := false:
	set(v):
		pickupable = v
		pickup_changed.emit()

var interactable := true

func interact(hand: Hand3D):
	interacted.emit(hand)

func action(hand: Hand3D, pressed: bool):
	if pressed:
		action_start.emit(hand)
	else:
		action_end.emit(hand)

func reset():
	pass

func try_pickup(hand: Hand3D, type: GridItem.Type, data = {}, force := false):
	if not pickupable and not force:
		return false
		
	if hand.is_holding_item():
		print("Player is holding an item, but shouldn't be possible")
		return false

	hand.hold_item(GridItem.new(type, data), global_position)
	queue_free()
	return true
