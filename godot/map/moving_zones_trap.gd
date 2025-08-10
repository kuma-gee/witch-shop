extends Trap

const DIRS = [
	Vector2i.UP,
	Vector2i.RIGHT,
	Vector2i.DOWN,
	Vector2i.LEFT,
]

@export var map: ModularMap

var tw: Tween

# Dont need default ready function
func _ready() -> void:
	pass

func start():
	var coords = map.zones.keys()
	var coord = coords.pick_random()
	
	if connected_trap:
		connected_trap.start()
