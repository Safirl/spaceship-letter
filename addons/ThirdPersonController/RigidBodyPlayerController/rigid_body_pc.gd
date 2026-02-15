class_name RigidBodyPlayerController extends RigidBody3D

## player controller to handle basic movements with tank controls.
## The gravity is received from external forces. 
## This player controller is useful when there are external forces that need to move the player.

## The pawn that will receive the animations in response to the inputs.
@export var pawn: Pawn

@export_group("Camera")
@export_range(0.0, 1.0, .01) var mouse_sensitivity := .25

@export_group("Movement")
@export_range(0., 20., .1) var move_speed := 8.0
@export_range(0., 40., .1) var acceleration := 20.0
@export_range(0., 20., .1) var rotation_speed := 12.0
@export_range(0., 20., .1) var jump_impulse := 12.0

@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %Camera

var _camera_input_direction := Vector2.ZERO
var _last_movement_direction := Vector3.BACK

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not is_instance_valid(pawn) or not is_instance_valid(_camera) or not is_instance_valid(_camera_pivot):
		push_error("One of the required nodes for player controller is not valid")

## TODO: This should be in another class
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

## TODO: This should be in a camera class
func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion := (
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		var event_mouse_motion = event as InputEventMouseMotion
		_camera_input_direction = event_mouse_motion.screen_relative * mouse_sensitivity

func _animate_character(is_starting_jump: bool) -> void:
	if is_starting_jump:
		pawn.jump()
	elif not is_on_floor() and linear_velocity.y < 0.0:
		pawn.fall()
	elif is_on_floor():
		var ground_speed := linear_velocity.length()
		if ground_speed > 0.0:
			pawn.move()
		else:
			pawn.idle()

func _move_camera(delta: float) -> void:
	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, deg_to_rad(0), deg_to_rad(80))
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta
	
	_camera_input_direction = Vector2.ZERO

func is_on_floor() -> bool:
	return true