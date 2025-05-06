extends RigidBody3D

@export var grid_item := GridItem.Type.CAULDRON
@export var data: Dictionary = {}
@onready var interactable_3d: Interactable3D = $Interactable3D

func _ready() -> void:
	interactable_3d.interacted.connect(func(hand: Hand3D):
		hand.hold_item(GridItem.new(grid_item, data))
		queue_free()
	)
