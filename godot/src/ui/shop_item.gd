class_name ShopItem
extends TextureButton

signal bought()

enum Item {
	ROBE,
	BROOMSTICK,
	WAND,
}

const PRICES = {
	Item.ROBE: 50,
	Item.WAND: 30,
	Item.BROOMSTICK: 40,
}

@export var item_type := Item.ROBE
@onready var price: int = PRICES[item_type]

@export var label: Label

func _ready() -> void:
	label.text = Item.keys()[item_type]
	pressed.connect(func():
		if GameManager.buy_item(item_type, price):
			bought.emit()
	)
