extends Node3D

@onready var meshInstance: MeshInstance3D = %Mesh
@export var blackhole_camera: Camera3D
@export var blackhole_subviewport: SubViewport
var blackhole_material: ShaderMaterial

func _ready() -> void:
	if (!blackhole_camera):
		blackhole_camera = get_tree().current_scene.find_child("BlackholeCamera")
		
	if (!blackhole_subviewport):
		blackhole_subviewport = get_tree().current_scene.find_child("BlackholeViewport")
	
	blackhole_material = meshInstance.mesh.material as ShaderMaterial
	if (!blackhole_material):
		push_error("ShaderMaterial not valid ! Can't initialize shader")
	#blackhole_material.set_shader_parameter("screen_texture", blackhole_subviewport.get_texture())



func _process(delta: float) -> void:
	look_at(blackhole_camera.global_position)
