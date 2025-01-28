extends Node2D

class_name TileManager

# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# A signal emitted to game.gd whenever a Tile's connected object is supposed to be loaded into the game
signal tile_object_enter_game

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

enum TileLayers { PITS, WATER, GROUND, ENVIRONMENT, SKY }

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var all_tilemaps: Dictionary

var tilemap_ground: TileMapLayer
var tilemap_environment: TileMapLayer
var tilemap_terrain: TileMapLayer


# A dictionary that maps Tile types to their designated callback functions for processing
var tile_callbacks : Dictionary = {
	"ledge_front" : tile_callback_ledge_front,
	"ledge_front_elevated" : tile_callback_ledge_front_elevated,
	
	"ledge_back" : tile_callback_ledge_back,
	"ledge_back_elevated" : tile_callback_ledge_back_elevated,
	
	"ledge_ground" : tile_callback_ledge_ground,
	"ledge_ground_elevated" : tile_callback_ledge_ground_elevated,
	
	"ground" : tile_callback_ground,
	
	"environment_asset" : tile_callback_environment_asset,
	"bush" : tile_callback_bush
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass



# Called every frame. Updates the Enemy's physics
func _physics_process(_delta: float) -> void:
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Immediately unloads the Tile from memory
func unload_tile(tile: Tile):
	tile.free()
	tile = null



# Process the Tile's designated callback function based on its type
func execute_tile_callback(tile: Tile, character: GameCharacter):
	
	# Determine if the Tile's type has a designated callback function to execute, then execute it
	if tile.type in tile_callbacks.keys():
		
		# Call the callback function for this Tile to process it with respect to the given Character
		tile_callbacks[tile.type].call(tile, character)



# Process the tiles nearby a given Character on the given Tilemap(s)
func process_nearby_tiles(tilemaps: Array[TileMapLayer], character: GameCharacter, tiles_above: int):
	
	# Note: tiles_above is the number of tiles that should be processed above the one that the Character is standing on
	# 	Ex: if trying to process three tiles above the tile that the Character is standing on, tiles_above = 3
	
	# Store the coordinates of the Tiles that the Character is currently standing on and was previously standing on in Map Coordinates
	character.previous_tile_position = character.current_tile_position
	character.current_tile_position = tilemaps[0].local_to_map(character.global_position)
	
	# Create a list of Tile coordinates to process
	var tiles_to_process: Array[Tile] = []
	
	# Store a local reference to the x and y coordinates of the Character's current Tile position
	var x: int = character.current_tile_position.x
	var y: int = character.current_tile_position.y
	
	
	# Iterate over each of the tilemaps that should have their Tiles processed
	for tilemap in tilemaps:
		
		# Add the Tiles in the row beneath the Character's current Tile into the list of Tiles to be processed
		tiles_to_process.append(Tile.new(tilemap, Vector2i(x + 1, y + 1)))
		tiles_to_process.append(Tile.new(tilemap, Vector2i(x, y + 1)))
		tiles_to_process.append(Tile.new(tilemap, Vector2i(x - 1, y + 1)))
		
		# Add the Tiles in the row including the Character's current Tile into the list of Tiles to be processed
		tiles_to_process.append(Tile.new(tilemap, Vector2i(x + 1, y)))
		tiles_to_process.append(Tile.new(tilemap, Vector2i(x, y)))
		tiles_to_process.append(Tile.new(tilemap, Vector2i(x - 1, y)))
		
		# Add the Tiles in the row above the Character's current Tile into the list of Tiles to be processed
		tiles_to_process.append(Tile.new(tilemap, Vector2i(x + 1, y - 1)))
		tiles_to_process.append(Tile.new(tilemap, Vector2i(x, y - 1)))
		tiles_to_process.append(Tile.new(tilemap, Vector2i(x - 1, y - 1)))
		
		# Iterate (tiles_above - 1) times to add extra rows of Tiles to process above the Character
		for count in range(2, tiles_above + 1):
			
			# Note: Loop starts at 2 instead of 1 because one row above the Character is already processed automatically (y - 1), so the next row to be added must start at (y = 2).
			
			# Add the Tiles 'count' row(s) above the Character's current Tile into the list of Tiles to be processed
			tiles_to_process.append(Tile.new(tilemap, Vector2i(x + 1, y - count)))
			tiles_to_process.append(Tile.new(tilemap, Vector2i(x, y - count)))
			tiles_to_process.append(Tile.new(tilemap, Vector2i(x - 1, y - count)))
	
	
	# Process each of the Tiles using their coordinates that were stored in the list
	for tile in range(tiles_to_process.size() - 1, -1, -1):
		
		# Execute the callback function associated with the type of Tile of this iteration
		execute_tile_callback(tiles_to_process[tile], character)
		
		# Unload the tile
		tiles_to_process[tile].free()
		tiles_to_process[tile] = null



# Returns the given Character's current altitude
func get_character_altitude(character: GameCharacter):
	
	# Store a local reference to the Tile that the Character is currently standing on in the terrain tilemap (the only map with elevation... at least as of 1/14/25)
	var current_tile = Tile.new(tilemap_terrain, character.current_tile_position)
	
	# Calculate and update the Character's current altitude
	character.current_altitude = get_altitude(current_tile)
	
	unload_tile(current_tile)
	current_tile = null



# A function used on any type of ledge tile to return its altitude
func get_altitude(ledge_tile: Tile):
	
	# Determine if the given Tile is not actually a ledge_tile, then return 0 because only Tiles with a 'ledge' typing have altitude
	if !ledge_tile.type or "ledge" not in ledge_tile.type:
		return 0
	
	# Determine if the given ledge_tile is not a front ledge, then fetch the closest front ledge, get it's height, and return that as the altitude
	if ledge_tile.type != "ledge_front" and ledge_tile.type != "ledge_front_elevated":
		
		# Store a local reference to the closest ledge_front Tile, and store an altitude value equal to the height of that ledge_front Tile
		var nearest_ledge_front = get_nearest_ledge_front(ledge_tile)
		var altitude = get_ledge_height(nearest_ledge_front, 1)
		
		# Unload the ledge_front Tile
		unload_tile(nearest_ledge_front)
		nearest_ledge_front = null
		
		# Return the altitude
		return altitude
	
	# Otherwise the given ledge_tile is a ledge_front Tile, so return it's height as the altitude
	else:
		return get_ledge_height(ledge_tile, 1)



# Determines the altitude of a given ledge_front Tile
func get_ledge_height(ledge_front_tile: Tile, altitude_counter: int):
	
	# Store a reference to the Tile below the given ledge_front_tile
	var tile_below = Tile.new(tilemap_terrain, Vector2i(ledge_front_tile.coords_map.x, ledge_front_tile.coords_map.y + 1))
	
	# Determine if the Tile below is a ledge_back or ledge_back_elevated, which would indicate there is a platform at a lower elevation than the ledge_front_tile, then try to get the ledge_front height from there with the altitude counter incremented to 2 now
	if tile_below.type == "ledge_back" or tile_below.type == "ledge_back_elevated":
		
		# Store a reference to the nearest ledge_front Tile
		var nearest_ledge_front = get_nearest_ledge_front(tile_below)
		
		# Set the altitude counter to equal the height of that ledge_front Tile
		altitude_counter = get_ledge_height(nearest_ledge_front, altitude_counter + 1)
		
		unload_tile(nearest_ledge_front)
		nearest_ledge_front = null
	
	
	# Otherwise, determine if the Tile below is ledge_front or a wall, which would indicate elevation, then calculate the altitude from that ledge_front with the altitude counter incremented
	elif tile_below.type == "ledge_front" or tile_below.type == "ledge_front_elevated" or tile_below.type == "ledge_wall":
		
		# Store the altitude counter value generated by the next recursive call of this function when the altitude counter incremented by 1
		altitude_counter = get_ledge_height(tile_below, altitude_counter + 1)
	
	
	# Unload the tile_below
	unload_tile(tile_below)
	tile_below = null
	
	# Return the altitude counter value
	return altitude_counter



# Gets a reference to the nearest ledge_front Tile
func get_nearest_ledge_front(tile: Tile):
	
	# Store a reference to the Tile below the given ledge_front_tile
	var tile_below = Tile.new(tilemap_terrain, Vector2i(tile.coords_map.x, tile.coords_map.y + 1))
	
	# Continue checking the Tile beneath the tile_below until it is a ledge_front type
	while not (tile_below.type == "ledge_front" or tile_below.type == "ledge_front_elevated"):
		
		# Store the map coords of the tile_below
		var coords = tile_below.coords_map
		
		# Unload the tile_below
		unload_tile(tile_below)
		tile_below = null
		
		# Set a tile_below to be equal to the tile beneath the previous tile_below
		tile_below = Tile.new(tilemap_terrain, Vector2i(coords.x, coords.y + 1))
		
		# Determine if the Tile below is a ledge_front tile, then return the Tile
		if tile_below.type == "ledge_front" or tile_below.type == "ledge_front_elevated":
			break
	
	return tile_below



# A callback function to be played when a Ledge Front Elevated Tile is being processed
func tile_callback_ledge_front(tile: Tile, character: GameCharacter):
	
	# Determine if the Character is not jumping, then adjust their collision value
	if !character.is_jumping:
		
		# Set the Character to collide with layer 1, disable their body collider, and enable their feet collider
		character.set_collision_value(1)
		character.body_collider.disabled = true
		character.feet_collider.disabled = false
	else:
		tile_callback_ledge_ground(tile, character)
		return
	
	# Determine if the Character is on a platform, then set this cell to have the y-sort origin necessary when the Character is on the platform
	if character.on_platform:
		tilemap_terrain.set_cell(tile.coords_map, 0, tilemap_terrain.get_cell_atlas_coords(tile.coords_map), 1)
	
	# Otherwise, the Character is on the ground, so determine if they are in front of the Tile and their z-index isn't already updated
	else:
		if character.z_index != 1 and character.global_position.y > tile.coords_local.y + tile.data.y_sort_origin:
			character.z_index = 1



# A callback function to be played when a Ledge Front Elevated Tile is being processed
func tile_callback_ledge_front_elevated(tile: Tile, character: GameCharacter):
	
	# Determine if the Character is not jumping, then adjust their collision value
	if !character.is_jumping:
		
		# Set the Character to collide with layer 3, disable their body collider, and enable their feet collider
		character.set_collision_value(3)
		character.body_collider.disabled = true
		character.feet_collider.disabled = false
	
	
	# Determine if the Character is on the ground, then set this cell to have the y-sort origin necessary when the Character is on the ground
	if !character.on_platform:
		tilemap_terrain.set_cell(tile.coords_map, 0, tilemap_terrain.get_cell_atlas_coords(tile.coords_map))
	
	# Otherwise, the Character is on a platform, so determine if they are in front of the Tile and their z-index isn't already updated
	else:
		if character.z_index != 1 and character.global_position.y > tile.coords_local.y + tile.data.y_sort_origin:
			character.z_index = 1


# A callback function to be played when a Ledge Back Tile is being processed
func tile_callback_ledge_back(tile: Tile, character: GameCharacter):
	
	# Determine if the Character is not jumping, then adjust their collision value
	if !character.is_jumping:
		
		# Set the Character to collide with layer 1, enable their body collider, and disable their feet collider
		character.set_collision_value(1)
		character.body_collider.disabled = false
		character.feet_collider.disabled = true
	
	
	# Determine if the Character is on a platform, then set this cell to have the y-sort origin necessary when the Character is on the platform
	if character.is_jumping or character.on_platform:
		tilemap_terrain.set_cell(tile.coords_map, 0, tilemap_terrain.get_cell_atlas_coords(tile.coords_map), 1)
	
	# Otherwise, the Character is on the ground, so determine if they are behind the Tile and their z-index isn't already updated
	else:
		if character.z_index != 0 and character.global_position.y < tile.coords_local.y + tile.data.y_sort_origin:
			character.z_index = 0


# A callback function to be played when a Ledge Back Elevated Tile is being processed
func tile_callback_ledge_back_elevated(tile: Tile, character: GameCharacter):
	
	# Determine if the Character is not jumping, then adjust their collision value
	if !character.is_jumping:
		
		# Set the Character to collide with layer 3, enable their body collider, and disable their feet collider
		character.set_collision_value(3)
		character.body_collider.disabled = true
		character.feet_collider.disabled = false
	
	# Determine if the Character is on the ground, then set this cell to have the y-sort origin necessary when the Character is on the ground
	if !character.on_platform:
		tilemap_terrain.set_cell(tile.coords_map, 0, tilemap_terrain.get_cell_atlas_coords(tile.coords_map))


# A callback function to be played when a Ledge Ground Tile is being processed
func tile_callback_ledge_ground(tile: Tile, character: GameCharacter):
	
	# Determine if the Character is on a platform, then set this cell to have the y-sort origin necessary when the Character is on the platform
	if character.is_jumping or character.on_platform:
		tilemap_ground.set_cell(tile.coords_map, 0, tilemap_ground.get_cell_atlas_coords(tile.coords_map), 2)



# A callback function to be played when a Ledge-Grass-Elevated Tile is being processed
func tile_callback_ledge_ground_elevated(tile: Tile, character: GameCharacter):
	
	# Determine if the Character is on the ground, then set this cell to have the y-sort origin necessary when the Character is on the ground
	if !character.is_jumping and !character.on_platform:
		tilemap_ground.set_cell(tile.coords_map, 0, tilemap_ground.get_cell_atlas_coords(tile.coords_map), 1)



# A callback function to be played when a Ground Tile is being processed
func tile_callback_ground(tile: Tile, character: GameCharacter):
	
	# Store a reference to the Tile in the same cell as the given tile but in the Terrain tilemap
	var terrain_tile = tile.get_same_cell(tilemap_terrain)
	
	# Check if the Tile that is in the same cell coordinates in the terrain tilemap as this Tile in the ground tilemap is a 'ledge' Tile
	if "ledge" in terrain_tile.type and terrain_tile.type != "ledge_wall":
		
		# Determine if the Character is on a platform, then set this cell to have the y-sort origin necessary when the Character is on the platform
		if character.on_platform:
			
			# Set this current ground tile to be a ledge_ground tile because the tile on the terrain map is a ledge
			tilemap_ground.set_cell(tile.coords_map, 0, tilemap_ground.get_cell_atlas_coords(tile.coords_map), 2)
		
		else:
			# Set this current ground tile to be a ledge_ground tile because the tile on the terrain map is a ledge
			tilemap_ground.set_cell(tile.coords_map, 0, tilemap_ground.get_cell_atlas_coords(tile.coords_map), 1)
			
	
	# Unload the terrain Tile
	unload_tile(terrain_tile)
	terrain_tile = null



# A callback function to be played when a EnvironmentAsset Tile is being processed (Trees and Rocks are currently the only EnvironmentAssets as of 1/23/25)
func tile_callback_environment_asset(tile: Tile, character: GameCharacter):
	
	# Determine if the Character is not jumping, then adjust their collision value
	if !character.is_jumping:
		
		# Set the Character to collide with layer 1, enable their body collider, and disable their feet collider
		character.set_collision_value(1)
		character.body_collider.disabled = true
		character.feet_collider.disabled = false
		character.z_index = 0
	
	else:
		
		# Determine if the Character started their jump in front of the environment tile, then set their z-index to 1 so that they don't clip through the asset while jumping
		if character.jump_start_height > tile.coords_local.y + tile.data.y_sort_origin:
			character.z_index = 1



# A callback function to be played when a Bush Tile is being processed (Bushes are not included with typical EnvironmentAssets because they need to be converted into objects, as they have their own behaviors. 1/23/25)
func tile_callback_bush(tile: Tile, character: GameCharacter):
	
	# Determine if the Character is not jumping, then adjust their collision value
	if !character.is_jumping:
		
		# Set the Character to collide with layer 1, enable their body collider, and disable their feet collider
		character.set_collision_value(1)
		character.body_collider.disabled = true
		character.feet_collider.disabled = false
		character.z_index = 0
	
	
	# Send a signal to the game to attempt to load the Bush Tile into the Scene Tree
	tile_object_enter_game.emit(tile)




#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
