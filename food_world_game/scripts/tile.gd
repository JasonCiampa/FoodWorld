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

var mid_jump: bool = false

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
func tile_callback_ledge(tilemap: TileMapLayer, tile_data: TileData, tile_map_coords: Vector2i, character: Character):
	
	# TO ACCOUNT FOR HIGHER ELEVATIONS, ADD A CHECK TO SEE IF THIS TILE'S Z-INDEX IS ONE, TWO, THREE, FOUR, ETC. HIGH OFF THE GROUND.
	# BASED ON THAT COUNT, LETS SAY 4, THAT MEANS THERE SHOULD BE FOUR WALLS UNDERNEATH THIS TILE.
	# THE COLLISION LAYER SHOULD BE PUSHED DOWN COUNT -1 TILES SO THAT THE BOTTOM MOST PART OF THE WALL IS COLLIDEABLE
	
	# Store a reference to a Tile's local coordinates after converting them from the given map coordinates of the Tile
	var tile_local_coords = tilemap.map_to_local(tile_map_coords)
	
	var current_tile_data = tilemap.get_cell_tile_data(character.current_tile)
	
	if current_tile_data:
		
		if current_tile_data.get_custom_data("tile_type") == "ledge" or current_tile_data.get_custom_data("tile_type") == "ledge_grass":
			return
		
	# Determine if the Character is jumping from below the Tile and has 
	if character.is_jumping:
		
		if character.bottom_point.y <= tile_local_coords.y + 16:
			character.z_index = tile_data.z_index + 1
		
		return
	
	# Determine if the Character is horizontally in range of the Tile
	if tile_local_coords.x - 16 <= character.position.x and character.position.x <= tile_local_coords.x + 16:
		
		# Determine if the Character is above the Tile
		if character.position.y < tile_local_coords.y:
			
			# Set the Character's z-index to be 2 less than than the Tile's so that the Character appears as if they are behind the Tile
			character.z_index = tile_data.z_index - 2
			
		# Otherwise, the Character is below the Tile
		else:
			character.z_index = 1


	
	
	# Paint Grass or whatever tile underneath cliffs/ledges with the alternate tile so that it can be processed separately from normal ground grass
	# If Player is jumping and passes the height required to land on a tile, set the Player's z-index to be one higher than the ledge's z-index.
	# If the Player's z-index is equal to the ledge's z-index, disable its collision layer
	
# Set Ledge tiles in Tilemap Editor to the appropriate z-index (increment by 1 for every time you elevate)
# In code, increment ledge z-index by 2 and ledge grass/tile by 1
# Everytime the Player's altitude increases, increase their z-index


# The higher the ledge becomes, the higher the default z-index but the lower the z-index should be in actual game

# LEDGE IN FRONT OF / ABOVE PLAYER
# Ledge					3
# Ledge Grass/Tile		2

# On top of ground		1
	# Player
# Ground (lowest)		0



# PLAYER STANDING IN FRONT OF LEDGE
# On top of ground		1	->	-1
	# Player

# Ledge					1	->	-1
# Ledge Grass/Tile		0	->	-2

# Ground (lowest)		0	->	-2


# PLAYER STANDING IN FRONT OF LEDGE
# On top of ground		1
	# Player

# Ledge					3	->	-3
# Ledge Grass/Tile		0	->	-4

# Ground (lowest)		0

# PLAYER ON TOP OF LEDGE
# On top of ground		4
	# Player



# Ledge					3
# Ledge Grass/Tile		2

# Ground (lowest)		0

# -4096 - -4093
# 3 - 0 (-2) = 1

# A variable that stores a callback function to be played when a Ledge Tile is being processed
func tile_callback_grass(tilemap: TileMapLayer, tile_data: TileData, tile_map_coords: Vector2i, character: Character):
	
	var terrain_tile_data = tilemap_terrain.get_cell_tile_data(tile_map_coords)
	
	if terrain_tile_data:
		var terrain_custom_data = terrain_tile_data.get_custom_data("tile_type")
		
		if terrain_custom_data == "ledge":
			tilemap_ground.set_cell(tile_map_coords, 0, tilemap_ground.get_cell_atlas_coords(tile_map_coords), 1)

	# IF THE TILE AT THE SAME COORDINATES ON THE TERRAIN TILEMAP IS A LEDGE
		# SET THE TILE IN THE GIVEN TILEMAP TO BE THE ALTERNATIVE GRASS TILE
		# IN THE ALTERNATIVE GRASS TILE CALLBACK, JUST ALWAYS SET ITS Z-INDEX TO BE 1 LOWER THAN THE LEDGE IT CORRESPONDS TO
	pass
	

# Returns a list of all the Tile Types for each tile surrounding the given Tile
func get_surrounding_tile_types(tile_coords: Vector2i):
	pass


func process_tile_data(tilemap: TileMapLayer, tile_map_coords: Vector2i, character: Character):
	
	# Attempt to fetch and store this Tile's data using the Tile's map coords (might fail if an invalid tile was given to the func)
	var tile_data = tilemap.get_cell_tile_data(tile_map_coords)
	
	# Determine if Tile data was fetched, then attempt to fetch the custom data I've embedded into the Tile
	if tile_data != null:
		
		# Attempt to fetch and store the specified custom data from the Tile (the Tile's type in this case)
		var tile_custom_data = tile_data.get_custom_data("tile_type")
		
		# Determine if the Tile's custom data (tile type) has a designated callback function to execute, then execute it
		if tile_custom_data in tile_callbacks.keys():
			
			# Call the callback function for this tile and pass in the Tilemap, the coordinates of the Tile that the Character is standing on in Local Coordinates, and the Character
			tile_callbacks[tile_custom_data].call(tilemap, tile_data, tile_map_coords, character)



# Process the tiles
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
		process_tile_data(tilemap, tile_coords, character)

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
