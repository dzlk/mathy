extends Node2D

# Папоротник Барнсли — фрактал, заданный четырьмя аффинными преобразованиями.
# Каждый кадр добавляем iters_per_frame новых точек, пока не наберём max_iters.

var max_iters := 10000
var iters_per_frame := 500

var points := PackedVector2Array()

func _ready() -> void:
	points.append(Vector2.ZERO)

# Переводит математические координаты фрактала (x: ±2.5, y: 0..10)
# в пиксели экрана. Y инвертирован, потому что в Godot ось Y направлена вниз.
func _to_screen(p: Vector2) -> Vector2:
	var size := get_viewport_rect().size
	@warning_ignore("shadowed_variable_base_class")
	var scale := size.y / 12.0
	return Vector2(size.x / 2.0 + p.x * scale, size.y - p.y * scale)

func _draw() -> void:
	for p in points:
		draw_circle(_to_screen(p), 1, Color.SEA_GREEN)

func _process(_delta: float) -> void:
	var iters = min(iters_per_frame, max_iters - points.size())

	var curr := points[points.size() - 1]
	for _i in iters:
		# Случайно выбираем одно из четырёх преобразований с заданными вероятностями
		var r := randf()

		if r < 0.01:
			# 1% — стебель: сжимает точку к оси X (рисует основание)
			curr = Vector2(0.0, 0.16 * curr.y)
		elif r < 0.86:
			# 85% — основные листья: слегка скручивает и поднимает точку вверх
			curr = Vector2(
				0.85 * curr.x + 0.04 * curr.y,
				-0.04 * curr.x + 0.85 * curr.y + 1.6,
			)
		elif r < 0.93:
			# 7% — левые листья
			curr = Vector2(
				0.2 * curr.x - 0.26 * curr.y,
				0.23 * curr.x + 0.22 * curr.y + 1.6,
			)
		else:
			# 7% — правые листья
			curr = Vector2(
				-0.15 * curr.x + 0.28 * curr.y,
				0.26 * curr.x + 0.24 * curr.y + 0.44,
			)

		points.append(curr)

	if iters > 0:
		queue_redraw()
