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
func tile_callback_ledge(tilemap: TileMapLayer, tile_data: TileData, tile_map_coords: Vector2i, character: Character):
	# Set the ledge to appear above the Player
	var tile_local_coords = tilemap.map_to_local(tile_map_coords)
	
	if tile_local_coords.x - 20 <= character.position.x and character.position.x <= tile_local_coords.x + 20:
		
		if character.position.y <= tile_local_coords.y:
			tilemap_environment.set_cell(tile_map_coords, 0, tilemap_environment.get_cell_atlas_coords(tile_map_coords), 1)
			tilemap_ground.set_cell(tile_map_coords, 0, tilemap_ground.get_cell_atlas_coords(tile_map_coords), 1)
			return

	tilemap_environment.set_cell(tile_map_coords, 0, tilemap_environment.get_cell_atlas_coords(tile_map_coords))
	tilemap_ground.set_cell(tile_map_coords, 0, tilemap_ground.get_cell_atlas_coords(tile_map_coords))




# A variable that stores a callback function to be played when a Ledge Tile is being processed
func tile_callback_grass(tilemap: TileMapLayer, tile_data: TileData, tile_coords: Vector2i, character: Character):
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



# number of layers of tiles to process as a parameter??
func process_tiles_around(tilemap: TileMapLayer, character: Character, tiles_from_center: int):
	
	# Store the coordinates of the Tile that the Character is standing on in Map Coordinates
	var main_tile_coords = tilemap.local_to_map(character.bottom_point)
	var tiles_to_process: Array[Vector2i] = [main_tile_coords]
	
	# Forms a 25x25 grid of tiles to process
	for count in range(1, tiles_from_center + 1):
		tiles_to_process.append(Vector2i(main_tile_coords.x + count, main_tile_coords.y))
		tiles_to_process.append(Vector2i(main_tile_coords.x - count, main_tile_coords.y))
		tiles_to_process.append(Vector2i(main_tile_coords.x, main_tile_coords.y + count))
		tiles_to_process.append(Vector2i(main_tile_coords.x, main_tile_coords.y - count))
		
		tiles_to_process.append(Vector2i(main_tile_coords.x - count, main_tile_coords.y - count))
		tiles_to_process.append(Vector2i(main_tile_coords.x + count, main_tile_coords.y - count))
		
		tiles_to_process.append(Vector2i(main_tile_coords.x - count, main_tile_coords.y + count))
		tiles_to_process.append(Vector2i(main_tile_coords.x + count, main_tile_coords.y + count))
		
		for number in range(1, count):
			tiles_to_process.append(Vector2i(main_tile_coords.x - count, main_tile_coords.y - count + number))
			tiles_to_process.append(Vector2i(main_tile_coords.x + count, main_tile_coords.y - count + number))
			tiles_to_process.append(Vector2i(main_tile_coords.x - count + number, main_tile_coords.y - count))
			tiles_to_process.append(Vector2i(main_tile_coords.x + count - number, main_tile_coords.y - count))
			
			tiles_to_process.append(Vector2i(main_tile_coords.x - count, main_tile_coords.y + count - number))
			tiles_to_process.append(Vector2i(main_tile_coords.x + count, main_tile_coords.y + count - number))
			tiles_to_process.append(Vector2i(main_tile_coords.x - count + number, main_tile_coords.y + count))
			tiles_to_process.append(Vector2i(main_tile_coords.x + count - number, main_tile_coords.y + count))

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
