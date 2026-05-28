extends MeshInstance3D

@export var labelX: Label3D
@export var labelY: Label3D
@export var labelZ: Label3D

var _material: StandardMaterial3D
var _axes_len = 30

var points_per_frame = 5
var max_points = 8000
var dt = 0.01

var colors: Array[Color] = [Color.BURLYWOOD, Color.CORAL, Color.DARK_GREEN, Color.LIGHT_BLUE]
var group_points: Array[PackedVector3Array] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_material= StandardMaterial3D.new()
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_material.vertex_color_use_as_albedo = true
	
	_setup_labels()

	_draw_axes()
	
	var e = 0.001
	group_points.append_array([
		PackedVector3Array([Vector3(0.1, 0.0, 0.0)]),
		PackedVector3Array([Vector3(0.1 + e, 0.0, 0.0)]),
		PackedVector3Array([Vector3(0.1, e, 0.0)]),
		PackedVector3Array([Vector3(0.1, 0.0, e)]),
	])

func _setup_labels() -> void:
	for label: Label3D in [labelX, labelY, labelZ]:
		label.font_size = 256
		label.pixel_size = 0.01
		label.outline_size = 0
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.modulate = Color.CADET_BLUE
		label.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS

	labelX.global_position = Vector3(_axes_len, 4, 0)
	labelY.global_position = Vector3(4, _axes_len, 0)
	labelZ.global_position = Vector3(0, 4, 55)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_ode_solution_points()
	_redraw()

func _redraw() -> void:
	mesh.clear_surfaces()
	
	_draw_axes()
	for i in group_points.size():
		_draw_points(group_points[i], colors[i % colors.size()])
	

func _draw_axes():
	mesh.surface_begin(Mesh.PRIMITIVE_LINES, _material)
	
	mesh.surface_set_color(Color.AQUAMARINE)
	
	# Draw X
	mesh.surface_add_vertex(Vector3(-_axes_len, 0, 0))
	mesh.surface_add_vertex(Vector3(_axes_len, 0, 0))
	
	# Draw Y
	mesh.surface_add_vertex(Vector3(0, -0, 0))
	mesh.surface_add_vertex(Vector3(0, _axes_len, 0))
	
	# Draw Z
	mesh.surface_add_vertex(Vector3(0, 0, -5))
	mesh.surface_add_vertex(Vector3(0, 0, 55))
	
	mesh.surface_end()


func _draw_points(pts: PackedVector3Array, color: Color = Color.BURLYWOOD) -> void:
	if pts.size() < 2:
		return
	mesh.surface_begin(Mesh.PRIMITIVE_LINES, _material)
	mesh.surface_set_color(color)
	for i in pts.size() - 1:
		mesh.surface_add_vertex(pts[i])
		mesh.surface_add_vertex(pts[i + 1])
	mesh.surface_end()


func _ode_solution_points() -> void:
	for i in group_points.size():
		var points := group_points[i]
		
		var state := points[points.size() - 1]
		var count: int = min(max_points - points.size(), points_per_frame)
		for _i in count:
			state = _lorenz_system(state)
			points.append(state)
			
		group_points[i] = points
	
func _lorenz_system(state: Vector3, sigma: float = 10.0, rho: float = 28.0, beta: float = 8.0/3.0) -> Vector3:
	var dx = sigma * (state.y - state.x)
	var dy = state.x * (rho - state.z) - state.y
	var dz = state.x * state.y - beta * state.z
	return state + Vector3(dx, dy, dz) * dt
