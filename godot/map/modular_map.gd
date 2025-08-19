class_name ModularMap
extends GridMap

const CAULDRON_ZONE = preload("res://map/zones/cauldron_zone.tscn")
const MATERIAL_ZONE = preload("res://map/zones/material_zone.tscn")
const ORDER_ZONE = preload("res://map/zones/order_zone.tscn")
const WORK_ZONE = preload("res://map/zones/work_zone.tscn")

const DIRECTIONS = [
	Vector2i.UP,
	Vector2i.RIGHT,
	Vector2i.DOWN,
	Vector2i.LEFT,
]

@export var traps: Array[Trap] = []

var zones = {}

var material_zone = null
var work_zone = null

func setup(ingredients, processes):
	if material_zone != null: return
	
	work_zone = add_zone(WORK_ZONE, Vector2i(-1, 0)) as WorkZone
	work_zone.set_processes(processes)
	
	material_zone = add_zone(MATERIAL_ZONE, Vector2i(0, 0)) as MaterialZone
	material_zone.set_ingredients(ingredients)
	
	add_zone(ORDER_ZONE, Vector2i(-1, -1))
	add_zone(CAULDRON_ZONE, Vector2i(0, -1))

func add_zone(scene: PackedScene, coord: Vector2i) -> Zone:
	var final_pos = map_to_local(Vector3i(coord.x, 0, coord.y))

	if coord in zones:
		var offset = map_to_local(Vector3.DOWN * 5)
		var new_node = scene.instantiate()
		new_node.position = final_pos - offset
		new_node.coord = coord
		add_child(new_node)
		new_node.move_to(final_pos)

		var existing_zone = zones[coord]
		existing_zone.move_to(existing_zone.position + offset, true)

		zones[coord] = new_node
		return new_node

	var node = scene.instantiate()
	node.position = final_pos
	node.coord = coord
	add_child(node)
	zones[coord] = node
	return node

func update_directions():
	for coord in zones:
		var open = []
		for dir in DIRECTIONS:
			if (coord + dir) in zones:
				open.append(Vector2(dir))
		
		zones[coord].set_open_directions(open)

func get_max_coord():
	var max_coord = Vector2i(0, 0)
	for coord in zones.keys():
		max_coord.x = max(max_coord.x, coord.x)
		max_coord.y = max(max_coord.y, coord.y)

	return max_coord

func get_all_obstacles():
	var result = []
	for x in zones.values():
		var zone = x as Zone
		result.append_array(zone.traps)
	
	result.append_array(traps)
	return result
