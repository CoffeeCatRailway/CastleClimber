extends Node

func isMoveKeyPressed() -> bool:
	return Input.is_action_pressed("move_left") || Input.is_action_pressed("move_right")

func tweenFlash(node: Node, time: float = .05, color: Color = Color.from_hsv(0., 0., 10.)) -> void:
	var tween: Tween = node.create_tween()
	var originalModulate: Color = node.modulate
	tween.tween_property(node, "modulate", color, time)
	tween.tween_property(node, "modulate", originalModulate, time)
	await tween.finished
	tween.kill()
