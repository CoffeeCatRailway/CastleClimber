class_name PigMoveComponent
extends MoveComponent

@export var areaAttack: Area2D

@export var rayGround: RayCast2D
@export var rayForward: RayCast2D

@export var timerWait: Timer

var currentSpeed: float

func _ready() -> void:
	currentSpeed = speed * signf(randf() * 2. - 1.)

func getMoveDirection() -> float:
	if !timerWait.is_stopped():
		return 0.
	
	if !rayGround.is_colliding() || rayForward.is_colliding():
		currentSpeed *= -1.
		timerWait.start()
	
	return currentSpeed

func isJumping(_body: CharacterBody2D) -> bool:
	return false

func isAttacking() -> bool:
	if areaAttack.has_overlapping_bodies():
		for body: Node2D in areaAttack.get_overlapping_bodies():
			if !body.has_node("HealthComponent") || body.name == get_parent().name:# || bodiesHit.has(body.name):
				continue
			return true
	return false

func isFacingLeft(flipH: bool) -> bool:
	return !flipH
