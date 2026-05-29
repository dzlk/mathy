extends Node2D


var vertices: PackedVector2Array
var points: PackedVector2Array = []

var _radius = 1
var _color = Color.DARK_SALMON
var _points_per_frame = 50
var _max_points = 10000

var _factor = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var size := get_viewport_rect().size
	
	vertices = PackedVector2Array([
		Vector2(size.x / 2, 10),
		Vector2(30, size.y - 10),
		Vector2(size.x - 40, size.y - 10),
	])
	
	var start := size / 2
	start.y -= 50
	points.append(start)
	
	pass # Replace with function body.
	
func _draw() -> void:
	_draw_points(vertices)
	_draw_points(points)

func _draw_points(pts: PackedVector2Array) -> void:
	for p in pts:
		draw_circle(p, _radius, _color)

func _process(_delta: float) -> void:
	var ok := _gen_points()
	if ok:
		queue_redraw()
	
func _gen_points() -> bool:
	var iters = min(_max_points - points.size(), _points_per_frame)
	
	var curr := points[points.size() - 1] 
	for _i in iters:
		var dir := _get_direction()
		
		curr = curr.lerp(dir, _factor)
		points.append(curr)
		
	return iters > 0
		
func _get_direction() -> Vector2:
	return vertices[randi() % vertices.size()]
