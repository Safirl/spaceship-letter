class_name PlayerController extends CharacterBody3D

## Base player controller to handle basic movements relatively to the camera orientation

## The pawn that will receive the animations in response to the inputs.
@export var pawn: Pawn

@export_group("Camera")
@export_range(0.0, 1.0, .01) var mouse_sensitivity := .25

@export_group("Movement")
@export_range(0., 20., .1) var move_speed := 8.0
@export_range(0., 40., .1) var acceleration := 20.0
@export_range(0., 20., .1) var rotation_speed := 12.0
@export_range(0., 20., .1) var jump_impulse := 12.0
@export_range(-30.0, 0., .1) var gravity := -30.0

@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %Camera

## inject BaseGravityComponents behaviors
signal request_gravity(delta: float, previous_velocity: Vector3)

var _camera_input_direction := Vector2.ZERO
#In Godot, Vector3.BACK is Forward vector in world space
var _last_movement_direction := Vector3.BACK

func _ready() -> void:
	if not is_instance_valid(pawn) or not is_instance_valid(_camera) or not is_instance_valid(_camera_pivot):
		push_error("One of the required nodes for player controller is not valid")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		

func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion := (
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		var event_mouse_motion = event as InputEventMouseMotion
		_camera_input_direction = event_mouse_motion.screen_relative * mouse_sensitivity

func _physics_process(delta: float) -> void:
	_move_camera(delta)
	var raw_input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var forward := _camera.global_basis.z
	var right := _camera.global_basis.x
	
	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.
	move_direction = move_direction.normalized()
	var old_velocity := velocity
	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
	
	#request_gravity.emit(delta, old_velocity)
	velocity.y = old_velocity.y + gravity * delta	
	
	var is_starting_jump := Input.is_action_just_pressed("jump") and is_on_floor()
	if is_starting_jump:
		velocity.y += jump_impulse
	
	move_and_slide()
	
	if move_direction.length() > .2:
		_last_movement_direction = move_direction
	var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
	pawn.global_rotation.y = lerp_angle(pawn.rotation.y, target_angle, rotation_speed * delta)
	_animate_character(is_starting_jump)
	
func _animate_character(is_starting_jump: bool) -> void:
	if is_starting_jump:
		pawn.jump()
	elif not is_on_floor() and velocity.y < 0.0:
		pawn.fall()
	elif is_on_floor():
		var ground_speed := velocity.length()
		if ground_speed > 0.0:
			pawn.move()
		else:
			pawn.idle()

func _move_camera(delta: float) -> void:
	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, deg_to_rad(0), deg_to_rad(80))
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta
	
	_camera_input_direction = Vector2.ZERO
