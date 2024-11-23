class_name CustomerSpawner
extends Node3D

signal customer_left(c)

@export var spawn_margin := 1.0
@export var grid: ShopGridMap
@export var scene: PackedScene
@onready var random_timer: RandomTimer = $RandomTimer

func _ready() -> void:
	random_timer.timeout.connect(func(): spawn())

func start_timer():
	random_timer.start()

func stop_timer():
	random_timer.stop()

func is_stopped():
	return random_timer.is_stopped()

func spawn():
	var customer = scene.instantiate()
	add_child(customer)
	customer.has_left.connect(func(): customer_left.emit(customer))
	
	var tile = grid.get_random_customer_tile(get_customer_tiles())
	var target = grid.map_to_local(tile)
	customer.move_to(target)
	customer.tile = tile
	customer.return_pos = global_position

func get_customer_tiles():
	return get_tree().get_nodes_in_group("customer").map(func(x): return x.tile)
