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
			obstacle_timer.start()
		else:
			shop_time_effect.do_hide()
			ready_effect.do_show()
			player_spawner.shop_closed()
			obstacle_timer.stop()
			
			if was_open:
				was_open = false

@export var shop_open_time: Control
@export var money_label: Label
@export var shop: Shop
@export var player_spawner: PlayerSpawner
@export var customer_spawner: CustomerSpawner
@export var obstacles: Array[Trap] = []

@onready var shop_open_timer: Timer = $ShopOpenTimer
@onready var shop_time_effect: SlideEffect = $ShopTimeEffect
@onready var ready_effect: SlideEffect = $ReadyEffect
@onready var obstacle_timer: RandomTimer = $ObstacleTimer
@onready var modular_map: ModularMap = $ModularMap

var failed_orders := 0
var difficulty := 1.0
var day := 0:
	set(v):
		day = v
		if day == 1:
			GameManager.increase_menu()
		if day == 2:
			GameManager.increase_menu()

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
	
	GameManager.money_changed.connect(func(m): money_label.text = "%s" % m)
	
	shop_open = false
	player_spawner.start_game.connect(func(): start_game())
	shop_open_timer.timeout.connect(func():
		if not customer_spawner.has_order():
			shop_open = false
	)
	customer_spawner.order_success.connect(func(item):
		GameManager.finished_order(item)
		_check_shop_status()
	)
	customer_spawner.order_failed.connect(func():
		failed_orders += 1
		_check_shop_status()
	)
	obstacle_timer.timeout.connect(func():
		var obstacle = obstacles.pick_random() as Trap
		obstacle.start()
		await obstacle.finished
		obstacle_timer.random_start()
	)
	
	modular_map.setup()

func _check_shop_status():
	if shop_open_timer.is_stopped() and shop_open:
		shop_open = false

func start_game():
	shop_open = true
