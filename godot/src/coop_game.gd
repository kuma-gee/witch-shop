class_name CoopGame
extends Node3D

var was_open := false
var shop_open := false:
	set(v):
		shop_open = v
		_update_moveable_objects()
		
		if shop_open:
			was_open = true
			day += 1
			
			customer_spawner.start()
			shop_open_timer.start()
			shop_time_effect.do_show()
			ready_effect.do_hide()
		else:
			shop_time_effect.do_hide()
			ready_effect.do_show()
			player_spawner.shop_closed()
			
			if was_open:
				shop.open_shop()
				was_open = false

@export var shop_open_time: Control
@export var money_label: Label
@export var shop: Shop
@export var customer_spawner: CustomerSpawner
@export var player_spawner: PlayerSpawner

@onready var shop_open_timer: Timer = $ShopOpenTimer
@onready var navigation_region_3d: NavigationRegion3D = $NavigationRegion3D
@onready var grid_map: ShopGridMap = $NavigationRegion3D/GridMap
@onready var shop_time_effect: SlideEffect = $ShopTimeEffect
@onready var ready_effect: SlideEffect = $ReadyEffect

var difficulty := 1.0
var day := 0:
	set(v):
		day = v
		if day == 1:
			customer_spawner.add_new_menu()

var money := 0:
	set(v):
		money = v
		money_label.text = "%s" % v

func _ready() -> void:
	InputMapper.override_key_inputs({
		"move_left": [KEY_A, InputMapper.joy_stick_x(-1)],
		"move_right": [KEY_D, InputMapper.joy_stick_x(1)],
		"move_up": [KEY_W, InputMapper.joy_stick_y(-1)],
		"move_down": [KEY_S, InputMapper.joy_stick_y(1)],
		"interact": [MOUSE_BUTTON_LEFT, InputMapper.joy_btn(JOY_BUTTON_A)],
		"action": [MOUSE_BUTTON_RIGHT, InputMapper.joy_btn(JOY_BUTTON_X)],
		"dash": [KEY_SHIFT, InputMapper.joy_btn(JOY_BUTTON_B)],
		"accept": [KEY_CTRL, InputMapper.joy_btn(JOY_BUTTON_Y)],
		"hold": [MOUSE_BUTTON_RIGHT, InputMapper.joy_btn(JOY_BUTTON_RIGHT_SHOULDER)]
	})
	
	customer_spawner.order_success.connect(func(potion: PotionItem): money += potion.get_price())
	
	#grid_map.setup_finished.connect(func():
		#player_spawner = get_tree().get_first_node_in_group("player_spawn")
		#customer_spawner = get_tree().get_first_node_in_group("customer_spawn")
		#print(customer_spawner)
		#shop_open = false
		#
		#customer_spawner.customer_left.connect(func(c):
			#if customer_spawner.is_stopped():
				#_check_all_customers_left(c)
		#)
	#)
	
	shop_open = false
	grid_map.start_game.connect(func(): start_game())
	#grid_map.object_placed.connect(func(): _update_moveable_objects())
	
	shop_open_timer.timeout.connect(func():
		customer_spawner.stop()
		shop_open = false
	)

func start_game():
	shop_open = true

func _update_moveable_objects():
	for obj in get_tree().get_nodes_in_group("moveable"):
		obj.pickupable = not shop_open

func _reset_moveable_objects():
	for obj in get_tree().get_nodes_in_group("moveable"):
		obj.reset()
