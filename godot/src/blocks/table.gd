class_name Table
extends Interactable3D

@export var item_node: ItemNodes

var item: PotionItem:
	set(v):
		item = v
		if item == null:
			item_node.hide_all()
		else:
			item_node.show_item(item)

func _ready():
	reset()

func reset():
	item = null

func interact(hand: Hand3D):
	if pickupable:
		print("Tables cannot be picked up")
		return
	
	if item == null:
		if not hand.is_holding_item():
			print("Not holding any items to put in")
			return
		if not hand.item is PotionItem:
			print("Only potion items can be placed at the Table")
			return
		
		item = hand.take_item()
	else:
		if hand.is_holding_item():
			print("Already holding an item. Cannot prepare %s" % item.get_name())
			return
		
		hand.hold_item(item)
		item = null
