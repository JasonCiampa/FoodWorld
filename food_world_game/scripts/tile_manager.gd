extends Node2D

class_name TileManager

# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------






# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


enum TileLayers { PITS, WATER, GROUND, ENVIRONMENT, SKY }


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var tilemap_pits: TileMapLayer
var tilemap_water: TileMapLayer
var tilemap_ground: TileMapLayer
var tilemap_environment: TileMapLayer
var tilemap_terrain: TileMapLayer
var tilemap_sky: TileMapLayer


var tile_callbacks : Dictionary = {
	
	
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



# Called every frame. Updates the Enemy's physics
func _physics_process(delta: float) -> void:
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------






# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Immediately unloads the Tile from memory
func unload_tile(tile: Tile):
	tile.free()
	tile = null




# Process the Tile's designated callback function based on its type
func execute_tile_callback(tile: Tile, character: Character):
	
	# Set the Tile's type in the Tile's custom data variable
	if tile.get_custom_data("tile_type"):
		
		# Determine if the Tile's custom data (tile type) has a designated callback function to execute, then execute it
		if tile.custom_data in tile_callbacks.keys():
			
			# Call the callback function for this tile and pass in the Tilemap, the coordinates of the Tile that the Character is standing on in Local Coordinates, and the Character
			tile_callbacks[tile.custom_data].call(tile, character)



# Process the tiles nearby a given Character on the given Tilemap
func process_nearby_tiles(tilemap: TileMapLayer, character: Character, tiles_out: int):
	
	# Store the coordinates of the Tiles that the Character is currently standing on and was previously standing on in Map Coordinates
	character.previous_tile_position = character.current_tile_position
	character.current_tile_position = tilemap.local_to_map(character.bottom_point)
	
	# Create a list of Tile coordinates to process starting with the tile that the Character is currently standing on
	var tiles_to_process: Array[Tile] = [Tile.new(tilemap, character.current_tile_position)]

	var x = character.current_tile_position.x
	var y = character.current_tile_position.y
	
	 #Iterate tiles_out number of times so that the coordinates for all of the Tiles are added to be processed 
	#(tiles_out represents how many tiles away from the Character on each side should be processed)
	for count in range(1, tiles_out + 1):
		
		# Retrieve the coordinates for the Tiles above, below, left, and right of the Character's current tile
		tiles_to_process.append(Tile.new(tilemap, Vector2i(x + count, y)))
		tiles_to_process.append(Tile.new(tilemap, Vector2i(x - count, y)))
		tiles_to_process.append(Tile.new(tilemap, Vector2i(x, y + count)))
		tiles_to_process.append(Tile.new(tilemap, Vector2i(x, y - count)))
		
		# Retrieve the coordinates for the tiles diagonally above the Character's current tile
		tiles_to_process.append(Tile.new(tilemap, Vector2i(x - count, y - count)))
		tiles_to_process.append(Tile.new(tilemap, Vector2i(x + count, y - count)))
		
		# Retrieve the coordinates for the tiles diagonally below the Character's current tile
		tiles_to_process.append(Tile.new(tilemap, Vector2i(x - count, y + count)))
		tiles_to_process.append(Tile.new(tilemap, Vector2i(x + count, y + count)))
		
		# Retrieve the coordinates for any remaining Tiles within range of the Character's current Tile (the range is determined by tiles_out)
		for number in range(1, count):
			tiles_to_process.append(Tile.new(tilemap, Vector2i(x - count, y - count + number)))
			tiles_to_process.append(Tile.new(tilemap, Vector2i(x + count, y - count + number)))
			tiles_to_process.append(Tile.new(tilemap, Vector2i(x - count + number, y - count)))
			tiles_to_process.append(Tile.new(tilemap, Vector2i(x + count - number, y - count)))
			
			tiles_to_process.append(Tile.new(tilemap, Vector2i(x - count, y + count - number)))
			tiles_to_process.append(Tile.new(tilemap, Vector2i(x + count, y + count - number)))
			tiles_to_process.append(Tile.new(tilemap, Vector2i(x - count + number, y + count)))
			tiles_to_process.append(Tile.new(tilemap, Vector2i(x + count - number, y + count)))
	
	## Process each of the Tiles using the coordinates from the list
	for tile in range(tiles_to_process.size() - 1, -1, -1):
		execute_tile_callback(tiles_to_process[tile], character)
		tiles_to_process[tile].free()
		tiles_to_process[tile] = null		

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# ABSTRACT FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# A custom ready function that each Enemy subclass should personally define. This is called in the default Enemy class's '_ready()' function
func ready():
	pass



# A custom process function that each Enemy subclass should personally define. This is called in the default Enemy class's '_process()' function
func process(delta: float):
	pass



# A custom physics_process function that each Enemy subclass should personally define. This is called in the default Enemy class's '_physics_process()' function
func physics_process(delta: float) -> void:
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
