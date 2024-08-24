extends Node2D

const FLAG_PASSAGE_LEFT: int = 0b100
const FLAG_PASSAGE_MIDDLE: int = 0b010
const FLAG_PASSAGE_RIGHT: int = 0b001

var floorsEnd: Dictionary = {
	FLAG_PASSAGE_RIGHT: "res://scenes/levels/floors/end/floor_end_right.tscn"
}
var floorsMid: Dictionary = {
	getMiddleFloorKey(FLAG_PASSAGE_RIGHT, FLAG_PASSAGE_RIGHT): "res://scenes/levels/floors/mid/floor_mid_right_right.tscn"
}
var floorsStart: Dictionary = {
	FLAG_PASSAGE_RIGHT: "res://scenes/levels/floors/start/floor_start_right.tscn"
}

@onready var levelDoorHandler: LevelDoorHandler = $LevelDoorHandler
@onready var tilemapMain: TileMap = $TileMap

@export_range(2, 100, 1, "or_greater") var floors: int = 2

var doorEntrance: Door
var doorExit: Door

func _ready() -> void:
	call_deferred("generateCastle")

func generateCastle() -> void:
	var time: int = Time.get_ticks_usec()
	#await get_tree().create_timer(1.).timeout
	
	var y: int = 0
	y = placeFloor(floorsEnd, FLAG_PASSAGE_RIGHT, y)
	y = placeFloor(floorsMid, getMiddleFloorKey(FLAG_PASSAGE_RIGHT, FLAG_PASSAGE_RIGHT), y)
	#y = placeFloor(floorsMid, getMiddleFloorKey(FLAG_PASSAGE_RIGHT, FLAG_PASSAGE_RIGHT), y)
	y = placeFloor(floorsStart, FLAG_PASSAGE_RIGHT, y)
	
	print("Castle generation took %s milliseconds" % [float(Time.get_ticks_usec() - time) / 1000.])
	
	$Player.global_position = doorEntrance.marker.global_position
	$Player/Camera2D.updateLimits()
	
	levelDoorHandler.doorEntrance = doorEntrance
	levelDoorHandler.doorExit = doorExit
	levelDoorHandler.init()
	levelDoorHandler.enterLevel()

func placeFloor(floorDict: Dictionary, passages: int, y: int) -> int:
	var floorScene: Node2D = load(floorDict[passages]).instantiate()
	var floorMap: TileMap = floorScene.get_node("TileMap") as TileMap
	
	# Copy floor tiles to main tilemap
	var tileOffset: Vector2i = Vector2i(0, y)
	var terrains: Array[Array] = []
	for i: int in tilemapMain.tile_set.get_terrains_count(0):
		terrains.append([])
	
	for tilePos: Vector2i in floorMap.get_used_cells(0):
		var terrain: int = floorMap.get_cell_tile_data(0, tilePos).terrain
		
		#if terrains.size() < terrain + 1:
			#terrains.append([])
		terrains[terrain].append(tilePos + tileOffset)
		
		#tilemapMain.set_cell(0, tilePos + tileOffset, floorMap.get_cell_source_id(0, tilePos), floorMap.get_cell_atlas_coords(0, tilePos)) ## 72.711 milliseconds - has borders between floors
		#tilemapMain.set_cells_terrain_connect(0, [tilePos + tileOffset], 0, terrain) ## 241.209 milliseconds
	
	for terrain: int in terrains.size():
		tilemapMain.set_cells_terrain_connect(0, terrains[terrain], 0, terrain) ## 113.842 milliseconds
	
	# Get room height
	var isMiddle: bool = (passages >> 3) & FLAG_PASSAGE_LEFT || (passages >> 3) & FLAG_PASSAGE_MIDDLE || (passages >> 3) & FLAG_PASSAGE_RIGHT
	#print(isMiddle)
	var height: int = floorMap.get_used_rect().size.y - (0 if isMiddle else 1)
	#print(floorMap.get_used_rect().size)
	
	# Clear floor tilemap & add floor to scene
	floorMap.clear_layer(0)
	add_child(floorScene)
	floorScene.position.y += y * tilemapMain.tile_set.tile_size.y
	
	# Find doors
	if floorScene.has_node("DoorEntrance"):
		doorEntrance = floorScene.get_node("DoorEntrance")
	if floorScene.has_node("DoorExit"):
		doorExit = floorScene.get_node("DoorExit")
	
	return height + y

func _process(_delta: float) -> void:
	pass

func getMiddleFloorKey(passageBottom: int, passageTop: int) -> int:
	return ((passageBottom) << 3) | passageTop
