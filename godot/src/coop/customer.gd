class_name ShopCustomer
extends CharacterBody3D

signal order_received(order)
signal has_left()

@export var speed := 4

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var pivot: Node3D = $Pivot
@onready var order: Sprite3D = $Order
@onready var interactable_3d: CustomerInteract = $Interactable3D
@onready var customer_detector: Area3D = $CustomerDetector

var return_pos: Vector3
var ordering_item: PotionItem.Type = -1
var leaving := false
var is_frozen := false
var tile: Vector3i

func _ready() -> void:
	order.hide()
	
	# customer_detector.body_entered.connect(func(_b): reached_position())
	interactable_3d.order_started.connect(func(o): set_order(o))
	interactable_3d.order_received.connect(func():
		order_received.emit(ordering_item)
		leave()
	)

func reached_position():
	navigation_agent_3d.target_position = global_position
	interactable_3d.enabled = true

func move_to(pos: Vector3):
	navigation_agent_3d.target_position = pos

func _physics_process(delta):
	if navigation_agent_3d.is_navigation_finished():
		if leaving:
			has_left.emit()
			queue_free()
		else:
			reached_position()
		return

	var next_path_position = navigation_agent_3d.get_next_path_position()
	var new_velocity = global_position.direction_to(next_path_position) * speed
	
	if new_velocity:
		pivot.basis = Basis.looking_at(new_velocity)
	_on_velocity_computed(new_velocity)
	
func _on_velocity_computed(safe_velocity):
	if is_frozen:
		return
		
	velocity = safe_velocity
	move_and_slide()

func set_order(item: PotionItem.Type):
	ordering_item = item
	order.modulate = PotionItem.get_color(item)
	order.show()

func leave():
	order.hide()
	move_to(return_pos)
	leaving = true

### Effects ###

func freeze():
	is_frozen = true
