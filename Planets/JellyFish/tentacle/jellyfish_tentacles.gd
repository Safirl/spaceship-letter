extends MeshInstance3D

@onready var path: Path3D = $Path3D
@onready var mm_instance: MultiMeshInstance3D = $TentatclesMM
@export_file("*.tscn") var tentacle_file

func _ready() -> void:
	build_tentacles()

func _process(delta: float) -> void:
	pass

func get_points() -> PackedVector3Array:
	var curve = path.curve
	return curve.get_baked_points()

func build_tentacles():
	if (!tentacle_file || !mm_instance || !path):
		printerr("Can't build tentacles! One of the required file is not valid.")
		return
	
	var points := get_points();
	
	var mm = MultiMesh.new();
	var file = preload("res://Planets/JellyFish/tentacle/jellyfish_tentacles.gd")
	mm.mesh = file
	mm.instance_count = points.size()
	
	for i in points.size():
		var p = points[i]
		
		var transform = Transform3D()
		transform.origin = p
		mm.set_instance_transform(i, transform)
	
	#mm_instance.multimesh = mm
