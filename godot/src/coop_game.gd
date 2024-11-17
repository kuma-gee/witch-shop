extends Node3D

var shop_ui_tween: Tween
var shop_open := false:
	set(v):
		shop_open = v
		_update_moveable_objects()
		
		if shop_open:
			navigation_region_3d.bake_navigation_mesh()
			
			print("Opening Shop")
			customer_spawner.start_timer()
			shop_open_timer.start()
			shop_time_effect.do_show()
			ready_effect.do_hide()
		else:
			print("Closing Shop")
			shop_time_effect.do_hide()
			ready_effect.do_show()
			player_spawner.shop_closed()

var player_spawner: PlayerSpawner
var customer_spawner: CustomerSpawner

var money := 0:
	set(v):
		money = v
		money_label.text = "%s" % money

#@export var cashier: Cashier
@export var shop_open_time: Control
@export var money_label: Label

@onready var shop_open_timer: Timer = $ShopOpenTimer
@onready var navigation_region_3d: NavigationRegion3D = $NavigationRegion3D
@onready var grid_map: ShopGridMap = $NavigationRegion3D/GridMap
@onready var shop_time_effect: SlideEffect = $ShopTimeEffect
@onready var ready_effect: SlideEffect = $ReadyEffect

func _ready() -> void:
	InputMapper.override_key_inputs({
		"move_left": [KEY_A, InputMapper.joy_stick_x(-1)],
		"move_right": [KEY_D, InputMapper.joy_stick_x(1)],
		"move_up": [KEY_W, InputMapper.joy_stick_y(-1)],
		"move_down": [KEY_S, InputMapper.joy_stick_y(1)],
		"interact": [KEY_E, InputMapper.joy_btn(JOY_BUTTON_A)],
		"action": [KEY_SPACE, InputMapper.joy_btn(JOY_BUTTON_X)],
		"sprint": [KEY_SHIFT, InputMapper.joy_btn(JOY_BUTTON_B)],
		"accept": [KEY_CTRL, InputMapper.joy_btn(JOY_BUTTON_Y)],
		"hold": [MOUSE_BUTTON_RIGHT, InputMapper.joy_btn(JOY_BUTTON_RIGHT_SHOULDER)]
	})
	
	grid_map.setup_finished.connect(func():
		player_spawner = get_tree().get_first_node_in_group("player_spawn")
		customer_spawner = get_tree().get_first_node_in_group("customer_spawn")
		shop_open = false
		money = 0
		
		customer_spawner.customer_left.connect(func(c):
			if customer_spawner.is_stopped():
				_check_all_customers_left(c)
		)
		player_spawner.start_game.connect(func(): start_game())
	)
	
	shop_open_timer.timeout.connect(func():
		customer_spawner.stop_timer()
		_check_all_customers_left()
		print("Closing hours")
	)
	#cashier.money_received.connect(func(m): money += m)
	grid_map.object_placed.connect(func(): _update_moveable_objects())

func start_game():
	shop_open = true

func _update_moveable_objects():
	for obj in get_tree().get_nodes_in_group("moveable"):
		obj.pickupable = not shop_open

func _reset_moveable_objects():
	for obj in get_tree().get_nodes_in_group("moveable"):
		obj.reset()

func _check_all_customers_left(current_customer: ShopCustomer = null):
	var customers = get_tree().get_nodes_in_group("customer").filter(func(c): return c != current_customer)
	if customers.is_empty():
		shop_open = false
