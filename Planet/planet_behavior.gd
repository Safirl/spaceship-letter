extends Node3D

@export var spin_area := 5
@export var planet_gravity := 30
@export var rotation_speed := 20

@onready var gravity_area_collision_shape : CollisionShape3D = %MaxGravityShape
@onready var gravity_area : Area3D = %MaxGravityArea
@onready var planet_static_body: StaticBody3D = %PlanetStaticBody
@onready var planet_mesh: MeshInstance3D = %PlanetMesh

var _gravity_component: BaseGravityComponent
var _is_user_in_radius := false

func _ready() -> void:
	gravity_area.body_entered.connect(func(body: Node3D):
		if not is_instance_valid(body):
			return
		var children := body.get_children()
		if children.size() < 1:
			return
		var index := children.find_custom(func(child): return child is BaseGravityComponent)
		if index < 0:
			return
		_gravity_component = children.get(index)
		if not is_instance_valid(_gravity_component):
			return
		_is_user_in_radius = true
		)
		
	gravity_area.body_exited.connect(func(body: Node3D):
		if body is CharacterPlayerController:
			_gravity_component = null
			_is_user_in_radius = false
		)

func _physics_process(delta: float) -> void:
	if not _is_user_in_radius or not is_instance_valid(_gravity_component):
		return
	
	var parent := _gravity_component.get_parent() as Node3D
	if not is_instance_valid(parent) or not parent is Node3D:
		return
		
	var gravity := get_gravity_on_object(parent.global_position)
	var gravity_direction := get_gravity_direction(parent.global_position)
	print(gravity)
	_gravity_component.add_force(gravity_direction, gravity)
	#if 
	#var target_quat := get_spin_on_object(parent)
	#var current_quat := parent.global_basis.get_rotation_quaternion()
	#parent.global_basis = Basis(target_quat)
	#parent.look_at(global_position)

func get_gravity_on_object(object_position: Vector3) -> float:
	var sphere_shape := gravity_area_collision_shape.shape as SphereShape3D
	var distance := object_position.distance_to(position) - get_planet_radius()
	if not is_instance_valid(sphere_shape):
		push_error("Sphere shape is not valid")
		return 0.
	var object_gravity = planet_gravity - distance * planet_gravity / (sphere_shape.radius * scale.x - get_planet_radius())
	return object_gravity

func get_spin_on_object(object: Node3D) -> Quaternion:
	var direction_to_planet := object.global_position.direction_to(global_position)
	var target_basis := Basis.looking_at(-direction_to_planet)
	var target_quat := target_basis.get_rotation_quaternion()
	return target_quat

## object_position must be a global_position
func get_gravity_direction(object_position: Vector3) -> Vector3:
	return (global_position - object_position).normalized()

func get_planet_radius() -> float:
	if not is_instance_valid(planet_mesh) or not is_instance_valid(planet_mesh.mesh):
		push_error("planet mesh is not valid")
		return 0.
	if not is_instance_valid(planet_static_body):
		push_error("planet static body is not valid")
		return 0.
	var planet_sphere_mesh := planet_mesh.mesh as SphereMesh
	
	var total_radius := planet_sphere_mesh.radius * planet_static_body.scale.x * scale.x
	return total_radius
