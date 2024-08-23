class_name StateIdle
extends State

@export var walkState: StateWalk
@export var deathState: StateDeath
@export var jumpState: StateJump
@export var attackState: StateAttack

@export var healthComponent: HealthComponent

#func enter() -> void:
	#if parent.is_on_floor():
		#animSprite.play("default")
	#parent.velocity = Vector2.ZERO

func update(_delta: float) -> State:
	if parent.is_on_floor():
		animSprite.play("default")
	
	if healthComponent.health <= 0:# || Input.is_action_just_pressed("ui_end"):
		return deathState
	
	if moveComponent.getMoveDirection() != 0.:#Utils.isMoveKeyPressed():
		return walkState
	
	if moveComponent.isJumping(parent):
		return jumpState._return(self)
	
	if moveComponent.isAttacking():
		return attackState._return(self)
	
	parent.velocity.x *= .9
	return null
