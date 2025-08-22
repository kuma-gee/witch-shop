extends RigidBody3D

#@export var max_angle: float = 90.0  # Maximum rotation in degrees
#@export var softness_strength: float = 10.0  # How strong the soft limit is
#@export var damping: float = 5.0  # Damping factor
#@export var hinge: HingeJoint3D
#
#var initial_rotation: Basis
#
#func _ready():
	## Store initial relative rotation
	#initial_rotation = global_transform.basis.inverse() * hinge.get_node(hinge.node_b).global_transform.basis
#
#func _physics_process(delta):
	## Calculate current relative rotation
	#var current_relative = global_transform.basis.inverse() * hinge.get_node(hinge.node_b).global_transform.basis
	#var rotation_diff = initial_rotation.inverse() * current_relative
	#
	## Convert to angle-axis representation
	#var angle = rotation_diff.get_rotation_angle()
	#var axis = rotation_diff.get_rotation_axis()
	#
	## Only consider rotation around the hinge axis (typically Y axis)
	#if axis.dot(Vector3.UP) > 0.9:  # Adjust if your hinge uses different axis
		#var degrees = rad_to_deg(angle)
		#
		## Apply soft limit
		#if abs(degrees) > max_angle:
			#var over_rotation = degrees - max_angle * sign(degrees)
			#var torque_amount = -over_rotation * softness_strength
			#var angular_vel = angular_velocity.dot(Vector3.UP)
			#var damping_force = -angular_vel * damping
			#apply_torque_impulse(Vector3.UP * (torque_amount + damping_force) * delta)
