class_name CauldronBase
extends Interactable3D

@export var cauldron_scene: PackedScene

var cauldron = null:
	set(v):
		cauldron = v
		interactable = v == null

func _ready() -> void:
	cauldron = _create_cauldron(GridItem.new(GridItem.Type.CAULDRON))

func interact(hand: Hand3D):
	if cauldron:
		print("Cauldron already on this base")
		return

	if not hand.is_holding_item():
		print("No items to put on this base")
		return
	
	if not hand.is_holding_grid_item(GridItem.Type.CAULDRON):
		print("Not holding a cauldron")
		return

	cauldron = _create_cauldron(hand.take_item())

func _create_cauldron(item: GridItem):
	var node = cauldron_scene.instantiate()
	add_child(node)

	if item.data is Dictionary:
		for prop in item.data:
			node.set(prop, item.data[prop])
	
	node.tree_exiting.connect(func(): cauldron = null)
	return node
