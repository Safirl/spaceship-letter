@tool
extends MeshInstance3D

@onready var mm_instance: MultiMeshInstance3D = $TentatclesMM
@export var tentacle_scene: PackedScene
@export var points_count: int = 8
@export var max_radius_offset: float = -1.
@export_tool_button("build_tentacles", "Callable") var build_tentacles_action := build_tentacles

func _ready() -> void:
	build_tentacles()

#func _process(delta: float) -> void:
	#if (!mm_instance):
		#return
	## set material params
	#var mm_material = mm_instance.multimesh.mesh.surface_get_material(0) as ShaderMaterial
	#var material = mesh.surface_get_material(0) as ShaderMaterial
	#if (mm_material && material):
		#mm_material.set_shader_parameter("ondulationSpeed", material.get_shader_parameter("ondulationSpeed"))

func build_tentacles():
	if (!tentacle_scene || !mm_instance):
		printerr("Can't build tentacles! One of the required file is not valid.")
		return
	
	var mm = MultiMesh.new();
	var instance: Node3D = tentacle_scene.instantiate()
	if (!instance):
		printerr("Can't build tentacles! tentacle_scene instance is not valid")
		return
	
	var mesh_instance: MeshInstance3D = instance
	mm.mesh = mesh_instance.mesh as CapsuleMesh
	instance.queue_free()
	
	# set material params
	var mm_material = mm.mesh.surface_get_material(0) as ShaderMaterial
	var material = mesh.surface_get_material(0) as ShaderMaterial
	if (mm_material && material):
		mm_material.set_shader_parameter("ondulationSpeed", material.get_shader_parameter("ondulationSpeed"))
		mm_material.set_shader_parameter("nodeWorldPosition", global_position)
	else:
		printerr("Material is not valid! Can't pass ondulation speed uniform")
	
	var height = mm.mesh.height
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = points_count
	var max_radius : float = mesh.radius + max_radius_offset;
	var center_x := 0;
	var center_z := 0;
	
	for i in points_count:
		var angle := float(i) / float(points_count) * 2 * PI
		var y = -height/2
		var x := center_x + cos(angle) * max_radius
		var z := center_z + sin(angle) * max_radius
		var transform = Transform3D()
		transform.origin = Vector3(x,y,z)
		mm.set_instance_transform(i, transform)
	
	mm_instance.multimesh = mm
