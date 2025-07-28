class_name Shelf
extends Interactable3D

@export var container: Node3D
@onready var max_items := container.get_child_count()

var items: Array[PotionItem] = []

func _ready() -> void:
	update()

func add_item(i: PotionItem):
	if items.size() >= max_items: return
	
	items.append(i)
	update()

func remove_item():
	if items.is_empty(): return null
	var item = items.pop_back()
	update()
	return item

func update():
	for i in container.get_child_count():
		var node = container.get_child(i) as ItemNodes
		if items.size() <= i:
			node.hide_all()
			continue
		
		node.show_item(items[i])

func has_space():
	return items.size() < max_items

func interact(hand: Hand3D):
	if not is_visible_in_tree(): return
	
	if hand.is_holding_item():
		if has_space() and PotionItem.is_potion(hand.item.type):
			add_item(hand.take_item())
	else:
		var item = remove_item()
		hand.hold_item(item)
