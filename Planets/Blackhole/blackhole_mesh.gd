@tool
extends MeshInstance3D

func _process(_delta):
	_update_shader_center()

func _update_shader_center():
	var camera: Camera3D
	var screen_size: Vector2
	
	if Engine.is_editor_hint():
		camera = EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
		screen_size = EditorInterface.get_editor_viewport_3d(0).get_visible_rect().size
	else:
		camera = get_viewport().get_camera_3d()
		screen_size = get_viewport().get_visible_rect().size
	
	if camera == null:
		return
	
	look_at(camera.global_position)
	var screen_pos := camera.unproject_position(global_position)
	if (!mesh.surface_get_material(0)):
		return;
	mesh.surface_get_material(0).set_shader_parameter("object_screen_uv", screen_pos / screen_size)
	#mesh.surface_get_material(0).set_shader_parameter("object_screen_pos", screen_pos)
