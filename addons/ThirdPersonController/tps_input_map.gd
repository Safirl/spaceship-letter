extends Node

class TPSInput:
	var action_name: String
	var events: Array[InputEvent]

var inputs: Array[TPSInput]

func _ready() -> void:
	if InputMap == null:
		push_error("Input map is null")
		return;
		
	_create_input_events()
	_register_inputs()

## Manually add inputs here. They will be automatically added to the InputMap
func _create_input_events() -> void:
	pass

func _register_inputs() -> void:
	for input in inputs:
		if not InputMap.has_action(input.action_name):
			InputMap.add_action(input.action_name)
		
		for input_event in input.events:
			if not InputMap.action_has_event(input.action_name, input_event):
				InputMap.action_add_event(input.action_name, input_event)
