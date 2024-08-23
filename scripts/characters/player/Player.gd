class_name Player
extends CharacterBody2D

@onready var healthComponent: HealthComponent = $HealthComponent

@onready var moveStateMachine: StateMachine = $MoveStateMachine

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var collisionAttack: CollisionShape2D = $AreaAttack/CollisionShape2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const ANIMATIONS_NO_SKIP: Array[String] = ["attack", "death"]

func _ready() -> void:
	moveStateMachine.init(self, sprite, $MoveComponent)
	
	healthComponent.hit.connect(onHit)

func _process(delta: float) -> void:
	moveStateMachine.update(delta)
	
	#if Input.is_action_just_pressed("ui_end"):
		#Utils.tweenFlash(self)

func _physics_process(delta: float) -> void:
	if !is_on_floor(): # Do before state machine so jumps can effect velocity
		velocity.y += Constants.GRAVITY * delta
	
	moveStateMachine.updatePhysics(delta)
	
	collision.position.x = 7.5 if sprite.flip_h else -7.5
	collisionAttack.position.x = -17. if sprite.flip_h else 17.
	
	if !is_on_floor() && !ANIMATIONS_NO_SKIP.has(sprite.animation): # Do after statemachine so it isn't overrided, checking if not attack animation feels hacky
		sprite.play("jump" if velocity.y < 0. else "fall")
	
	# Call `move_and_slide` after state machine once velocity is set/updated
	move_and_slide()

func enterDoorState(exit: bool) -> void:
	moveStateMachine.changeState($MoveStateMachine/StateDoor.setIsExiting(exit))

func onHit(_isDead: bool, knockback: Vector2) -> void:
	Utils.tweenFlash(self)
	
	velocity.x = knockback.x
	velocity.y -= knockback.y
