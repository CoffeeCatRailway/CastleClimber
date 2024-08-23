class_name StateDoor
extends State

@export var idleState: StateIdle
var isExiting: bool = false

func updatePhysics(_delta: float) -> State:
	if !animSprite.is_playing():
		if isExiting:
			parent.visible = false
			return null
		else:
			return idleState
	
	animSprite.play("door_in" if isExiting else "door_out")
	return null

func setIsExiting(_isExiting: bool) -> StateDoor:
	isExiting = _isExiting
	
	animSprite.flip_h = false
	animSprite.animation = "door_in" if isExiting else "door_out"
	animSprite.frame = 0
	
	parent.velocity = Vector2.ZERO
	
	return self
