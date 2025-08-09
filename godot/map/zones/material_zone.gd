class_name MaterialZone
extends Zone

@export var ingredients: Array[Ingredient] = []

func has_all_ingredients(list: Array) -> bool:
	for item in list:
		if find_ingredient(item) == null:
			return false
	return not list.is_empty()

func find_ingredient(type: PotionItem.Type) -> Ingredient:
	for ingredient in ingredients:
		if is_instance_valid(ingredient) and ingredient.type == type:
			return ingredient
	return null

func set_ingredients(list: Array):
	for i in ingredients.size():
		var node = ingredients[i]
		if not is_instance_valid(node): continue
		
		var item = list[i] if i < list.size() else null

		if item != null:
			node.type = item
		else:
			node.queue_free()
