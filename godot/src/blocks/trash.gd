class_name Trash
extends Interactable3D

func interact(hand: Hand3D):
	if pickupable:
		try_pickup(hand, GridItem.Type.TRASH)
		return
	
	if not hand.is_holding_item():
		print("Not holding any items to throw away")
		return
	
	if not hand.item is PotionItem:
		if hand.item is GridItem and hand.item.type == GridItem.Type.CAULDRON:
			hand.item.data.items = []
			print("Cleared cauldron")
		else:
			print("Can only throw away potion items or clear cauldrons")
		return
	
	print("Throwing away %s" % hand.item.get_name())
	hand.take_item()
