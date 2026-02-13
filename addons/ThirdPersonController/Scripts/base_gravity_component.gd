class_name BaseGravityComponent extends Node3D

@export_range(-30.0, 0., .1) var gravity := -30.0

class Force:
	var direction: Vector3
	var strength: float
	
	func _init(new_direction: Vector3, new_strength: float) -> void:
		direction = new_direction
		strength = new_strength

var forces: Array[Force] = []
var _parent: PlayerController

func _ready() -> void:
	_parent = get_parent();
	if not is_instance_valid(_parent):
		push_error("parent object is not valid! This script must be used on a child component")
		return
	if not _parent is PlayerController:
		push_error("parent object is not a PlayerController! This script must be used as a PlayerController child")
		_parent = null
	_parent.request_gravity.connect(apply_gravity)

## called by _physics_process of the parent
func apply_gravity(delta: float, old_velocity: Vector3) -> void:
	if not is_instance_valid(_parent):
		push_error("parent object is not valid!")
		return
		
	for force in forces:
		var normalized_direction := force.direction.normalized()
		_parent.velocity += normalized_direction * force.strength * delta
	forces.clear()
	
func add_force(direction: Vector3, strength: float) -> void:
	if not is_instance_valid(_parent):
		push_error("parent object is not valid!")
		return
	forces.push_back(Force.new(direction, strength))


func _exit_tree() -> void:
	if not is_instance_valid(_parent):
		return
	_parent.request_gravity.disconnect(apply_gravity)
