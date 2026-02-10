extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not InputMap:
		return;
	var ev = InputEventAction.new()
	# Set as ui_left, pressed.
	ev.action = "ui_left"
	ev.pressed = true
	# Feedback.
	Input.parse_input_event(ev)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
