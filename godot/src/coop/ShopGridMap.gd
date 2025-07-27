class_name ShopGridMap
extends GridMap

signal start_game()
signal setup_finished()
signal object_placed()

const TEMPLATE = [
	#[GridItem.Type.WALL, Vector3.RIGHT, [
		#Vector2i(0, 1),
		#[Vector2i(0, 4), Vector2i(0, 10)],
	#]],
	#[GridItem.Type.WALL, Vector3.FORWARD, [[Vector2i(0, 11), Vector2i(15, 11)]]],
#
	#[GridItem.Type.TABLE, Vector3.BACK, [
		#[Vector2i(6, 1), Vector2i(6, 7)],
		#Vector2i(6, 9),
		#Vector2i(6, 10),
	#]],
	[GridItem.Type.FLOOR_FILL, 0.0, [[Vector2i(-20, -20), Vector2i(20, 20)]]],
	[GridItem.Type.FLOOR_MAIN, 0.0, [[Vector2i(-7, -6), Vector2i(7, 4)]]],
	
	#[GridItem.Type.WALL, -PI/2, [[Vector2i(-7, -7), Vector2i(7, -7)]]], # Back
	#[GridItem.Type.WALL, PI, [[Vector2i(8, -6), Vector2i(8, 4)]]], # Right
	#[GridItem.Type.WALL, 0.0, [[Vector2i(-8, -6), Vector2i(-8, 4)]]], # Left
	#
	#[GridItem.Type.WALL, PI/2, [[Vector2i(-7, 5), Vector2i(-2, 5)]]], # Front
	#[GridItem.Type.WALL, PI/2, [[Vector2i(1, 5), Vector2i(7, 5)]]], # Front
	#[GridItem.Type.DOOR, PI/2, Vector2i(-1, 5)], # Front
	#
	#[GridItem.Type.CORNER, 0.0, Vector2i(-8, -7)],
	#[GridItem.Type.CORNER, -PI/2, Vector2i(8, -7)],
	#[GridItem.Type.CORNER, PI/2, Vector2i(-8, 5)],
	#[GridItem.Type.CORNER, PI, Vector2i(8, 5)],
	#
	#[GridItem.Type.CUSTOMER_SPAWN, {}, Vector2i(0, -6)],
	[GridItem.Type.CAULDRON, {}, Vector2i(0, -2)],
	
	[GridItem.Type.MATERIAL, {"type": PotionItem.Type.FEATHER}, Vector2i(2, -6)],
	[GridItem.Type.MATERIAL, {"type": PotionItem.Type.HERB}, Vector2i(3, -6)],
	[GridItem.Type.MATERIAL, {"type": PotionItem.Type.STARLIGHT_DUST}, Vector2i(4, -6)],
	[GridItem.Type.MATERIAL, {"type": PotionItem.Type.TEARS}, Vector2i(5, -6)],
	[GridItem.Type.PREP_AREA, {"type": PotionItem.Process.CUTTING}, Vector2i(-1, -6)],
	[GridItem.Type.PREP_AREA, {"type": PotionItem.Process.COMBUST}, Vector2i(-2, -6)],
	[GridItem.Type.TRASH, {}, Vector2i(-4, -6)],
]

const CAULDRON = preload("res://src/blocks/cauldron.tscn")
const MATERIAL_BOX = preload("res://src/blocks/material_box.tscn")
const PREP_AREA = preload("res://src/blocks/prep_area.tscn")
const TRASH = preload("res://src/blocks/trash.tscn")
const TABLE = preload("res://src/blocks/table.tscn")
const PLAYER_SPAWNER = preload("res://src/blocks/player_spawner.tscn")
const CUSTOMER_SPAWNER = preload("res://src/blocks/customer_spawner.tscn")
const FLOOR_MAIN = preload("res://src/blocks/floor_main.tscn")
const FLOOR_TILE = preload("res://src/blocks/floor_tile.tscn")
const WALL = preload("res://src/blocks/wall.tscn")
const CORNER = preload("res://src/blocks/corner.tscn")
const DOOR = preload("res://src/blocks/door.tscn")

const ITEM_MAP := {
	GridItem.Type.CAULDRON: CAULDRON,
	GridItem.Type.MATERIAL: MATERIAL_BOX,
	GridItem.Type.PREP_AREA: PREP_AREA,
	GridItem.Type.TRASH: TRASH,
	GridItem.Type.TABLE: TABLE,
	GridItem.Type.CUSTOMER_SPAWN: CUSTOMER_SPAWNER,
	GridItem.Type.FLOOR_FILL: FLOOR_TILE,
	GridItem.Type.FLOOR_MAIN: FLOOR_MAIN,
	GridItem.Type.WALL: WALL,
	GridItem.Type.CORNER: CORNER,
	GridItem.Type.DOOR: DOOR,
}

const FLOOR_TYPES := [GridItem.Type.FLOOR_CUSTOMER, GridItem.Type.FLOOR_PLAYER, GridItem.Type.FLOOR_FILL, GridItem.Type.FLOOR_MAIN]

