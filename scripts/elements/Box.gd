extends RigidBody2D

@onready var healthComponent: HealthComponent = $HealthComponent

@onready var pieces: Array[RigidBody2D] = [$Piece1, $Piece2, $Piece3, $Piece4]
const KNOCKBACK_CORRECTION: Vector2 = Vector2(1., -1.)

func _ready() -> void:
	healthComponent.hit.connect(onHit)
	
	for piece: RigidBody2D in pieces:
		piece.visible = false
		piece.disable_mode = CollisionObject2D.DISABLE_MODE_MAKE_STATIC
		piece.process_mode = Node.PROCESS_MODE_DISABLED

func onHit(isDead: bool, knockback: Vector2) -> void:
	Utils.tweenFlash(self)
	
	if isDead:
		$Sprite2D.visible = false
		$CollisionShape2D.call_deferred("set_disabled", true)
		freeze = true
		
		for piece: RigidBody2D in pieces:
			piece.visible = true
			piece.process_mode = Node.PROCESS_MODE_INHERIT
			
			piece.apply_impulse(knockback * KNOCKBACK_CORRECTION * (randf() * .5 + .5))
	else:
		apply_impulse(knockback * KNOCKBACK_CORRECTION * (randf() * .5))
