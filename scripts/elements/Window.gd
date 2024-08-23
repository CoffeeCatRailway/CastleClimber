extends Sprite2D

func _ready() -> void:
	(material as ShaderMaterial).set_shader_parameter("scrollStart", randf())
