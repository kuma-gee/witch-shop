extends Sprite3D

@export var raycast: RayCast3D

func _process(delta: float) -> void:
	if raycast.is_colliding():
		global_position.y = raycast.get_collision_point().y
	else:
		global_position.y = 0
	
	global_position.y += 0.1
