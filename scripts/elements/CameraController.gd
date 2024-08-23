extends Camera2D

@export var limits: ReferenceRect

func _ready() -> void:
	limit_left = int(limits.position.x)
	limit_top = int(limits.position.y)
	limit_right = int(limits.position.x + limits.size.x)
	limit_bottom = int(limits.position.y + limits.size.y)
