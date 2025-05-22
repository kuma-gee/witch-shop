class_name Hand3D extends Area3D

signal picked_up_at(pos: Vector3)
signal item_changed()

@export var label: Label3D

var item:
	set(v):
		if item == v: return
		item = v
		item_changed.emit()
	
		if item and item.has_method("get_name"):
			label.text = item.get_name()
		else:
			label.text = ""

func interact():
	var interactable = get_interactable()
	if interactable:
		print(interactable)
		interactable.interact(self)
		return true
		
	return false

func action(pressed: bool):
	var interactable = get_interactable()
	if interactable:
		interactable.action(self, pressed)
		return interactable
		
	return null
	
func get_interactable() -> Interactable3D:
	for area in get_overlapping_areas():
		if area is Interactable3D:
			return area
	return null

func hold_item(i, pos = null):
	if item: return
	
	item = i
	if i is GridItem and pos != null:
		picked_up_at.emit(pos)
	
	print("Holding item %s" % i.get_name())

func is_holding_item():
	return item != null

func take_item():
	var x = item
	item = null
	return x
