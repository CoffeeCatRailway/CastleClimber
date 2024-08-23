class_name MoveComponent
extends Node

@export var speed: float = 150.
@export var jumpForce: float = -300.

func getMoveDirection() -> float:
	return Input.get_axis("move_left", "move_right") * speed

func isJumping(body: CharacterBody2D) -> bool:
	return Input.is_action_pressed("jump") && body.is_on_floor()

#func hasStoppedJumping() -> bool:
	#return Input.is_action_just_released("jump")

func isAttacking() -> bool:
	return Input.is_action_just_pressed("attack")

func isFacingLeft(flipH: bool) -> bool:
	return flipH
