class_name StateDeath
extends State

func enter() -> void:
	parent.velocity.x = 0.

func update(_delta: float) -> State:
	if animSprite.animation != "death":
		animSprite.play("death")
	return null
