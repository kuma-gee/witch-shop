@tool
class_name ShopGridMap
extends GridMap

signal start_game()
signal setup_finished()
signal object_placed()

const TEMPLATE = [
	#[GridItem.Type.WALL, Vector3.BACK, [[Vector2i(0, 0), Vector2i(15, 0)]]],
	#[GridItem.Type.WALL, Vector3.LEFT, [[Vector2i(15, 1), Vector2i(15, 10)]]],
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
	[GridItem.Type.FLOOR_FILL, Vector3.RIGHT, [[Vector2i(-20, -20), Vector2i(20, 20)]]],
	[GridItem.Type.CUSTOMER_SPAWN, {}, Vector2i(0, -3)],
	[GridItem.Type.CAULDRON, {}, Vector2i(0, 0)],
]

const CAULDRON = preload("res://src/blocks/cauldron.tscn")
const MATERIAL_BOX = preload("res://src/blocks/material_box.tscn")
const PREP_AREA = preload("res://src/blocks/prep_area.tscn")
const TRASH = preload("res://src/blocks/trash.tscn")
const TABLE = preload("res://src/blocks/table.tscn")
const PLAYER_SPAWNER = preload("res://src/blocks/player_spawner.tscn")
const CUSTOMER_SPAWNER = preload("res://src/blocks/customer_spawner.tscn")

const ITEM_MAP := {
	GridItem.Type.CAULDRON: CAULDRON,
	GridItem.Type.MATERIAL: MATERIAL_BOX,
	GridItem.Type.PREP_AREA: PREP_AREA,
	GridItem.Type.TRASH: TRASH,
	GridItem.Type.TABLE: TABLE,
	GridItem.Type.CUSTOMER_SPAWN: CUSTOMER_SPAWNER,
	#GridItem.Type.PLAYER_SPAWN: PLAYER_SPAWNER,
	GridItem.Type.WALL: 2,
	GridItem.Type.FLOOR_FILL: 1,
}

const FLOOR_TYPES := [GridItem.Type.FLOOR_CUSTOMER, GridItem.Type.FLOOR_PLAYER, GridItem.Type.FLOOR_FILL]

@export var run := false:
	set(v):
		setup(TEMPLATE)

@export var default_layer := 1
@export var floor_layer := 0
@export var package_scene: PackedScene

@export var spawn_root: Node3D
@export var camera: Camera3D
@export var root: NavigationRegion3D
@export var ready_container: ReadyContainer

var player_spawn: PlayerSpawner
var customer_spawn: CustomerSpawner

var initial_packages = [
	[GridItem.Type.MATERIAL, {"type": PotionItem.Type.FEATHER}],
	[GridItem.Type.MATERIAL, {"type": PotionItem.Type.HERB}],
	[GridItem.Type.MATERIAL, {"type": PotionItem.Type.STARLIGHT_DUST}],
	[GridItem.Type.PREP_AREA, {"type": PotionItem.Process.CUTTING}],
	[GridItem.Type.PREP_AREA, {"type": PotionItem.Process.COMBUST}],
	[GridItem.Type.TRASH, {}],
]
var data = {}
var customer_tiles = []

func _ready() -> void:
	await get_tree().physics_frame
	setup(TEMPLATE)

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
		for pos in positions:
			if typeof(pos) == TYPE_ARRAY:
				var start = pos[0]
				var end = pos[1]

				for x in range(start.x, end.x + 1):
					for z in range(start.y, end.y + 1):
						place(Vector2i(x, z), grid_item)

			else:
				place(pos, grid_item)

	#var min_max = get_min_max_positions(get_used_cells().filter(func(x): return x.y == default_layer))
	#var min_pos = min_max[0]
	#var max_pos = min_max[1]
	#
	#var center = min_pos + (max_pos - min_pos) / 2
	#var center_pos = map_to_local(center)
	#camera.position = center_pos + Vector3.BACK * 15 + Vector3.UP * 15
	#camera.look_at(center_pos)
	
	#root.bake_navigation_mesh()
	setup_finished.emit()

func get_min_max_positions(positions: Array):
	var min_pos = null
	var max_pos = null
	for c in positions:
		if min_pos == null:
			min_pos = c
		
		if max_pos == null:
			max_pos = c
		
		min_pos.x = min(c.x, min_pos.x)
		min_pos.z = min(c.z, min_pos.z)
		max_pos.x = max(c.x, max_pos.x)
		max_pos.z = max(c.z, max_pos.z)
	
	return [min_pos, max_pos]

func get_random_customer_tile(exclude := []):
	var available = customer_tiles.filter(func(x): return not x in exclude)
	return available[randi() % available.size()]

func place(pos: Vector2i, item: GridItem) -> bool:
	var layer = floor_layer if item.type in FLOOR_TYPES else default_layer
	var v = _get_coord(pos, layer)
	
	if item.type == GridItem.Type.FLOOR_CUSTOMER:
		customer_tiles.append(v)
	
	if v in data:
		print("Already an object at %s" % v)
		return false
	
	if get_cell_item(v) != INVALID_CELL_ITEM:
		print("Already a tile at %s" % v)
		return false
		
	#if item.type == GridItem.Type.PLAYER_SPAWN:
		#var node = _create_node(v, PLAYER_SPAWNER)
		#node.grid = self
		#player_spawn = node
		#return true
		#
	#if item.type == GridItem.Type.CUSTOMER_SPAWN:
		#var node = _create_node(v, CUSTOMER_SPAWNER)
		#node.grid = self
		#customer_spawn = node
		#return true
		
	var item_obj = ITEM_MAP[item.type]
	
	if typeof(item_obj) == TYPE_INT:
		var dir = Basis.looking_at(item.data).rotated(Vector3.UP, PI / 2) if not item.data is Dictionary else Basis.IDENTITY
		set_cell_item(v, item_obj, get_orthogonal_index_from_basis(dir))
		return true
	
	var node = _create_node(v, item_obj)
	data[v] = node
	
	if item.data is Dictionary:
		for prop in item.data:
			node.set(prop, item.data[prop])

	object_placed.emit()
	return true

func _create_node(pos: Vector3i, scene: PackedScene):
	var node = scene.instantiate()
	add_child(node)
	node.global_position = map_to_local(pos) + Vector3(0, -cell_size.y, 0)
	node.owner = owner
	return node

func remove(pos: Vector2i):
	var v = _get_coord(pos, default_layer)
	if not v in data:
		print("Nothing to remove at %s" % v)
		return
		
	var obj = data[v]
	remove_child(obj)
	data.erase(v)
