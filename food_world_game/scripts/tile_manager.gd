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
	
	"ledge" : tile_callback_ledge,
	"ledge_top": tile_callback_ledge_top,
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
	
	if character.on_platform:
		character.z_index = tile.data.z_index + 1
		
		var tile_above = Tile.new(tilemap_terrain, Vector2i(tile.coords_map.x, tile.coords_map.y - 1))
	
		if tile_above.set_custom_data("tile_type"):
		
			# Determine if the tile above the Character is a ledge
			if tile_above.custom_data == "ledge":
				return
		
		else:
			
			# Determine if the ledge that the Character is on doesn't have a ledge above of it (the Character is on this ledge if they are on a platform and their feet are above the bottom of the tile)
			if tile.coords_local.y + 8 > character.bottom_point.y and character.bottom_point.y > tile.coords_local.y - 8:
			
				# Set this current ledge tile to be an alternate ledge_top tile with a physics barrier on top because this ledge is the highest so it won't have another ledge with its own barrier above it to prevent the Player from walking off
				tilemap_terrain.set_cell(tile.coords_map, 0, tilemap_terrain.get_cell_atlas_coords(tile.coords_map), 1)
				character.body_collider.disabled = true
				character.position.y -= 1
				return
		
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



func tile_callback_ledge_top(tile: Tile, character: Character):
	
	if character.on_platform:
		if character.bottom_point.y < tile.coords_local.y + 8:
			character.body_collider.disabled = true
	
	if character.is_jumping:
		
		if tile.coords_local.y + 8 > character.jump_start_height and character.jump_start_height > tile.coords_local.y - 8:
			tilemap_terrain.set_cell(tile.coords_map, 0, tilemap_terrain.get_cell_atlas_coords(tile.coords_map))
			# Change this so that the character will fall back down to the collider
			character.jump_start_height = tile.coords_local.y + 8
	
	#if character.is_falling:
		#if character.bottom_point.y < tile.coords_local.y - 8:
			#print("fart")
			#tilemap_terrain.set_cell(tile.coords_map, 0, tilemap_terrain.get_cell_atlas_coords(tile.coords_map))




# A variable that stores a callback function to be played when a Ledge Tile is being processed
func tile_callback_grass(tile: Tile, character: Character):
	
	var terrain_tile = tile.get_same_cell(tilemap_terrain)
		
	if terrain_tile.set_custom_data("tile_type"):
		
		# Determine if the Tile at the same coordinates as this Tile on the terrain map is a ledge, then set this grass Tile to be ledge_grass
		if terrain_tile.custom_data == "ledge":
			
			# Set this current grass tile to be a ledge_grass tile because the tile on the terrain map is a ledge
			tilemap_ground.set_cell(tile.coords_map, 0, tilemap_ground.get_cell_atlas_coords(tile.coords_map), 1)



# Process the Tile's designated callback function based on its type
func execute_tile_callback(tile: Tile, character: Character):
	
	# Set the Tile's type in the Tile's custom data variable
	if tile.set_custom_data("tile_type"):
		
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
	#tiles_to_process[0].set_custom_data("tile_type")
	#if tiles_to_process[0].custom_data:
		#print(tiles_to_process[0].custom_data)
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
	
	# Process each of the Tiles using the coordinates from the list
	for tile in tiles_to_process:
		execute_tile_callback(tile, character)

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
