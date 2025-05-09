extends Node

signal logged(txt)
signal money_changed(m)

var items: Array[ShopItem.Item] = []

var money := 0:
	set(v):
		money = v
		money_changed.emit(v)

var potions = [
	PotionItem.Type.POTION_RED,
	PotionItem.Type.POTION_BLUE,
	PotionItem.Type.POTION_GREEN,
	PotionItem.Type.POTION_YELLOW,
	PotionItem.Type.POTION_WHITE,
]

var current_menu := 0

func _ready() -> void:
	money = 0

func buy_item(item: ShopItem.Item, price: int):
	if money < price: return false
	
	print("Bought item %s" % ShopItem.Item.keys()[item])
	money -= price
	items.append(item)
	return true

func finished_order(potion: PotionItem):
	money += potion.get_price()

func get_menu():
	return potions.slice(0, current_menu)

func increase_menu():
	current_menu += 1
