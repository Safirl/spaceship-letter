extends BaseGravityComponent

func apply_gravity(delta: float, old_velocity: Vector3) -> void:
	if not is_instance_valid(_parent):
		push_error("parent object is not valid! This script must be used on a child component")
		return
	
	#var new_force := Force.new(Vector3.DOWN, abs(gravity))
	#forces.push_back(new_force) 
	#_parent.velocity.y = old_velocity.y
	
	super(delta, old_velocity)
