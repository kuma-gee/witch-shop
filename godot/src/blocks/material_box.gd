class_name Ingredient
extends Interactable3D

@export var type := PotionItem.Type.FEATHER:
	set(v):
		type = v
		_update_text()

@onready var decal: Decal = $Decal
@onready var label_3d: Label3D = $Label3D

func _ready() -> void:
	if PotionItem.is_potion(type):
		decal.modulate = PotionItem.get_color(type)
	
	_update_text()

func _update_text():
	label_3d.text = PotionItem.Type.keys()[type]

func interact(hand: Hand3D):
	if pickupable:
		hand.hold_item(GridItem.new(GridItem.Type.MATERIAL, {"type": type}), global_position)
		queue_free()
		return
	
	var item = PotionItem.Type.keys()[type]
	if hand.is_holding_item():
		print("Already holding an item. Cannot pickup %s" % item)
		return false
	
	hand.hold_item(PotionItem.new(type))
	print("Taking Item %s" % item)
	return true
