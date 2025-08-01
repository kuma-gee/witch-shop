class_name PlayerSpawner
extends Marker3D

signal start_game()

@export var player: PackedScene
@export var spawn_root: Node3D
@export var ready_container: ReadyContainer

@export var colors: Array[Color] = []

var player_colors := {}
var ready_players := {}
var started := false

func _unhandled_input(event: InputEvent) -> void:
	if not started:
		_create_player(event)

func _create_player(event: InputEvent):
	var input = _create_input(event) as PlayerInput
	add_child(input)
	player_colors[input.get_id()] = colors[player_colors.size()] if player_colors.size() < colors.size() else Color.WHITE
	ready_players[input.get_id()] = false
	_create_player_for_input(input)

func _create_player_for_input(input: PlayerInput, pos = position):
	var player_node = player.instantiate() as Player3D
	var player_id = input.get_id()
	player_node.position = pos
	player_node.player_input = input
	player_node.color = player_colors[input.get_id()]
	spawn_root.add_child(player_node)
	
	player_node.accepted.connect(func(): _player_accepted(player_id))
	player_node.died.connect(func(pos):
		var node = _create_player_for_input(input, to_local(pos))
		node.hidden = true
		await player_node.cleared
		node.hidden = false
	)
	return player_node

func _create_input(event: InputEvent):
	var input = PlayerInput.new()
	input.set_for_event(event)
	return input

func _player_accepted(player_id: String):
	if started: return
	
	ready_players[player_id] = not ready_players[player_id]
	ready_container.set_ready(player_id, ready_players[player_id])
	
	if is_everyone_ready():
		start_game.emit() # Signals in here don't work?
		started = true
		reset_ready_state()

func _find_input_for(event: InputEvent):
	var joypad = PlayerInput.is_joypad_event(event)
	var device = event.device
	
	for c in get_children():
		if not c is PlayerInput: continue
		
		var input = c as PlayerInput
		if input.device_id == device and input.joypad == joypad:
			return input
	
	return null

func get_player_count():
	return get_children().size()

func is_everyone_ready():
	return ready_players.values().filter(func(x): return not x).is_empty()

func reset_ready_state():
	for x in ready_players:
		ready_players[x] = false

func shop_closed():
	ready_container.reset()
	started = false
