extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector3(6, -42, 38)
	look_at(Vector3(0, 0, 25))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
