class_name PhysicsMovement
extends Node

@export var max_speed := 8
@export var acceleration := 100
@export var acceleration_factor_from_dot: Curve
@export var max_accel_force := 150
@export var max_acceleration_factor_from_dot: Curve

var goal_vel := Vector3.ZERO

func apply_physics(move_dir: Vector3, delta: float, linear_velocity: Vector3) -> Vector3:
	var unit_vel = goal_vel.normalized()
	var vel_dot = move_dir.dot(unit_vel)
	var accel = acceleration * _curve_minus_range(acceleration_factor_from_dot, vel_dot)
	
	var current_target_vel = move_dir * max_speed
	goal_vel = goal_vel.move_toward(current_target_vel, accel * delta)
	
	var needed_accel = (goal_vel - linear_velocity) / delta
	var max_accel = max_accel_force * _curve_minus_range(max_acceleration_factor_from_dot, vel_dot)
	needed_accel = needed_accel.limit_length(max_accel)
	
	return needed_accel

func _curve_minus_range(curve: Curve, value: float):
	var scaled_value = (value + 1.0) / 2.0
	return curve.sample(scaled_value)
