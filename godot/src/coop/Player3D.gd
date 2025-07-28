class_name Player3D
extends RigidBody3D

const ARM_BONES = ["UpperArm.L", "LowerArm.L", "UpperArm.R", "LowerArm.R"]

signal cleared()
signal died(pos: Vector3)
signal accepted()

@export var player_input: PlayerInput
@export var color_ring: Sprite3D
@export var color := Color.WHITE:
	set(v):
		color = v
		color_ring.modulate = color
@onready var grid: ShopGridMap = get_tree().get_first_node_in_group("grid")

@export_category("Items")
@export var throw_charge: Chargeable
@export var preview_item: PreviewBlock
@export var item_nodes: ItemNodes
@export var throw_item: PackedScene
@export var throw_angle := 45.0

@export_category("Movement")
@export var upright_joint_spring_strength := 10
@export var upright_joint_spring_damper := 1.5
@export var animation: PlayerAnimation
@onready var physics_movement: PhysicsMovement = $PhysicsMovement
@onready var ground_spring_cast: GroundSpringCast = $GroundSpringCast

@export_category("Effects")
@export var phyiscal_bone_simulator: PhysicalBoneSimulator3D
@export var body_bone: PhysicalBone3D
@onready var freeze_timer: Timer = $FreezeTimer
@onready var explosion_timer: Timer = $ExplosionTimer

@onready var pivot = $Pivot
@onready var hold_point = $Pivot/HoldPoint
@onready var hand_3d: Hand3D = $Pivot/Hand3D

var hidden := false:
	set(v):
		hidden = v
		freeze = v
		pivot.visible = not hidden
		set_process(not hidden)
		set_physics_process(not hidden)

var working_obj = null
var is_hold_pressed := false:
	set(v):
		is_hold_pressed = v
		if is_hold_pressed:
			animation.prepare_catch()

func _ready() -> void:
	explosion_timer.timeout.connect(func():
		cleared.emit()
		queue_free()
	)
	hand_3d.body_entered.connect(func(item):
		if item is ThrowableItem and is_hold_pressed:
			item.pick_up(hand_3d)
	)
	
	for c in phyiscal_bone_simulator.get_children():
		if c is PhysicalBone3D:
			add_collision_exception_with(c)
	
	_update_hand_items()
	hand_3d.item_changed.connect(func(): _update_hand_items())
	hand_3d.picked_up_at.connect(func(pos: Vector3):
		var p = grid.local_to_map(pos)
		grid.remove(Vector2i(p.x, p.z))
	)
	
	player_input.just_pressed.connect(func(event: InputEvent):
		if event.is_action_pressed("interact"):
			_hand_interact()
		elif event.is_action_pressed("action"):
			_hand_action()
		elif event.is_action_pressed("accept"):
			accepted.emit()
		elif event.is_action_pressed("ui_cancel"):
			throw_charge.stop()
			is_hold_pressed = false
		# elif event.is_action_pressed("dash"):
		# 	var b = pivot.basis as Basis
		# 	knockback = Vector3.FORWARD * dash_speed * b.get_rotation_quaternion().inverse()
	)
	
	player_input.just_released.connect(func(event: InputEvent):
		if event.is_action_released("action"):
			_hand_action_release()
	)

func _process(_delta: float) -> void:
	preview_item.update_position(global_position)

func _physics_process(delta: float) -> void:
	if not freeze_timer.is_stopped() or phyiscal_bone_simulator.is_simulating_physics():
		animation.active = false
		return
	
	animation.active = true

	if not is_hold_pressed and not working_obj:
		var move_dir = _get_move_dir()
		_aim_for_throw(move_dir)
		apply_central_force(physics_movement.apply_physics(move_dir, delta, linear_velocity) * mass)
	
	apply_central_force(ground_spring_cast.apply_spring_force(linear_velocity))
	apply_torque(_get_upright_rotation())


