class_name PotionItem

const ITEM_FEATHER = preload("res://assets/sprites/Item_Feather.png")
const ITEM_HERB = preload("res://assets/sprites/Item_Herb.png")
const ITEM_STARLIGHT_DUST = preload("res://assets/sprites/Item_StarlightDust.png")
const ITEM_TEARS = preload("res://assets/sprites/Item_Tears.png")

const PROCESSES = {
	Process.CUTTING: {
		Type.HERB: Type.HERB_CUTTING,
	},
	Process.DISTILL: {
		Type.TEARS: Type.TEARS_DISTILL,
	},
	Process.COMBUST: {
		Type.STARLIGHT_DUST: Type.STARLIGHT_DUST_COMBUST,
	},
}

const RECIPIES = {
	Type.POTION_RED: [Type.HERB, Type.HERB], # Heal
	Type.POTION_WHITE: [Type.FEATHER, Type.FEATHER, Type.HERB_CUTTING], # Levitation
	Type.POTION_YELLOW: [Type.STARLIGHT_DUST_COMBUST], # Explosion
	Type.POTION_BLUE: [Type.TEARS_DISTILL], # Freeze
	Type.POTION_GREEN: [Type.HERB_CUTTING, Type.HERB_CUTTING, Type.FEATHER], # Goo
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
	Type.POTION_YELLOW: Color.YELLOW,
	Type.POTION_WHITE: Color.WHITE,
}

enum Process {
	NONE,
	CUTTING,
	DISTILL,
	COMBUST,
}

enum Type {
	FEATHER,
	HERB,
	HERB_CUTTING,
	TEARS,
	TEARS_DISTILL,
	STARLIGHT_DUST,
	STARLIGHT_DUST_COMBUST,
	
	POTION_RED, # Explosion - Destroy
	POTION_BLUE, # Freeze - Fire Trap
	POTION_GREEN, # Goo - Tornado
	POTION_YELLOW, # Explosion
	POTION_PURPLE, # Invisibility?
	POTION_WHITE, # Levitation - Trapdoor
}

const TEXTURE_MAP = {
	Type.FEATHER: ITEM_FEATHER,
	Type.HERB: ITEM_HERB,
	Type.TEARS: ITEM_TEARS,
	Type.STARLIGHT_DUST: ITEM_STARLIGHT_DUST,
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
	if process in PROCESSES and type in PROCESSES[process]:
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
	
	items.sort_custom(func(a, b): return a.type < b.type)
	var sorted_types = types.duplicate()
	sorted_types.sort_custom(func(a, b): return a < b)
	
	for i in items.size():
		if not items[i].type == sorted_types[i]:
			return false
	return true

static func is_potion(type: Type):
	return type >= Type.POTION_RED

static func get_color(type: Type):
	return COLOR[type] if type in COLOR else Color.WHITE

static func get_texture(type: Type):
	return TEXTURE_MAP[type] if type in TEXTURE_MAP else null
