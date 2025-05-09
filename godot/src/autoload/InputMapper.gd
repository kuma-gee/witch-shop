class_name InputMapper

static func override_key_inputs(inputs: Dictionary):
	for action in InputMap.get_actions():
		if action.begins_with("ui_"): continue # getting errors if build-in actions doesn't exist
		InputMap.erase_action(action)

	for action in inputs:
		add_input(action, inputs[action])
	
static func input_to_event(k: Variant):
	if k is InputEvent:
		return k;
	elif k >= MOUSE_BUTTON_LEFT and k <= MOUSE_BUTTON_XBUTTON2:
		return mouse(k)
	else:
		return key(k)

static func add_input(action: String, inputs: Variant):
	InputMap.add_action(action)
		
	var value = inputs
	if not value is Array:
		value = [inputs]

	for k in value:
		InputMap.action_add_event(action, input_to_event(k))
		InputMap.action_set_deadzone(action, 0.5)

static func mouse(k: int) -> InputEventMouseButton:
	var ev = InputEventMouseButton.new()
	ev.button_index = k
	return ev

static func key(k: int) -> InputEventKey:
	var ev = InputEventKey.new()
	ev.keycode = k
	return ev

static func joy_btn(k: int) -> InputEventJoypadButton:
	var ev = InputEventJoypadButton.new()
	ev.button_index = k
	return ev

static func joy_stick_x(value: int) -> InputEventJoypadMotion:
	var ev = InputEventJoypadMotion.new()
	ev.axis = JOY_AXIS_LEFT_X
	ev.axis_value = value
	return ev

static func joy_stick_y(value: int) -> InputEventJoypadMotion:
	var ev = InputEventJoypadMotion.new()
	ev.axis = JOY_AXIS_LEFT_Y
	ev.axis_value = value
	return ev
