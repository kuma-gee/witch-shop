extends Trap

const DIRS = [
	Vector2.UP,
	Vector2.RIGHT,
]

@export var map: ModularMap
@export var timer: RandomTimer

# Dont need default ready function of super class
func _ready() -> void:
	timer.timeout.connect(func():
		for coord in map.zones:
			var zone = map.zones[coord] as Zone
			if zone.is_moving(): continue # should not happen?
			var pos = map.map_to_local(_to_vector3(zone.coord))
			zone.move_to(pos)
		
		finished.emit()
	)

func _to_vector3(coord: Vector2):
	return Vector3i(coord.x, 0, coord.y)

func start():
	var coords = map.zones.keys()
	var coord = coords.pick_random()

	var dir = DIRS.pick_random()
	var parts = split_floor(coords, coord, Vector2(coord) + dir)

	var group_a = parts[0]
	var group_b = parts[1]

	if group_a.size() == 0 or group_b.size() == 0:
		finished.emit()
		return

	var move_dir = dir.rotated(PI/2)
	var move_offset = map.map_to_local(_to_vector3(move_dir))

	for p in group_a:
		var zone = map.zones[p]
		zone.move_to(zone.position + move_offset)
	for p in group_b:
		var zone = map.zones[p]
		zone.move_to(zone.position - move_offset)
	
	timer.random_start()
	
	if connected_trap:
		connected_trap.start()

func split_floor(coords: Array, start: Vector2, end: Vector2):
	var group_a := []
	var group_b := []
	
	for p in coords:
		# https://stackoverflow.com/questions/1560492/how-to-tell-whether-a-point-is-to-the-right-or-left-side-of-a-line
		var side = (end.x - start.x) * (p.y - start.y) - (end.y - start.y) * (p.x - start.x)
		if side > 0:
			group_a.append(p)
		else:
			group_b.append(p)
	
	#print("Positive: %s" % [group_a])
	#print("Negative: %s" % [group_b])
	return [group_a, group_b]
