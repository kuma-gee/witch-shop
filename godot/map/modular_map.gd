class_name ModularMap
extends GridMap

const CAULDRON_ZONE = preload("res://map/zones/cauldron_zone.tscn")
const MATERIAL_ZONE = preload("res://map/zones/material_zone.tscn")
const ORDER_ZONE = preload("res://map/zones/order_zone.tscn")
const WORK_ZONE = preload("res://map/zones/work_zone.tscn")

var zones = {}

func setup():
	_add_zone(ORDER_ZONE, Vector2i(0, 0))
	_add_zone(MATERIAL_ZONE, Vector2i(1, 0))
	_add_zone(WORK_ZONE, Vector2i(0, 1))
	_add_zone(CAULDRON_ZONE, Vector2i(1, 1))

func _add_zone(scene: PackedScene, coord: Vector2i):
	var node = scene.instantiate()
	node.position = map_to_local(Vector3i(coord.x, 0, coord.y))
	add_child(node)
	zones[coord] = node
