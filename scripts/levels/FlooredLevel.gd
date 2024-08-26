extends Node2D

const FLAG_PASSAGE_LEFT: int = 0b100
const FLAG_PASSAGE_MIDDLE: int = 0b010
const FLAG_PASSAGE_RIGHT: int = 0b001

const FLOORS_END: Dictionary = {
	FLAG_PASSAGE_RIGHT: "res://scenes/levels/floors/end/floor_end_right.tscn",
	FLAG_PASSAGE_LEFT: "res://scenes/levels/floors/end/floor_end_left.tscn",
}
var FLOORS_MID: Dictionary = {
	getMiddleFloorKey(FLAG_PASSAGE_RIGHT, FLAG_PASSAGE_RIGHT): "res://scenes/levels/floors/mid/floor_mid_right_right.tscn",
	getMiddleFloorKey(FLAG_PASSAGE_LEFT, FLAG_PASSAGE_RIGHT): "res://scenes/levels/floors/mid/floor_mid_left_right.tscn",
	getMiddleFloorKey(FLAG_PASSAGE_RIGHT, FLAG_PASSAGE_LEFT): "res://scenes/levels/floors/mid/floor_mid_right_left.tscn",
	getMiddleFloorKey(FLAG_PASSAGE_LEFT, FLAG_PASSAGE_LEFT): "res://scenes/levels/floors/mid/floor_mid_left_left.tscn",
	getMiddleFloorKey(FLAG_PASSAGE_LEFT | FLAG_PASSAGE_RIGHT, FLAG_PASSAGE_LEFT | FLAG_PASSAGE_RIGHT): "res://scenes/levels/floors/mid/floor_mid_left_right_left_right.tscn",
}
const FLOORS_START: Dictionary = {
	FLAG_PASSAGE_RIGHT: "res://scenes/levels/floors/start/floor_start_right.tscn",
	FLAG_PASSAGE_LEFT | FLAG_PASSAGE_RIGHT: "res://scenes/levels/floors/start/floor_start_left_right.tscn",
}

@onready var levelDoorHandler: LevelDoorHandler = $LevelDoorHandler
@onready var tilemapMain: TileMap = $TileMap

@export_range(2, 100, 1, "or_greater") var floorCount: int = 2

var doorEntrance: Door
var doorExit: Door

func _ready() -> void:
	call_deferred("generateCastle")

func padBinary(decimal: int, pad: int) -> String:
	return String.num_int64(decimal, 2).pad_zeros(pad)

