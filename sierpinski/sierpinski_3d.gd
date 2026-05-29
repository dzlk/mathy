extends Node3D

var vertices: PackedVector3Array
var points: PackedVector3Array = []

var _max_points = 20000
var _points_per_frame = 50
var _factor = 0.5

var _multimesh: MultiMesh
var _cam: Camera3D

var _angle := 0.0
var _height := 8
var _radius := 10

func _ready() -> void:
	var s = 4.0
	vertices = PackedVector3Array([
		Vector3( 1,  1,  1) * s,
		Vector3(-1, -1,  1) * s,
		Vector3(-1,  1, -1) * s,
		Vector3( 1, -1, -1) * s,
	])

	points.append(Vector3.ZERO)
	
	# Mesh init
	var mat = StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	var sphere = SphereMesh.new()
	sphere.radius = 0.04
	sphere.height = 0.08
	sphere.radial_segments = 4
	sphere.rings = 2
	sphere.material = mat

	_multimesh = MultiMesh.new()
	_multimesh.transform_format = MultiMesh.TRANSFORM_3D
	_multimesh.use_colors = true
	_multimesh.mesh = sphere
	_multimesh.instance_count = _max_points
	_multimesh.visible_instance_count = 0

	var mmi = MultiMeshInstance3D.new()
	mmi.multimesh = _multimesh
	add_child(mmi)
	
	# Camera init
	_cam = Camera3D.new()
	add_child(_cam)
	_update_camera()

func _process(delta: float) -> void:
	_update_camera(delta)

	var iters = min(_max_points - points.size(), _points_per_frame)

	if iters <= 0:
		return

	var curr := points[points.size() - 1]
	for _i in iters:
		curr = curr.lerp(vertices[randi() % vertices.size()], _factor)
		var i = points.size()
		_multimesh.set_instance_transform(i, Transform3D(Basis.IDENTITY, curr))
		var t = (curr.y + 4.0) / 8.0
		_multimesh.set_instance_color(i, Color(t, 0.4, 1.0 - t))
		points.append(curr)

	_multimesh.visible_instance_count = points.size()
	
func _update_camera(delta: float = 0.0) -> void:
	_angle += delta * 0.4
	_cam.position = Vector3(sin(_angle) * _radius, _height, cos(_angle) * _radius)
	_cam.look_at(Vector3.ZERO)
