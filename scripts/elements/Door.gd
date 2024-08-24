class_name Door
extends AnimatedSprite2D

@export_file("*.tscn") var nextLevel: String
@onready var area: Area2D = $Area2D
@onready var marker: Marker2D = $Marker2D

func _ready() -> void:
	animation_finished.connect(onAnimationFinished)

func onAnimationFinished() -> void:
	if animation == "close":
		play("default")
