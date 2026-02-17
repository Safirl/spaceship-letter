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
var _move_direction := Vector3.BACK
var _last_strong_direction := Vector3.ZERO
var local_gravity := Vector3.ZERO

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

func _get_model_oriented_input() -> Vector3:
	var input_left_right := (
		Input.get_action_strength("move_left") - 
		Input.get_action_strength("move_right")
	)
	var input_forward := Input.get_action_strength("move_forward")
	var raw_input := Vector2(input_left_right, input_forward)
	var input := Vector3.ZERO
	input.x = raw_input.x * sqrt(1. - raw_input.y * raw_input.y / 2)
	input.z = raw_input.y * sqrt(1. - raw_input.x * raw_input.x / 2)

	input = pawn.basis * input
	return input

func _process(delta: float) -> void:
	_move_camera(delta)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	local_gravity = state.total_gravity.normalized()

	if _move_direction.length() > .2:
		_last_strong_direction = _move_direction.normalized()

	_move_direction = _get_model_oriented_input()
	_orient_character_to_direction(_last_strong_direction, state.step)

	if is_jumping(state):
		apply_central_impulse(-local_gravity * jump_impulse)
	if is_on_floor(state):
		apply_central_force(_move_direction * move_speed)
	_animate_character(state)

func _orient_character_to_direction(direction: Vector3, delta: float) -> void:
	var left_axis := (-local_gravity.cross(direction))
	var rotation_basis := Basis(left_axis, -local_gravity, direction).orthonormalized()
	pawn.basis = pawn.basis.get_rotation_quaternion().slerp(rotation_basis, delta * rotation_speed)

func _animate_character(state: PhysicsDirectBodyState3D) -> void:
	if is_jumping(state):
		pawn.jump()
	elif not is_on_floor(state) and linear_velocity.y < 0.0:
		pawn.fall()
	elif is_on_floor(state):
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

func is_on_floor(state: PhysicsDirectBodyState3D) -> bool:
	for contact in state.get_contact_count():
		var contact_normal = state.get_contact_local_normal(contact)
		if contact_normal.dot(-local_gravity) > .5:
			return true	
	return false

func is_jumping(state: PhysicsDirectBodyState3D) -> bool:
	return Input.is_action_just_pressed("jump") and is_on_floor(state)
