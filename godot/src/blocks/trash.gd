class_name Trash
extends Interactable3D

func interact(hand: Hand3D):
	if pickupable:
		hand.hold_item(GridItem.new(GridItem.Type.TRASH), global_position)
		queue_free()
		return
	
	if not hand.is_holding_item():
		print("Not holding any items to throw away")
		return
	
	if not hand.item is PotionItem:
		print("Can only throw away potion items")
		return
	
	print("Throwing away %s" % hand.item.get_name())
	hand.take_item()
