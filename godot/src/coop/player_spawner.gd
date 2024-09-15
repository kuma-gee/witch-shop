extends Marker3D

@export var player: PackedScene
@export var grid: ShopGridMap
@export var root: Node3D

@export var colors: Array[Color] = []

func _unhandled_input(event: InputEvent) -> void:
	_create_player(event)

func _create_player(event: InputEvent):
	var input = _create_input(event)
	var player_node = player.instantiate() as Player3D
	
	add_child(input)
	
	player_node.player_input = input
	player_node.grid = grid
	player_node.color = colors[get_child_count()] if get_child_count() < colors.size() else Color.WHITE
	root.add_child(player_node)

func _create_input(event: InputEvent):
	var input = PlayerInput.new()
	input.set_for_event(event)
	return input

func _find_input_for(event: InputEvent):
	var joypad = PlayerInput.is_joypad_event(event)
	var device = event.device
	
	for c in get_children():
		if not c is PlayerInput: continue
		
		var input = c as PlayerInput
		if input.device_id == device and input.joypad == joypad:
			return input
	
	return null
