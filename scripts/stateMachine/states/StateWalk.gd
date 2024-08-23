class_name StateWalk
extends State

@export var idleState: StateIdle
@export var deathState: StateDeath
@export var jumpState: StateJump
@export var attackState: StateAttack

@export var healthComponent: HealthComponent

@export var flipH: bool = false

func update(_delta: float) -> State:
	if healthComponent.health <= 0:
		return deathState
	return null

func updatePhysics(_delta: float) -> State:
	if parent.is_on_floor():
		animSprite.play("run")
	
	if healthComponent.health <= 0:
		return deathState
	
	if moveComponent.isJumping(parent):
		return jumpState._return(self)
	
	if moveComponent.isAttacking():
		return attackState._return(self)
	
	parent.velocity.x = moveComponent.getMoveDirection()
	
	if parent.velocity.x == 0.:
		return idleState
	
	animSprite.flip_h = parent.velocity.x < 0.
	if flipH:
		animSprite.flip_h = !animSprite.flip_h
	
	return null