@export var run := false:
	set(v):
		setup(TEMPLATE)

@export var default_layer := 1
@export var floor_layer := 0
@export var package_scene: PackedScene
@export var ready_container: ReadyContainer

var initial_packages = []
var data = {}
var customer_tiles = []

#func _ready() -> void:
	#await get_tree().physics_frame
	#setup(TEMPLATE)

func _get_coord(pos: Vector2i, y: int):
	return Vector3i(pos.x, y, pos.y)

func spawn_initial_packages():
	var start_x = initial_packages.size() / 2.0
	for i in initial_packages.size():
		var pkg = initial_packages[i]
		var node = package_scene.instantiate()
		node.grid_item = pkg[0]
		node.data = pkg[1]
		node.position = Vector3(-start_x + i * 2, 1, 4)
		add_child(node)

func setup(data: Array):
	for c in get_children():
		c.queue_free()
	
	spawn_initial_packages()
	
	self.data = {}
	for pos in get_used_cells():
		if pos.y == default_layer:
			set_cell_item(pos, -1)
	
	for line in data:
		var item_data = line[1]
		var positions = line[2]
		if typeof(positions) != TYPE_ARRAY:
			positions = [positions]

		var grid_item = GridItem.new(line[0], item_data)
		if grid_item.type == GridItem.Type.WALL:
			print()
		
		for pos in positions:
			if typeof(pos) == TYPE_ARRAY:
				var start = pos[0]
				var end = pos[1]

				for x in range(start.x, end.x + 1):
					for z in range(start.y, end.y + 1):
						place(Vector2i(x, z), grid_item)

			else:
				place(pos, grid_item)

	setup_finished.emit()

func get_random_customer_tile(exclude := []):
	var available = customer_tiles.filter(func(x): return not x in exclude)
	return available[randi() % available.size()]

func place(pos: Vector2i, item: GridItem) -> bool:
	var layer = floor_layer if item.type in FLOOR_TYPES else default_layer
	var v = _get_coord(pos, layer)
	
	var replace = layer == floor_layer
	if v in data and not replace:
		print("Already an object at %s" % v)
		return false
	
	if v in data:
		remove(pos, layer)
	
	#if get_cell_item(v) != INVALID_CELL_ITEM and layer != FLOOR_TYPES:
		#print("Already a tile at %s" % v)
		#return false
	
	var item_obj = ITEM_MAP[item.type]
	var dir = item.data if item.data is float else 0 #Basis.looking_at(item.data).rotated(Vector3.UP, PI / 2) if not item.data is Dictionary else Basis.IDENTITY
	
	#if typeof(item_obj) == TYPE_INT:
		#set_cell_item(v, item_obj, get_orthogonal_index_from_basis(dir))
		#return true
	
	var node = _create_node(v, item_obj, dir)
	if node == null: return false
	
	data[v] = node
	
	if item.data is Dictionary:
		for prop in item.data:
			node.set(prop, item.data[prop])

	object_placed.emit()
	return true

func _add_to_floor(pos: Vector3i, scene: PackedScene, rot: float):
	var node = scene.instantiate()
	var floor_coord = pos + Vector3i.DOWN
	if not floor_coord in data:
		print("Floor does not exist")
		return null
	
	node.rotation.y = rot
	var floor = data[floor_coord]
	if floor == null: return null
	#if floor is not FloorMain and scene != WALL and scene != CORNER and scene != DOOR: return null
	
	floor.add_child(node)
	return node

func _create_node(pos: Vector3i, scene: PackedScene, rot: float):
	if pos.y == default_layer:
		return _add_to_floor(pos, scene, rot)
	
	var node = scene.instantiate()
	node.position = map_to_local(pos) + Vector3(0, -cell_size.y, 0)
	add_child(node)
	node.rotation.y = rot
	node.owner = owner
	return node

func remove(pos: Vector2i, layer = default_layer):
	var v = _get_coord(pos, layer)
	if not v in data:
		print("Nothing to remove at %s" % v)
		return
		
	var obj = data[v]
	obj.queue_free()
	data.erase(v)

func split_floor(start: Vector2, end: Vector2):
	var group_a := []
	var group_b := []
	
	for grid_pos in data:
		var p = Vector2(grid_pos.x, grid_pos.z)
		
		# https://stackoverflow.com/questions/1560492/how-to-tell-whether-a-point-is-to-the-right-or-left-side-of-a-line
		var side = (end.x - start.x) * (p.y - start.y) - (end.y - start.y) * (p.x - start.x)
		if side > 0:
			group_a.append(grid_pos)
		else:
			group_b.append(grid_pos)
	
	#print("Positive: %s" % [group_a])
	#print("Negative: %s" % [group_b])
	return [group_a, group_b]

func move_floor(coords: Array, offset: Vector3):
	for c in coords:
		var tile = data[c]
		if tile.has_method("move_tile"):
			tile.move_tile(offset)

func reset_floor():
	for c in data:
		var tile = data[c]
		if tile.has_method("reset_tile"):
			tile.reset_tile()
