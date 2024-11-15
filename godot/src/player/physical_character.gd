extends Node3D

const SPEED = 50
const DAMPING = 0.9

@export var angular_spring_stiffness: float = 4000.0
@export var angular_spring_damping: float = 80.0
@export var max_angular_force: float = 9999.0

@export var input: PlayerInput
@export var ragdoll_mode := false
@export var body_bone: PhysicalBone3D
@export var animation: AnimationPlayer

@export var on_floor_left: ShapeCast3D
@export var on_floor_right: ShapeCast3D
@export var simulator: PhysicalBoneSimulator3D

@onready var physical_skel : Skeleton3D = $Physical/Armature/Skeleton3D
@onready var animated_skel : Skeleton3D = $Animated/Armature/Skeleton3D
@onready var physical: Node3D = $Physical

@onready var physics_bones: Array = physical_skel.get_children().filter(func(x): return x is PhysicalBone3D)

var can_jump = true
var is_on_floor = false
var walking = false # if it is walking

var active_arm_left = false
var active_arm_right = false

var current_delta: float

func _ready() -> void:
	simulator.physical_bones_start_simulation()
	animated_skel.skeleton_updated.connect(func(): _on_skeleton_3d_skeleton_updated())

func _physics_process(delta):
	current_delta = delta
	if not ragdoll_mode:# if not in ragdoll mode
		
		# walking control
		#var move_2d = input.get_vector("move_left", "move_right", "move_up", "move_down")
		#var dir = Vector3(move_2d.x, 0, move_2d.y).normalized()
		
		var dir = Vector3.ZERO
		if input.is_action_pressed("move_up"):
			dir += animated_skel.global_transform.basis.z
		if input.is_action_pressed("move_left"):
			dir += animated_skel.global_transform.basis.x
		if input.is_action_pressed("move_right"):
			dir -= animated_skel.global_transform.basis.x
		if input.is_action_pressed("move_down"):
			dir -= animated_skel.global_transform.basis.z
			
		if dir:
			physical.basis = Basis.looking_at(dir)

		walking = dir.length() > 0

		body_bone.apply_central_impulse(dir * SPEED * delta) #move character
		#body_bone.linear_velocity *= Vector3(DAMPING, 1, DAMPING)# add damping to make it less slippery
		
		
		#check if is on floor
		is_on_floor = false
		if on_floor_left.is_colliding():
			for i in on_floor_left.get_collision_count():
				if on_floor_left.get_collision_normal(i).y > 0.5:
					is_on_floor = true
					break
		if not is_on_floor: 
			if on_floor_right.is_colliding():
				for i in on_floor_right.get_collision_count():
					if on_floor_right.get_collision_normal(i).y > 0.5:
						is_on_floor = true
						break
		
		#play walking animation/idle
		animation.play("Walk" if walking else "Idle")

		#rotate the character toward the camera direction
		#animated_skel.rotation.y = camera_pivot.rotation.y


func _on_skeleton_3d_skeleton_updated() -> void:
	if not ragdoll_mode:# if not in ragdoll mode
		# rotate the physical bones toward the animated bones rotations using hookes law
		for b:PhysicalBone3D in physics_bones:
			if not active_arm_left and b.name.contains("Arm_L"): continue # only rotated the arms if its activated
			if not active_arm_right and b.name.contains("Arm_R"): continue # only rotated the arms if its activated
			var target_transform: Transform3D = animated_skel.global_transform * animated_skel.get_bone_global_pose(b.get_bone_id())
			var current_transform: Transform3D = physical_skel.global_transform * physical_skel.get_bone_global_pose(b.get_bone_id())
			var rotation_difference: Basis = (target_transform.basis * current_transform.basis.inverse())
			var torque = hookes_law(rotation_difference.get_euler(), b.angular_velocity, angular_spring_stiffness, angular_spring_damping)
			torque = torque.limit_length(max_angular_force)
			
			b.angular_velocity += torque * current_delta

# spring related function
func hookes_law(displacement: Vector3, current_velocity: Vector3, stiffness: float, damping: float) -> Vector3:
	return (stiffness * displacement) - (damping * current_velocity)
