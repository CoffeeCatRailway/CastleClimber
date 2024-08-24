class_name LevelDoorHandler
extends Node

@export var doorEntrance: Door
@export var doorExit: Door
var canUseDoor: bool = false

@export var player: Player

@export var auto: bool = true

func _ready() -> void:
	if auto:
		#init()
		call_deferred("init")
		call_deferred("enterLevel")

func init() -> void:
	doorExit.area.body_entered.connect(onDoorExitAreaEntered)
	doorExit.area.body_exited.connect(onDoorExitAreaExited)
	
	player.visible = false

func enterLevel() -> void:
	doorEntrance.play("open")
	await doorEntrance.animation_finished
	doorEntrance.play("close")
	player.global_position = doorEntrance.marker.global_position
	player.enterDoorState(false)
	player.visible = true

func exitLevel() -> void:
	player.global_position = doorExit.marker.global_position
	player.enterDoorState(true)
	doorExit.play("open")
	await doorExit.animation_finished
	doorExit.play("close")
	await doorExit.animation_finished
	#player.visible = false
	if doorExit.nextLevel:
		get_tree().change_scene_to_file(doorExit.nextLevel)
	else:
		get_tree().reload_current_scene()

func onDoorExitAreaEntered(body: Node2D) -> void:
	if body == player:
		canUseDoor = true

func onDoorExitAreaExited(body: Node2D) -> void:
	if body == player:
		canUseDoor = false

func _process(_delta: float) -> void:
	if !canUseDoor:
		return
	
	if Input.is_action_just_pressed("interact"):
		canUseDoor = false
		exitLevel()
