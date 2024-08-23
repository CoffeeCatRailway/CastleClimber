class_name StateAttack
extends State

@export var returnState: State
@export var areaAttack: Area2D

@export var damage: int = 20
@export var defaultKnockback: Vector2 = Vector2(250., 150.)

var bodiesHit: Array[String] = []

func enter() -> void:
	bodiesHit.clear()

func updatePhysics(_delta: float) -> State:
	if !animSprite.is_playing():
		return returnState
	
	animSprite.play("attack")
	parent.velocity.x *= .9
	
	if areaAttack.has_overlapping_bodies():
		for body: Node2D in areaAttack.get_overlapping_bodies():
			if !body.has_node("HealthComponent") || body.name == parent.name || bodiesHit.has(body.name):
				continue
			
			var knockback: Vector2 = defaultKnockback
			knockback.x *= (-1. if moveComponent.isFacingLeft(animSprite.flip_h) else 1.)
			body.get_node("HealthComponent").damage(damage, knockback)
			bodiesHit.append(body.name)
			#if body is CharacterBody2D:
				#body.velocity.x = knockback.x * (-1. if moveComponent.isFacingLeft(animSprite.flip_h) else 1.)
				#body.velocity.y -= knockback.y
			#print("Hit ", body.name, " for ", damage, " damage")
	
	return null

func _return(state: State) -> StateAttack:
	returnState = state
	return self
