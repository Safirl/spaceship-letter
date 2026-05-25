class_name RigidBodyPlayerController extends RigidBody3D

## player controller to handle basic movements with tank controls.
## The gravity is received from external forces.
## This player controller is useful when there are external forces that need to move the player.

## The pawn that will receive the animations in response to the inputs.
@export var pawn: Pawn

@export_group("Camera")
@export_range(0.0, 1.0, .01) var mouse_sensitivity := .25

@export_group("Movement")
@export_range(0., 20., .1) var move_speed := 4.0
@export_range(0., 40., .1) var acceleration := 20.0
@export_range(0., 20., .1) var rotation_speed := 12.0
@export_range(0., 20., .1) var jump_impulse := 3.0
@export_range(0., 100., .1) var damping := 60.0

@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %PlayerCamera

var _camera_input_direction := Vector2.ZERO
var _move_direction := Vector3.ZERO
var _last_strong_direction := Vector3.ZERO
var _is_starting_jump := false
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


func _process(delta: float) -> void:
	_move_camera(delta)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	local_gravity = state.total_gravity.normalized()
	_move_direction = _get_model_oriented_input()
	_is_starting_jump = Input.is_action_just_pressed("jump")

	_orient_body_to_gravity(state.step)

	if _move_direction.length() > 0.2:
		_last_strong_direction = _move_direction
		_orient_character_to_direction(_last_strong_direction, state.step)

	var up := -local_gravity
	var current := state.linear_velocity

	# Décomposer la vélocité actuelle
	var vertical_velocity := up * current.dot(up)      # composante gravité/saut
	var horizontal_velocity := current - vertical_velocity  # composante mouvement

	# Calculer la cible horizontale uniquement
	var local_move := _move_direction - up * _move_direction.dot(up)
	var target_horizontal := local_move.normalized() * move_speed if local_move.length() > 0.001 else Vector3.ZERO

	# Interpoler uniquement l'horizontal, garder le vertical intact
	var new_horizontal := horizontal_velocity.move_toward(target_horizontal, acceleration / damping)
	state.linear_velocity = new_horizontal + vertical_velocity

	if _is_starting_jump and is_on_floor(state):
		apply_central_impulse(up * jump_impulse)

	_animate_character(state)

func _get_model_oriented_input() -> Vector3:
	var raw_input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var forward := _camera.global_basis.z
	var right := _camera.global_basis.x

	var move_direction := (forward * raw_input.y + right * raw_input.x).normalized()
	return move_direction

func _orient_body_to_gravity(delta: float) -> void:
	var up := -local_gravity
	var current_up := basis.y
	var rotation_axis := current_up.cross(up)
	if rotation_axis.length() < 0.001:
		return
	var angle := current_up.angle_to(up)
	var rotation_quat := Quaternion(rotation_axis.normalized(), angle)
	basis = Basis(rotation_quat.slerp(Quaternion.IDENTITY, 1.0 - delta * 5) * basis.get_rotation_quaternion())

func _orient_character_to_direction(direction: Vector3, delta: float) -> void:
	if direction.length() < 0.001:
		return
	var local_dir := basis.inverse() * direction
	local_dir.y = 0.0
	if local_dir.length() < 0.001:
		return
	local_dir = local_dir.normalized()
	
	var target_basis := Basis.looking_at(-local_dir, Vector3.UP)
	pawn.basis = Basis(pawn.basis.get_rotation_quaternion().slerp(
		target_basis.get_rotation_quaternion(),
		delta * rotation_speed
	))	

func _animate_character(state: PhysicsDirectBodyState3D) -> void:
	var up := -local_gravity
	var vertical_speed := state.linear_velocity.dot(up)
	if not is_on_floor(state):
		if vertical_speed > 0.0:
			pawn.jump()
		else:
			pawn.fall()
	elif is_on_floor(state):
		var ground_speed := linear_velocity.length()
		if ground_speed > 0.01:
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
	return Input.is_action_just_pressed("jump") and !is_on_floor(state)
