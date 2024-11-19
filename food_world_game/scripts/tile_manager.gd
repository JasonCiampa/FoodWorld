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
	#"ledge" : tile_callback_ledge,
	#"ledge_grass" : tile_callback_ledge_grass,
	#"grass" : tile_callback_grass,
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




#
# A callback function to be played when a Ledge Tile is being processed
func tile_callback_ledge(tile: Tile, character: Character):
	
	if character.on_platform:
		character.z_index = tile.data.z_index + 1
		
	if character.is_jumping:
		character.z_index = 10
		return
	
	# Determine if the Character is horizontally in range of the Tile
	if tile.coords_local.x - 16 <= character.position.x and character.position.x <= tile.coords_local.x + 16:
		
		# Determine if the Character is above the Tile
		if character.bottom_point.y < tile.coords_local.y:
			
			# Set the Character's z-index to be 2 less than than the Tile's so that the Character appears as if they are behind the Tile
			character.z_index = tile.data.z_index - 2
			
		# Otherwise, the Character is below the Tile
		else:
			character.z_index = 1
#
#
#
## A callback function to be played when a Ledge-Grass Tile is being processed
#func tile_callback_ledge_grass(tile: Tile, character: Character):
	#
	## Determine if the Character's bottom-point.y local coords are in this Tile's map coords, then land the Character on this 
	#if character.is_falling and tile.tilemap.local_to_map(character.bottom_point) == tile.coords_map:
		#character.on_platform = true
		#character.fall_end()
#
#
#
# A callback function to be played when a Grass Tile is being processed
func tile_callback_grass(tile: Tile, character: Character):
	
	# Determine if the Character's bottom-point.y local coords are in this Tile's map coords, then land the Character on this 
	if character.is_falling and tile.tilemap.local_to_map(character.bottom_point) == tile.coords_map:
		character.on_platform = true
		character.fall_end()
	
	var terrain_tile = tile.get_same_cell(tilemap_terrain)
	
	# Check if the the Tile that is in the samdwe cell coordinates as this Tile but in the terrain tile map is a 'ledge' tile
	if terrain_tile.get_custom_data("tile_type") == "ledge":
		
		# Set this current grass tile to be a ledge_grass tile because the tile on the terrain map is a ledge
		tilemap_ground.set_cell(tile.coords_map, 0, tilemap_ground.get_cell_atlas_coords(tile.coords_map), 1)
		
	
	unload_tile(terrain_tile)


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
