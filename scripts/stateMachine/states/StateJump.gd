class_name StateJump
extends State

@export var returnState: State

func updatePhysics(_delta: float) -> State:
	if parent.is_on_floor():
		parent.velocity.y = moveComponent.jumpForce
	#if moveComponent.hasStoppedJumping() && parent.velocity.y < 0.:
		#parent.velocity.y *= .4
	
	return returnState

func _return(state: State) -> StateJump:
	returnState = state
	return self