func generateCastle() -> void:
	var time: int = Time.get_ticks_usec()
	#await get_tree().create_timer(1.).timeout
	
	# Chose floor keys
	#var endKey: int = FLOORS_END.keys().pick_random()
	#print("Chose key '", padBinary(endKey, 3), "' for top floor")
	#
	#var middleKeys: Array[int] = []
	#if floorCount > 2:
		#middleKeys.resize(floorCount - 2)
		#var lastKey: int = endKey
		#var i: int = floorCount - 2
		#
		#var trys: int = 0
		#var maxTrys: int = 10
		#
		#var skipKey: int = -1
		#while i > 0:# && trys < maxTrys:
			#var floors: Array = FLOORS_MID.keys()
			#if skipKey != -1:
				#floors.erase(skipKey)
				#print("Skipping key '", padBinary(skipKey, 6), "'")
				#skipKey = -1
			#
			#var key: int = floors.pick_random()
			#var top: int = key & 0b000111
			#
			##print("f", (i + 1), "-", padBinary(lastKey, 3), " & f", i, "-", padBinary(top, 3), " = ", padBinary(lastKey & top, 3))
			#if lastKey & top != 0:
				#middleKeys[i - 1] = key
				##middleKeys.append(key)
				#print("Chose key '", padBinary(key, 6), "' for f", i)
				#i -= 1
				#lastKey = key >> 3 # Last key is 'bottom passages' of floor
				#trys = 0
			#else:
				#trys += 1
			#
			#if trys >= maxTrys: ## Failed because 'lastKey' before 'i+1' is unknown
				#i = clampi(i + 1, 0, middleKeys.size() - 1)
				#lastKey = middleKeys[clampi(i + 1, 0, middleKeys.size() - 1)] >> 3
				#skipKey = key
				#print("Retrying f", i, " after not finding possible key (", padBinary(key, 6), ") for f", (i - 1), " after ", trys, " trys...")
				#trys = 0
		##if trys >= maxTrys:
			##printerr("Coundn't find floor to place after `", padBinary(middleKeys[-1], 6), "' in ", trys, " trys!")
	#
	#var startKey: int = FLAG_PASSAGE_RIGHT#FLOORS_START.keys().pick_random()
	#
	#for key: int in middleKeys:
		#print(padBinary(key, 6))
	
	# Method: Filter keys by passages
	var endKey: int = FLOORS_END.keys().pick_random()
	print("Chose key '", padBinary(endKey, 3), "' for f", (floorCount - 1))
	
	var middleKeys: Array[int] = []
	middleKeys.resize(floorCount - 2)
	var startKey: int
	
	var i: int = floorCount - 2 # Start at second from top
	var lastKey: int = endKey << 3
	
	var skipKey: int = -1
	
	while i >= 0:
		var isBottomFloor: bool = i == 0
		var lastKeyBottom: int = lastKey >> 3
		
		print("\nFiltering possible floor (f", i, ") for last '", padBinary(lastKeyBottom, 3), "'")
		var possibleKeys: Array = (FLOORS_START if isBottomFloor else FLOORS_MID).keys().filter(func(_key: int) -> bool: return (_key & 0b000111) & lastKeyBottom != 0)
		#print(possibleKeys.map(func(a): return padBinary(a, 6)))
		
		if skipKey != -1:
			#print(possibleKeys.map(func(_key: int) -> String: return padBinary(_key, 6)))
			possibleKeys.erase(skipKey)
			print("Skipping key '", padBinary(skipKey, 6), "'")
			if possibleKeys.size() == 0:
				printerr("0 possible keys!")
				get_tree().quit(-1)
				return
			skipKey = -1
		
		if possibleKeys.size() == 0:
			printerr("No possible floor for f", i, " last key: ", padBinary(lastKey, 6))
			#print(middleKeys.map(func(_key: int) -> String: return padBinary(_key, 6)))
			#return
			
			i = clampi(i + 1, 0, floorCount - 2) # Move up floor
			skipKey = lastKey
			var lastI: int = clampi(i + 1, 0, floorCount - 2) # Get key above floor i
			print("Retrying f", i, " & skipping last key. Index ", lastI)
			lastKey = (endKey << 3) if lastI >= middleKeys.size() else middleKeys[lastI]
			continue
			
			#print("Retrying f", i, " after not finding possible key (", padBinary(key, 6), ") for f", (i - 1), " after ", trys, " trys...")
			#skipKey = lastKey
			#i = clampi(i + 1, 0, floorCount - 2) # Move up floor
			#print("Retrying f", i, ". No possible floor for f", (i - 1), " key: ", padBinary(skipKey, 6))
			#lastKey = middleKeys[clampi(i + 1, 0, floorCount - 2)] # Get key above floor i
			#continue
		
		var key: int = possibleKeys.pick_random()
		if isBottomFloor:
			startKey = key
		else:
			#middleKeys.append(key)
			middleKeys[i - 1] = key
		print("Chose key '", padBinary(key, (3 if isBottomFloor else 6)), "' for f", i)
		i -= 1
		lastKey = key# >> (0 if isBottomFloor else 3)
	
	# Place floors
	var y: int = 0
	#y = placeFloor(FLOORS_END, FLAG_PASSAGE_RIGHT, y)
	#y = placeFloor(FLOORS_MID, getMiddleFloorKey(FLAG_PASSAGE_RIGHT, FLAG_PASSAGE_RIGHT), y)
	#y = placeFloor(FLOORS_START, FLAG_PASSAGE_RIGHT, y)
	#y = placeFloor(FLOORS_MID, getMiddleFloorKey(FLAG_PASSAGE_LEFT, FLAG_PASSAGE_RIGHT), y)
	#y = placeFloor(FLOORS_START, FLAG_PASSAGE_LEFT | FLAG_PASSAGE_RIGHT, y)
	
	y = placeFloor(FLOORS_END, endKey, y)
	if floorCount > 2:
		for j: int in range(floorCount - 3, -1, -1): # Iterate backwards
			y = placeFloor(FLOORS_MID, middleKeys[j], y)
		#for key: int in middleKeys:
			#y = placeFloor(FLOORS_MID, key, y)
	y = placeFloor(FLOORS_START, startKey, y)
	
	print("Castle generation took %s milliseconds" % [float(Time.get_ticks_usec() - time) / 1000.])
	
	$Player.global_position = doorEntrance.marker.global_position
	$Camera2D.updateLimits()
	
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
