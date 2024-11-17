class_name ShopGridMap
extends GridMap

signal setup_finished()
signal object_placed()

const TEMPLATE = [
	[GridItem.Type.WALL, Vector3.BACK, [
		Vector2i(0, 0),
		Vector2i(1, 0),
		Vector2i(2, 0),
		Vector2i(3, 0),
		Vector2i(4, 0),
		Vector2i(5, 0),
		Vector2i(6, 0),
		Vector2i(7, 0),
		Vector2i(8, 0),
		Vector2i(9, 0),
		Vector2i(10, 0),
	]],
	[GridItem.Type.WALL, Vector3.LEFT, [
		Vector2i(10, 1),
		Vector2i(10, 2),
		Vector2i(10, 3),
		Vector2i(10, 4),
		Vector2i(10, 5),
		Vector2i(10, 6),
	]],
	[GridItem.Type.WALL, Vector3.RIGHT, [
		Vector2i(0, 1),
		Vector2i(0, 2),
		Vector2i(0, 3),
		Vector2i(0, 4),
		Vector2i(0, 5),
		Vector2i(0, 6),
	]],
	[GridItem.Type.WALL, Vector3.FORWARD, [
		Vector2i(0, 7),
		Vector2i(1, 7),
		Vector2i(2, 7),
		Vector2i(3, 7),
		Vector2i(4, 7),
		Vector2i(5, 7),
		Vector2i(6, 7),
		Vector2i(7, 7),
		Vector2i(8, 7),
		Vector2i(9, 7),
		Vector2i(10, 7),
	]],

	[GridItem.Type.PLAYER_SPAWN, Vector3.BACK, Vector2i(5, 5)],
	[GridItem.Type.CUSTOMER_SPAWN, Vector3.BACK, Vector2i(-5, 1)],

	[GridItem.Type.CAULDRON, Vector3.BACK, Vector2i(3, 3)],
	[GridItem.Type.MATERIAL, Vector3.RIGHT, Vector2i(2, 3)],
	[GridItem.Type.TRASH, Vector3.RIGHT, Vector2i(2, 2)],
]

const CAULDRON = preload("res://src/blocks/cauldron.tscn")
const MATERIAL_BOX = preload("res://src/blocks/material_box.tscn")
const PREP_AREA = preload("res://src/blocks/prep_area.tscn")
const TRASH = preload("res://src/blocks/trash.tscn")
const TABLE = preload("res://src/blocks/table.tscn")
const PLAYER_SPAWNER = preload("res://src/blocks/player_spawner.tscn")
const CUSTOMER_SPAWNER = preload("res://src/blocks/customer_spawner.tscn")

const ITEM_MAP = {
	GridItem.Type.CAULDRON: CAULDRON,
	GridItem.Type.MATERIAL: MATERIAL_BOX,
	GridItem.Type.PREP_AREA: PREP_AREA,
	GridItem.Type.TRASH: TRASH,
	GridItem.Type.WALL: 2,
}

@export var camera: Camera3D
@export var default_layer := 1
@export var root: NavigationRegion3D
@export var ready_container: ReadyContainer

var data = {}

func _ready() -> void:
	await get_tree().physics_frame
	setup(TEMPLATE)

func _get_coord(pos: Vector2i):
	return Vector3i(pos.x, default_layer, pos.y)

func setup(data: Array):
	for c in get_children():
		c.queue_free()
	
	for pos in get_used_cells():
		if pos.y == default_layer:
			set_cell_item(pos, -1)
	
	for line in data:
		var item_data = line[1]
		var positions = line[2]
		if typeof(positions) != TYPE_ARRAY:
			positions = [positions]
		for pos in positions:
			place(pos, GridItem.new(line[0], item_data))
	
	var cells = get_used_cells()
	var min_pos = null
	var max_pos = null
	for c in get_used_cells():
		if c.y != default_layer:
			continue
		
		if min_pos == null:
			min_pos = c
			continue
		
		if max_pos == null:
			max_pos = c
			continue
		
		min_pos.x = min(c.x, min_pos.x)
		min_pos.z = min(c.z, min_pos.z)
		max_pos.x = max(c.x, max_pos.x)
		max_pos.z = max(c.z, max_pos.z)
	
	var center = min_pos + (max_pos - min_pos) / 2
	var center_pos = map_to_local(center)
	camera.position = center_pos + Vector3.BACK * 15 + Vector3.UP * 15
	camera.look_at(center_pos)
	
	setup_finished.emit()

func place(pos: Vector2i, item: GridItem) -> bool:
	var v = _get_coord(pos)
	if v in data:
		print("Already an object at %s" % v)
		return false
	
	if get_cell_item(v) != INVALID_CELL_ITEM:
		print("Already a tile at %s" % v)
		return false
		
	if item.type == GridItem.Type.PLAYER_SPAWN:
		var node = _create_node(v, PLAYER_SPAWNER)
		node.grid = self
		return true
		
	if item.type == GridItem.Type.CUSTOMER_SPAWN:
		_create_node(v, CUSTOMER_SPAWNER)
		return true
		
	var item_obj = ITEM_MAP[item.type]
	if typeof(item_obj) == TYPE_INT:
		var dir = Basis.looking_at(item.data).rotated(Vector3.UP, PI/2)
		set_cell_item(v, item_obj, get_orthogonal_index_from_basis(dir))
		return true
	
	var node = _create_node(v, item_obj)
	data[v] = node
	
	for prop in item.data:
		node.set(prop, item.data[prop])

	object_placed.emit()
	return true

func _create_node(pos: Vector3i, scene: PackedScene):
	var node = scene.instantiate()
	root.add_child(node)
	node.global_position = map_to_local(pos) + Vector3(0, -cell_size.y, 0)
	return node

func remove(pos: Vector2i):
	var v = _get_coord(pos)
	if not v in data:
		print("Nothing to remove at %s" % v)
		return
		
	var obj = data[v]
	root.remove_child(obj)
	data.erase(v)
