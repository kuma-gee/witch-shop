extends Node

signal logged(txt)
signal money_changed(m)

var items: Array[ShopItem.Item] = []
var menu := [PotionItem.Type.POTION_RED]
var money := 0:
	set(v):
		money = v
		money_changed.emit(v)

func _ready() -> void:
	money = 0

func buy_item(item: ShopItem.Item, price: int):
	if money < price: return false
	
	print("Bought item %s" % ShopItem.Item.keys()[item])
	money -= price
	items.append(item)
	return true
