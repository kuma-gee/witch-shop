class_name GridItem

enum Type {
	CAULDRON,
	MATERIAL,
	TRASH,
	PREP_AREA,
	TABLE,
	WALL,
	CORNER,
	DOOR,
	
	FLOOR_CUSTOMER,
	FLOOR_PLAYER,
	FLOOR_FILL,
	FLOOR_MAIN,
	
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
