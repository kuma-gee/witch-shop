class_name PrepArea3D
extends Interactable3D

const AUTOMATIC_PROCESS = [PotionItem.Process.COMBUST, PotionItem.Process.DISTILL]

@export var type_label: Label3D
@export var type := PotionItem.Process.NONE:
	set(v):
		type = v
		if type_label:
			type_label.text = PotionItem.get_process_name(v)
			type_label.visible = v != PotionItem.Process.NONE

@export var default_process_time := 1.0
@export var item_node: ItemNodes
@export var icon: ActionIcon
@export var label_3d: Label3D

@onready var type_nodes := {
	PotionItem.Process.NONE: $None,
	PotionItem.Process.CUTTING: $Cutting,
	PotionItem.Process.COMBUST: $Combust,
}

var item: PotionItem:
	set(v):
		item = v
		if item == null:
			icon.hide()
			item_node.hide_all()
			label_3d.hide()
		else:
			icon.show()
			icon.modulate = Color.WHITE if can_prepare(item) else Color.RED
			item_node.show_item(item)
			label_3d.show()
			label_3d.text = item.get_name()

var is_preparing := false

func _ready():
	reset()

func reset():
	self.item = null
	self.type = self.type
	for t in type_nodes.keys():
		type_nodes[t].visible = t == type

func _is_automatic():
	return type in AUTOMATIC_PROCESS

func _process(delta: float) -> void:
	if can_prepare(item) and (is_preparing or _is_automatic()):
		item.processed += delta
		icon.set_fill(item.processed / default_process_time)
		
		if item.processed >= default_process_time:
			processed_item()

func processed_item():
	if item == null:
		print("No item to process")
		return
		
	if not can_prepare(item):
		print("Cannot process %s" % item.get_name())
		return

	stop_process()
	
	print("Item processed: %s" % item.get_name())
	var new_type = PotionItem.get_process_item(type, item.type)
	item = PotionItem.new(new_type)

func can_prepare(item):
	return item is PotionItem and PotionItem.get_process_item(type, item.type) != null

func interact(hand: Hand3D):
	if not GameManager.shop_open:
		try_pickup(hand, GridItem.Type.PREP_AREA, {"item": item, "type": type})
		return
	
	if item == null:
		if not hand.is_holding_item():
			print("Not holding any items to put in")
			return
		if not hand.item is PotionItem:
			print("Only potion items can be placed at the PrepArea")
			return
		
		item = hand.take_item()
	else:
		if hand.is_holding_item():
			print("Already holding an item. Cannot prepare %s" % item.get_name())
			return
		
		hand.hold_item(item)
		item = null

func action(hand: Hand3D, pressed: bool):
	if pickupable:
		print("In pickup mode")
		return
	
	if pressed and not can_prepare(item):
		print("Cannot prepare %s at this station" % [item.get_name() if item else null])
		return
	
	if pressed:
		start_process()
	else:
		stop_process()

func start_process():
	if item == null:
		print("No item to process")
		return
		
	if _is_automatic():
		print("Items are automatically processed")
		return
	
	if item.process_type < 0:
		item.process_type = type
	elif item.process_type != type:
		print("item is already processed as %s" % PotionItem.Process.keys()[item.process_type])
		return
	
	print("Start processing %s: %s" % [item.get_name(), item.processed])
	is_preparing = true

func stop_process():
	if item == null:
		print("No item to stop processing")
		return
	
	if item.process_type == null:
		print("Item has not started processing")
		return
		
	if _is_automatic():
		print("Items are automatically processed")
		return
	
	print("Stop processing %s: %s" % [item.get_name(), item.processed])
	is_preparing = false