### Items ###
func _hand_interact():
	if hand_3d.is_holding_item() and hand_3d.item is GridItem:
		var player_pos = preview_item.get_grid_position(global_position)
		if can_place_at(player_pos) and grid.place(Vector2i(player_pos.x, player_pos.z), hand_3d.item):
			hand_3d.take_item()

		# Right now its needs to fall through
		# when the player is holding a CAULDRON and interacting with the TRASH
		
		# if grid.place(Vector2i(player_pos.x, player_pos.z), hand_3d.item):
		# 	hand_3d.take_item()
		# 	return

	hand_3d.interact()

func can_place_at(coord: Vector3i) -> bool:
	var pos = grid.map_to_local(coord)
	var mask = 1

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(pos + Vector3.UP * 0.5, pos + Vector3.DOWN * 0.5, mask)
	var result = space_state.intersect_ray(query)
	print(result)
	return result.is_empty()

func _hand_action():
	var obj = hand_3d.action(true)
	if obj:
		working_obj = obj
		animation.start_work()
		return
	
	if not hand_3d.is_holding_item():
		is_hold_pressed = true
		return
		
	if not hand_3d.item is PotionItem:
		print("Can only throw potion items")
		return 
	
	throw_charge.start()

func _hand_action_release():
	if throw_charge.is_charging:
		_throw_item(hand_3d.item)
		hand_3d.take_item()
	else:
		hand_3d.action(false)
	
	working_obj = null
	is_hold_pressed = false

func _throw_item(item):
	var force = throw_charge.stop()
	var node = item_nodes.get_node_for_item(item)
	
	var throwing_item = throw_item.instantiate()
	throwing_item.add_child(node.duplicate())
	throwing_item.item = hand_3d.item
	get_tree().current_scene.add_child(throwing_item)
	throwing_item.global_position = item_nodes.global_position
	
	throwing_item.throw_at(_get_throw_dir() * force)

func _get_throw_dir():
	var dir = _get_face_dir()
	var throw: Vector3 = dir
	var throw_axis = throw.rotated(Vector3.UP, deg_to_rad(90)).normalized()
	
	return throw.rotated(throw_axis, deg_to_rad(-throw_angle))

func _get_face_dir():
	var quat = pivot.basis.get_euler() as Vector3
	return Vector3.FORWARD.rotated(Vector3.UP, quat.y)

func _update_hand_items():
	if hand_3d.is_holding_item():
		item_nodes.show_item(hand_3d.item)
		preview_item.show()
	else:
		item_nodes.hide_all()
		preview_item.hide()

### Effects ###

func freeze_body():
	freeze_timer.start()

func explode(from: Vector3, force = 200):
	died.emit(global_position)
	color_ring.hide()
	
	phyiscal_bone_simulator.active = true
	phyiscal_bone_simulator.physical_bones_start_simulation()
	
	var dir = from.direction_to(global_position)
	body_bone.apply_central_impulse(dir * force)
	explosion_timer.start()

func levitate():
	pass

### Movement ###

func _get_move_dir():
	var motion = player_input.get_vector("move_left", "move_right", "move_up", "move_down")
	var move_dir = Vector3(motion.x, 0, motion.y)
	if move_dir.length() > 1:
		move_dir = move_dir.normalized()
	return move_dir

func _aim_for_throw(move_dir: Vector3):
	var aim = player_input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if aim:
		pivot.basis = Basis.looking_at(Vector3(aim.x, 0, aim.y))
	else:
		if throw_charge.is_charging:
			var offset = -PI * 0.5
			var screen_pos = get_viewport().get_camera_3d().unproject_position(pivot.global_transform.origin)
			var mouse_pos = get_viewport().get_mouse_position()
			var angle = screen_pos.angle_to_point(mouse_pos)
			pivot.rotation.y = -(angle + offset)
		elif move_dir:
			pivot.basis = Basis.looking_at(move_dir)

func _get_upright_rotation():
	var upright_rotation = Basis().rotated(Vector3.UP, 0)
	var current_rotation = transform.basis
	var target_rotation = upright_rotation
	var rotation_difference = (target_rotation * current_rotation.inverse()).get_rotation_quaternion()

	var axis = rotation_difference.get_axis()
	var angle = rotation_difference.get_angle()

	return axis * angle * upright_joint_spring_strength - (angular_velocity * upright_joint_spring_damper)
