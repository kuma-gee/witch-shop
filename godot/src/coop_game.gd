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
			
			shop_open_timer.start()
			shop_time_effect.do_show()
			ready_effect.do_hide()
			obstacle_timer.start()
		else:
			_reset_moveable_objects()
			shop_time_effect.do_hide()
			ready_effect.do_show()
			player_spawner.shop_closed()
			obstacle_timer.stop()
			
			if was_open:
				shop.open_shop()
				was_open = false

@export var shop_open_time: Control
@export var money_label: Label
@export var shop: Shop
@export var player_spawner: PlayerSpawner

@onready var shop_open_timer: Timer = $ShopOpenTimer
@onready var grid_map: ShopGridMap = $GridMap
@onready var shop_time_effect: SlideEffect = $ShopTimeEffect
@onready var ready_effect: SlideEffect = $ReadyEffect
@onready var obstacle_timer: RandomTimer = $ObstacleTimer
@onready var obstacle_wait_timer: RandomTimer = $ObstacleWaitTimer

var difficulty := 1.0
var day := 0:
	set(v):
		day = v
		if day == 1:
			GameManager.increase_menu()

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
		"hold": [MOUSE_BUTTON_RIGHT, InputMapper.joy_btn(JOY_BUTTON_RIGHT_SHOULDER)],
		
		"action_1": [KEY_1],
		"action_2": [KEY_2],
		"action_3": [KEY_3]
	})
	
	GameManager.money_changed.connect(func(m): money_label.text = "%s" % m)
	
	shop_open = false
	player_spawner.start_game.connect(func(): start_game())
	grid_map.setup_finished.connect(func(): _update_moveable_objects())
	grid_map.object_placed.connect(func(): _update_moveable_objects())
	shop_open_timer.timeout.connect(func(): shop_open = false)
	obstacle_timer.timeout.connect(func():
		var groups = grid_map.split_floor(Vector2(-2, -2), Vector2(2, 2))
		grid_map.move_floor(groups[0], Vector3.LEFT * 3)
		grid_map.move_floor(groups[1], Vector3.RIGHT * 3)
		obstacle_wait_timer.random_start()
	)
	obstacle_wait_timer.timeout.connect(func():
		grid_map.reset_floor()
		obstacle_timer.start()
	)

func start_game():
	shop_open = true

func _update_moveable_objects():
	for obj in get_tree().get_nodes_in_group("moveable"):
		obj.pickupable = not shop_open

func _reset_moveable_objects():
	for obj in get_tree().get_nodes_in_group("moveable"):
		obj.reset()
