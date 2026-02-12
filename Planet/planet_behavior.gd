extends Node3D

#@export var gravity_area_collision_shape := 10
#@export var min_gravity_area := 2
@export var spin_area := 5
@export var planet_gravity := 30

@onready var gravity_area_collision_shape : CollisionShape3D = %MaxGravityShape
@onready var gravity_area : Area3D = %MaxGravityArea
@onready var planet_static_body: StaticBody3D = %PlanetStaticBody
@onready var planet_mesh: MeshInstance3D = %PlanetMesh

var _is_user_in_radius := false
var player_controller : CharacterBody3D = null
## Idée:
## La planète doit attirer le joueur vers son centre
## Selon un max et un min
## avec une zone pour tourner le joueur

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gravity_area.body_entered.connect(func(body: Node3D):
		if body is CharacterBody3D:
			player_controller = body
			_is_user_in_radius = true
		)
func _process(delta: float) -> void:
	if _is_user_in_radius and is_instance_valid(player_controller):
		get_gravity_on_object(player_controller.position)

func get_gravity_on_object(object_position: Vector3) -> float:
	var sphere_shape := gravity_area_collision_shape.shape as SphereShape3D
	var distance := object_position.distance_to(position) - get_planet_radius()
	## distance = 0 | max_distance x
	## gravity = 30 | gravity y
	if not is_instance_valid(sphere_shape):
		push_error("Sphere shape is not valid")
		return 0.
	var object_gravity = planet_gravity - distance * planet_gravity / (sphere_shape.radius - get_planet_radius())
	print(object_gravity)
	return 0.
	

func get_planet_radius() -> float:
	var planet_sphere_mesh := planet_mesh.mesh as SphereMesh
	
	var total_radius := planet_sphere_mesh.radius * planet_static_body.scale.x * scale.x
	return total_radius
