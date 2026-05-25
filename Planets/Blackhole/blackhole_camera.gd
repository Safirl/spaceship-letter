extends Camera3D

@onready var player_camera : Camera3D = %PlayerCamera 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (!player_camera):
		push_error("player camera is not valid. Can't move Blackhole camera")
	global_position = player_camera.global_position
	global_rotation = player_camera.global_rotation
