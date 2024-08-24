extends Camera2D

@export var limits: ReferenceRect
@export var tilemap: TileMap

@export var target: Node2D
var followTarget: bool = true
@export_range(1., 100.) var scrollSpeed: float = 20.

func _ready() -> void:
	updateLimits()

func updateLimits() -> void:
	#position_smoothing_enabled = false
	if limits:
		limit_left = int(limits.position.x)
		limit_top = int(limits.position.y)
		limit_right = int(limits.position.x + limits.size.x)
		limit_bottom = int(limits.position.y + limits.size.y)
	elif tilemap:
		var tilemapRect: Rect2i = tilemap.get_used_rect()
		tilemapRect.position += Vector2i.ONE
		tilemapRect.size -= Vector2i.ONE * 2
		limit_left = tilemapRect.position.x * tilemap.tile_set.tile_size.x
		limit_top = tilemapRect.position.y * tilemap.tile_set.tile_size.y
		limit_right = tilemapRect.end.x * tilemap.tile_set.tile_size.x
		limit_bottom = tilemapRect.end.y * tilemap.tile_set.tile_size.y
	#position_smoothing_enabled = true

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("camera_mode_toggle"):
		followTarget = !followTarget
		print("Toggled camera mode")
	
	if followTarget:
		global_position = target.global_position

func _input(event: InputEvent) -> void:
	if followTarget:
		return
	
	if event is InputEventMouseButton && event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			global_position.y -= scrollSpeed
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			global_position.y += scrollSpeed
		
		global_position.y = clampf(global_position.y, limit_top, limit_bottom)
		
		#print(global_position.y)
