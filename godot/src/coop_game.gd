class_name CoopGame
extends Node3D

var was_open := false
var shop_open := false:
	set(v):
		shop_open = v
		GameManager.shop_open = v
		
		if shop_open:
			was_open = true
			day += 1
			
			failed_orders = 0
			shop_open_timer.start()
			shop_time_effect.do_show()
			ready_effect.do_hide()
			_start_zones()
		else:
			if day == 1:
				GameManager.increase_menu()
			
			shop_time_effect.do_hide()
			ready_effect.do_show()
			player_spawner.shop_closed()
			_stop_zones()
			_update_zones()
			
			if was_open:
				was_open = false

@export var shop_open_time: Control
@export var money_label: Label
@export var shop: Shop
@export var player_spawner: PlayerSpawner

@onready var shop_open_timer: Timer = $ShopOpenTimer
@onready var shop_time_effect: SlideEffect = $ShopTimeEffect
@onready var ready_effect: SlideEffect = $ReadyEffect
@onready var modular_map: ModularMap = $ModularMap

var failed_orders := 0
var difficulty := 1.0
var day := 0

func _ready() -> void:
	InputMapper.override_key_inputs({
		"move_left": [KEY_A, InputMapper.joy_stick_x(-1)],
		"move_right": [KEY_D, InputMapper.joy_stick_x(1)],
		"move_up": [KEY_W, InputMapper.joy_stick_y(-1)],
		"move_down": [KEY_S, InputMapper.joy_stick_y(1)],
		"interact": [MOUSE_BUTTON_LEFT, InputMapper.joy_btn(JOY_BUTTON_A)],
		"action": [MOUSE_BUTTON_RIGHT, InputMapper.joy_btn(JOY_BUTTON_X)],
		"accept": [KEY_CTRL, InputMapper.joy_btn(JOY_BUTTON_Y)],
	})
	
	shop_open = false
	GameManager.money_changed.connect(func(m): money_label.text = "%s" % m)
	
	var customer_spawn = _get_customer_spawner()
	player_spawner.start_game.connect(func(): start_game())
	shop_open_timer.timeout.connect(func():
		if not customer_spawn.has_order():
			shop_open = false
	)
	customer_spawn.order_success.connect(func(item):
		GameManager.finished_order(item)
		_check_shop_status()
	)
	customer_spawn.order_failed.connect(func():
		failed_orders += 1
		_check_shop_status()
	)

func _get_customer_spawner() -> CustomerSpawner:
	return get_tree().get_first_node_in_group("customer_spawn")
	
func _get_player_spawner() -> PlayerSpawner:
	return get_tree().get_first_node_in_group("player_spawn")

func _check_shop_status():
	if shop_open_timer.is_stopped() and shop_open:
		shop_open = false

func start_game():
	if _are_zones_moving(): return
	shop_open = true

func _update_zones():
	var data = GameManager.get_current_needed_ingredients()
	var ingredients = data[0]
	var processes = data[1]
	modular_map.setup(ingredients, processes)
	
	print(ingredients, processes)

	if not modular_map.material_zone.has_all_ingredients(ingredients):
		modular_map.material_zone = modular_map.add_zone(modular_map.MATERIAL_ZONE, modular_map.material_zone.coord)

	if not modular_map.work_zone.has_all_processes(processes):
		modular_map.work_zone = modular_map.add_zone(modular_map.WORK_ZONE, modular_map.work_zone.coord)

	modular_map.material_zone.set_ingredients(ingredients)
	modular_map.work_zone.set_processes(processes)
	modular_map.update_directions()

func _start_zones():
	for zone in get_tree().get_nodes_in_group(Zone.GROUP):
		zone.start()
	
func _stop_zones():
	for zone in get_tree().get_nodes_in_group(Zone.GROUP):
		zone.stop()

func _are_zones_moving():
	for zone in get_tree().get_nodes_in_group(Zone.GROUP):
		if zone.is_moving():
			return true
	return false
