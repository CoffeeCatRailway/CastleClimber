## Based on https://www.youtube.com/watch?v=bNdFXooM1MQ
##			https://github.com/theshaggydev/the-shaggy-dev-projects/tree/main/projects/godot-4/advanced-state-machines
class_name StateMachine
extends Node

@export var initialState: State
var currentState: State

func init(parent: CharacterBody2D, animSprite: AnimatedSprite2D, moveComponent: MoveComponent) -> void:
	for child: State in get_children():
		child.parent = parent
		child.animSprite = animSprite
		child.moveComponent = moveComponent
	
	changeState(initialState)

func changeState(newState: State) -> void:
	if currentState:
		currentState.exit()
	
	currentState = newState
	currentState.enter()

func update(delta: float) -> void:
	var newState: State = currentState.update(delta)
	if newState:
		changeState(newState)

func updatePhysics(delta: float) -> void:
	var newState: State = currentState.updatePhysics(delta)
	if newState:
		changeState(newState)
