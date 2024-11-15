extends Node2D


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
	
	"ledge" : tile_callback_ledge,
	"grass" : tile_callback_grass
	
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


# A variable that stores a callback function to be played when a Ledge Tile is being processed
func tile_callback_ledge(tile: Tile, character: Character):
	
	# Determine if this Tile has data and custom data for a type definition of 'ledge' or 'ledge_grass', then return
	if tile.data:
		if tile.data.get_custom_data("tile_type") == "ledge" or tile.data.get_custom_data("tile_type") == "ledge_grass":
			return
		
	# Determine if the Character is jumping
	if character.is_jumping:
		
		if character.bottom_point.y <= tile.coords_local.y + 16:
			character.z_index = tile.data.z_index + 1
		
		return
	
	# Determine if the Character is horizontally in range of the Tile
	if tile.coords_local.x - 16 <= character.position.x and character.position.x <= tile.coords_local.x + 16:
		
		# Determine if the Character is above the Tile
		if character.position.y < tile.coords_local.y:
			
			# Set the Character's z-index to be 2 less than than the Tile's so that the Character appears as if they are behind the Tile
			character.z_index = tile.data.z_index - 2
			
		# Otherwise, the Character is below the Tile
		else:
			character.z_index = 1



# A variable that stores a callback function to be played when a Ledge Tile is being processed
func tile_callback_grass(tile: Tile, character: Character):
	
	var terrain_tile = tile.get_same_cell(tilemap_terrain)
		
	if terrain_tile.get_custom_data("tile_type"):
		
		# Determine if the Tile at the same coordinates as this Tile on the terrain map is a ledge, then set this grass Tile to be ledge_grass
		if terrain_tile.custom_data == "ledge":
			
			# Set this current grass tile to be a ledge_grass tile because the tile on the terrain map is a ledge
			tilemap_ground.set_cell(tile.coords_map, 0, tilemap_ground.get_cell_atlas_coords(tile.coords_map), 1)



# Process the Tile's designated callback function based on its type
func execute_tile_callback(tile: Tile, character: Character):
	
	# Determine if the Tile's custom data (tile type) has a designated callback function to execute, then execute it
	if tile.get_custom_data("tile_type") in tile_callbacks.keys():
		
		# Call the callback function for this tile and pass in the Tilemap, the coordinates of the Tile that the Character is standing on in Local Coordinates, and the Character
		tile_callbacks[tile.custom_data].call(tile, character)



# Process the tiles nearby a given Character on the given Tilemap
func process_nearby_tiles(tilemap: TileMapLayer, character: Character, tiles_out: int):
	
	# Store the coordinates of the Tiles that the Character is currently standing on and was previously standing on in Map Coordinates
	character.previous_tile = character.current_tile
	character.current_tile = tilemap.local_to_map(character.bottom_point)
	
	# Create a list of Tile coordinates to process starting with the tile that the Character is currently standing on
	var tiles_to_process: Array[Vector2i] = [character.current_tile]
	
	 #Iterate tiles_out number of times so that the coordinates for all of the Tiles are added to be processed 
	#(tiles_out represents how many tiles away from the Character on each side should be processed)
	for count in range(1, tiles_out + 1):
		
		# Retrieve the coordinates for the Tiles above, below, left, and right of the Character's current tile
		tiles_to_process.append(Vector2i(character.current_tile.x + count, character.current_tile.y))
		tiles_to_process.append(Vector2i(character.current_tile.x - count, character.current_tile.y))
		tiles_to_process.append(Vector2i(character.current_tile.x, character.current_tile.y + count))
		tiles_to_process.append(Vector2i(character.current_tile.x, character.current_tile.y - count))
		
		# Retrieve the coordinates for the tiles diagonally above the Character's current tile
		tiles_to_process.append(Vector2i(character.current_tile.x - count, character.current_tile.y - count))
		tiles_to_process.append(Vector2i(character.current_tile.x + count, character.current_tile.y - count))
		
		# Retrieve the coordinates for the tiles diagonally below the Character's current tile
		tiles_to_process.append(Vector2i(character.current_tile.x - count, character.current_tile.y + count))
		tiles_to_process.append(Vector2i(character.current_tile.x + count, character.current_tile.y + count))
		
		# Retrieve the coordinates for any remaining Tiles within range of the Character's current Tile (the range is determined by tiles_out)
		for number in range(1, count):
			tiles_to_process.append(Vector2i(character.current_tile.x - count, character.current_tile.y - count + number))
			tiles_to_process.append(Vector2i(character.current_tile.x + count, character.current_tile.y - count + number))
			tiles_to_process.append(Vector2i(character.current_tile.x - count + number, character.current_tile.y - count))
			tiles_to_process.append(Vector2i(character.current_tile.x + count - number, character.current_tile.y - count))
			
			tiles_to_process.append(Vector2i(character.current_tile.x - count, character.current_tile.y + count - number))
			tiles_to_process.append(Vector2i(character.current_tile.x + count, character.current_tile.y + count - number))
			tiles_to_process.append(Vector2i(character.current_tile.x - count + number, character.current_tile.y + count))
			tiles_to_process.append(Vector2i(character.current_tile.x + count - number, character.current_tile.y + count))
	
	# Process each of the Tiles using the coordinates from the list
	for tile_coords in tiles_to_process:
		execute_tile_callback(Tile.new(tilemap, tile_coords), character)

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
