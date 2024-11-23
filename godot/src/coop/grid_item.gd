class_name GridItem

enum Type {
	CAULDRON,
	MATERIAL,
	TRASH,
	PREP_AREA,
	TABLE,
	WALL,
	
	FLOOR_CUSTOMER,
	FLOOR_PLAYER,
	FLOOR_FILL,
	
	PLAYER_SPAWN,
	CUSTOMER_SPAWN,
}

var type: Type = -1
var data = {}

func _init(t: Type, d = {}) -> void:
	type = t
	data = d

func get_name():
	return Type.keys()[type]
