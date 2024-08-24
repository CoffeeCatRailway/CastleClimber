extends Camera2D

@export var limits: ReferenceRect
@export var tilemap: TileMap

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
