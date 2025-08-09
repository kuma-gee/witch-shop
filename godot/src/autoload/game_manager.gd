extends Node

signal logged(txt)
signal money_changed(m)

var bought_items: Array[ShopItem.Item] = []

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

var current_menu := 1
var shop_open := false

func _ready() -> void:
	money = 0

func buy_item(item: ShopItem.Item, price: int):
	if money < price: return false
	
	print("Bought item %ss" % ShopItem.Item.keys()[item])
	money -= price
	bought_items.append(item)
	return true

func finished_order(potion: PotionItem):
	money += potion.get_price()

func get_menu():
	return potions.slice(0, current_menu)

func increase_menu():
	current_menu += 1

func get_current_needed_ingredients():
	var items = []
	var processes = []

	for potion in get_menu():
		var ingredients = PotionItem.RECIPIES[potion]
		for i in ingredients:
			var base_name = _get_base_ingredient_name(i)
			var base_type = PotionItem.Type[base_name[0]]

			if not base_type in items:
				items.append(base_type)

			var process = base_name[1]
			if process and not process in processes:
				processes.append(process)

	return [items, processes]
			
func _get_base_ingredient_name(item: PotionItem.Type):
	var processes = PotionItem.Process.keys()
	var n = PotionItem.Type.keys()[item]
	for p in processes:
		if n.ends_with(p):
			n = n.substr(0, n.length() - p.length())
			if n.ends_with("_"):
				n = n.substr(0, n.length() - 1)

			return [n, PotionItem.Process[p]]
	
	return [n, null]
