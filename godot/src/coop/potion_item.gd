class_name PotionItem

const PROCESSES = {
	Process.CUTTING: {
		Type.HERB: Type.HERB_CUTTED,
	},
	Process.DISTILL: {
		Type.TEARS: Type.TEARS_DISTILL,
	},
	Process.COMBUST: {
		Type.STARLIGHT_DUST: Type.STARLIGHT_DUST_COMBUST,
	},
}

const RECIPIES = {
	Type.POTION_RED: [Type.FEATHER, Type.HERB_CUTTED],
	Type.POTION_BLUE: [Type.STARLIGHT_DUST, Type.FEATHER, Type.FEATHER],
	Type.POTION_GREEN: [Type.HERB_CUTTED, Type.HERB_CUTTED, Type.FEATHER],
	Type.TEARS_DISTILL: [Type.TEARS, Type.STARLIGHT_DUST],
}

const PRICES = {
	Type.POTION_RED: 5,
	Type.POTION_BLUE: 8,
	Type.POTION_GREEN: 12,
	Type.POTION_YELLOW: 15,
	Type.POTION_WHITE: 20,
}

const COLOR = {
	Type.POTION_RED: Color.RED,
	Type.POTION_BLUE: Color.BLUE,
	Type.POTION_GREEN: Color.GREEN,
}

enum Process {
	CUTTING,
	DISTILL,
	COMBUST,
}

enum Type {
	FEATHER,
	HERB,
	HERB_CUTTED,
	TEARS,
	TEARS_DISTILL,
	STARLIGHT_DUST,
	STARLIGHT_DUST_COMBUST,
	
	POTION_RED, # Explosion/Fire
	POTION_BLUE, # Freeze
	POTION_GREEN, # Goo
	POTION_YELLOW, # Booze
	POTION_WHITE, # Clear?
}

var type: Type
var process_type: Process = -1
var processed := 0.0

func _init(item: Type):
	type = item

func get_name():
	return Type.keys()[type]

static func get_process_name(x: Process):
	return Process.keys()[x]

func get_price():
	if not type in PRICES: return 0
	return PRICES[type]

static func get_process_item(process: Process, type: Type):
	if type in PROCESSES[process]:
		return PROCESSES[process][type]
	return null

static func find_recipe(items: Array):
	for key in RECIPIES.keys():
		var recipe = RECIPIES[key]
		if contains_all(items, recipe):
			return key
	return null

static func contains_all(items: Array, types: Array):
	if items.size() != types.size():
		return false
	
	for x in items:
		if not x.type in types:
			return false
	return true

static func is_potion(type: Type):
	return type >= Type.POTION_RED

static func get_color(type: Type):
	return COLOR[type] if type in COLOR else Color.WHITE
