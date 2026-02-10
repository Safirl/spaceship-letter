extends Node

class TPSInput extends RefCounted:
	var action_name: String
	var events: Array[InputEvent] = []
	
	func _init(in_action_name: String, in_events: Array[InputEvent]) -> void:
		if in_action_name.is_empty() or in_events.is_empty():
			push_error("Invalid TPSInput constructor")
			return;
		action_name = in_action_name
		events = in_events
		
var inputs: Array[TPSInput]

func _ready() -> void:
	if InputMap == null:
		push_error("Input map is null")
		return;
	_create_input_events()
	_register_inputs()

## Manually add inputs here. They will be automatically added to the InputMap
func _create_input_events() -> void:
	var move_left_WASD = InputEventKey.new()
	move_left_WASD.physical_keycode = KEY_A
	var move_left_arrow = InputEventKey.new()
	move_left_arrow.physical_keycode = KEY_LEFT
	var move_left_joystick = InputEventJoypadMotion.new()
	move_left_joystick.axis_value = -1.
	move_left_joystick.axis = JOY_AXIS_LEFT_X
	var move_left_events: Array[InputEvent] = [move_left_WASD, move_left_arrow, move_left_joystick]
	var move_left = TPSInput.new("move_left", move_left_events)
	inputs.push_back(move_left)

	
	var move_right_WASD = InputEventKey.new()
	move_right_WASD.physical_keycode = KEY_D
	var move_right_arrow = InputEventKey.new()
	move_right_arrow.physical_keycode = KEY_RIGHT
	var move_right_joystick = InputEventJoypadMotion.new()
	move_right_joystick.axis_value = 1.
	move_right_joystick.axis = JOY_AXIS_RIGHT_X
	var move_right_events: Array[InputEvent] = [move_right_WASD, move_right_arrow, move_right_joystick]
	var move_right = TPSInput.new("move_right", move_right_events)
	inputs.push_back(move_right)

	var move_forward_WASD = InputEventKey.new()
	move_forward_WASD.physical_keycode = KEY_W
	var move_forward_arrow = InputEventKey.new()
	move_forward_arrow.physical_keycode = KEY_UP
	var move_forward_joystick = InputEventJoypadMotion.new()
	move_forward_joystick.axis_value = 1.
	move_forward_joystick.axis = JOY_AXIS_LEFT_Y
	var move_forward_events: Array[InputEvent] = [move_forward_WASD, move_forward_arrow, move_forward_joystick]
	var move_forward = TPSInput.new("move_forward", move_forward_events)
	inputs.push_back(move_forward)

	var move_backward_WASD = InputEventKey.new()
	move_backward_WASD.physical_keycode = KEY_S
	var move_backward_arrow = InputEventKey.new()
	move_backward_arrow.physical_keycode = KEY_DOWN
	var move_backward_joystick = InputEventJoypadMotion.new()
	move_backward_joystick.axis_value = -1.
	move_backward_joystick.axis = JOY_AXIS_LEFT_Y
	var move_backward_events: Array[InputEvent] = [move_backward_WASD, move_backward_arrow, move_backward_joystick]
	var move_backward = TPSInput.new("move_backward", move_backward_events)
	inputs.push_back(move_backward)

func _register_inputs() -> void:
	for input in inputs:
		print("input name:", input.action_name)
		if not InputMap.has_action(input.action_name):
			InputMap.add_action(input.action_name)

		var existing_events := InputMap.action_get_events(input.action_name)

		for input_event in input.events:
			var already_exists := false
			for existing in existing_events:
				if existing.is_match(input_event):
					already_exists = true
					break

			if not already_exists:
				InputMap.action_add_event(input.action_name, input_event)
