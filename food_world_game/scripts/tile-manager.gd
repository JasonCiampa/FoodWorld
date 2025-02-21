extends TileMapLayer

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

var world_tilemaps: Dictionary

var tilemaps_active: Array[TileMapLayer]

var tiles_occupied: Dictionary
var tiles_enabled_navigation: Dictionary

# A dictionary that maps Tile types to their designated callback functions for processing
var tile_callbacks : Dictionary = {
	"ground" : tile_callback_ground,
	
	"ledge_front" : tile_callback_ledge,
	"ledge_back" : tile_callback_ledge,
	
	"environment_asset" : tile_callback_environment_asset,
	"bush" : tile_callback_bush,
	
	"building" : tile_callback_building
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


func _init(_world_tilemaps: Dictionary) -> void:
	world_tilemaps = _world_tilemaps
	
	var tiles_used_environment: Array
	
	for world in world_tilemaps:
		
		tiles_used_environment.append_array(world_tilemaps[world][Tile.MapType.ENVIRONMENT].get_used_cells())
		
		var unique_dict = {} 
		
		for coords in tiles_used_environment:
			unique_dict[coords] = true
			
		tiles_used_environment = unique_dict.keys()
		
		
		# PATH FINDING 
		for coords in range(tiles_used_environment.size() -1, 0, -1):
		
			# Determine if the ground Tile's coordinates are not occupied in the environment tilemap, then enable pathfinding for the tile
			var environment_tile = Tile.new(world_tilemaps[world][Tile.MapType.ENVIRONMENT], Tile.MapType.ENVIRONMENT, tiles_used_environment[coords])
			
			# Determine if the terrain Tile's width is set and is larger than 1
			if environment_tile.width != null and environment_tile.width > 1:
				
				# Iterate for each tile wide the Tile is
				for col in range(environment_tile.width + 1):
					
					# Iterate for each tile tall the Tile is
					for row in range(environment_tile.height):
						
						# Append the coordinates of this sub-Tile into the list of Tiles not to process for path-finding
						tiles_occupied.get_or_add(Vector2i(tiles_used_environment[coords].x - int(environment_tile.width / 2) + col, tiles_used_environment[coords].y - int(environment_tile.height / 2) + row + 1), true)
			else:
				
				# Append the coordinates of this single Tile into the list of Tiles not to process for path-finding
				tiles_occupied.get_or_add(tiles_used_environment[coords], true)
	

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Immediately unloads the Tile from memory
func unload_tile(tile: Tile):
	tile.free()
	tile = null


# Determine where the Character is in the world and send a signal to the game to update their location (returns TileMap to process)
func update_tile_world_location(tile: Tile, character: GameCharacter) -> Tile:
	
	# Determine if there is not any data for the given Tile in its associated Tilemap
	if tile.type == "":
	
		# Iterate over each world that contains Tilemaps
		for world in world_tilemaps:
			
			# Create a new Tile with the same type of Tilemap and the same coordinates as the given Tile in the world of this iteration
			var new_tile: Tile = Tile.new(world_tilemaps[world][tile.map_type], tile.map_type, tile.coords_map)
			
			# Determine if the newly created Tile has data in the world of this iteration
			if new_tile.type != "":
				
				character.current_tilemaps = world_tilemaps[world]
			
				return new_tile
			
			# Otherwise, the newly created Tile doesn't exist in the world of this iteration, so unload it
			else:
				
				# Unload the Tile and return from the function now that the world has been updated
				unload_tile(new_tile)
				new_tile = null
		
		# No data was found in any TileMap in any world for this Tile, so return null because there's no point in processing an empty Tile
		return null
	
	# Otherwise, the Tile already has data in its associated Tilemap, so return the tile without changes
	else:
		return tile



# Process the Tile's designated callback function based on its type
func execute_tile_callback(tile: Tile, character: GameCharacter):
	
	# Update the Tile's world location if necessary
	var updated_tile = update_tile_world_location(tile, character)
	
	# Determine if the updated Tile is not null and if the Tile's type has a designated callback function to execute, then execute it
	if updated_tile and tile_callbacks.get(tile.type) != null:
		
		# Call the callback function for this Tile to process it with respect to the given Character
		tile_callbacks[tile.type].call(tile, character)


# Process the tiles nearby a given Character on the given Tilemap(s)
func process_nearby_tiles(character: GameCharacter, tiles_above: int):
	
	# Note: tiles_above is the number of tiles that should be processed above the one that the Character is standing on
	# 	Ex: if trying to process three tiles above the tile that the Character is standing on, tiles_above = 3
	
	# Store the coordinates of the Tiles that the Character is currently standing on and was previously standing on in Map Coordinates
	character.previous_tile_position = character.current_tile_position
	character.current_tile_position = character.current_tilemaps[Tile.MapType.GROUND].local_to_map(character.global_position)
	
	# Create a list of Tile coordinates to process
	var tiles_to_process: Array[Tile] = []
	
	# Store a local reference to the x and y coordinates of the Character's current Tile position
	var x: int = character.current_tile_position.x
	var y: int = character.current_tile_position.y
	
	# Iterate over each of the tilemaps that should have their Tiles processed
	for map_type in character.current_tilemaps.size():
		
		# Add the Tiles in the row beneath the Character's current Tile into the list of Tiles to be processed
		tiles_to_process.append(Tile.new(character.current_tilemaps[map_type], map_type, Vector2i(x + 1, y + 1)))
		tiles_to_process.append(Tile.new(character.current_tilemaps[map_type], map_type, Vector2i(x, y + 1)))
		tiles_to_process.append(Tile.new(character.current_tilemaps[map_type], map_type, Vector2i(x - 1, y + 1)))
		
		# Add the Tiles in the row including the Character's current Tile into the list of Tiles to be processed
		tiles_to_process.append(Tile.new(character.current_tilemaps[map_type], map_type, Vector2i(x + 1, y)))
		tiles_to_process.append(Tile.new(character.current_tilemaps[map_type], map_type, Vector2i(x, y)))
		tiles_to_process.append(Tile.new(character.current_tilemaps[map_type], map_type, Vector2i(x - 1, y)))
		
		# Add the Tiles in the row above the Character's current Tile into the list of Tiles to be processed
		tiles_to_process.append(Tile.new(character.current_tilemaps[map_type], map_type, Vector2i(x + 1, y - 1)))
		tiles_to_process.append(Tile.new(character.current_tilemaps[map_type], map_type, Vector2i(x, y - 1)))
		tiles_to_process.append(Tile.new(character.current_tilemaps[map_type], map_type, Vector2i(x - 1, y - 1)))
		
		# Iterate (tiles_above - 1) times to add extra rows of Tiles to process above the Character
		for count in range(2, tiles_above + 1):
			
			# Note: Loop starts at 2 instead of 1 because one row above the Character is already processed automatically (y - 1), so the next row to be added must start at (y = 2).
			
			# Add the Tiles 'count' row(s) above the Character's current Tile into the list of Tiles to be processed
			tiles_to_process.append(Tile.new(character.current_tilemaps[map_type], map_type, Vector2i(x + 1, y - count)))
			tiles_to_process.append(Tile.new(character.current_tilemaps[map_type], map_type, Vector2i(x, y - count)))
			tiles_to_process.append(Tile.new(character.current_tilemaps[map_type], map_type, Vector2i(x - 1, y - count)))
	
	

	
	# Process each of the Tiles using their coordinates that were stored in the list
	for tile in range(tiles_to_process.size() - 1, -1, -1):
		
		# Execute the callback function associated with the type of Tile of this iteration
		execute_tile_callback(tiles_to_process[tile], character)
		
		
		if tiles_to_process[tile].map_type == Tile.MapType.GROUND:
			
			# Determine if the tile is not occupied or already enabled for navigation, then enable navigation on it and add it to the list of tile coords enabled for navigation
			if tiles_occupied.get(tiles_to_process[tile].coords_map) == null and tiles_enabled_navigation.get(tiles_to_process[tile].coords_map) == null:
				tiles_to_process[tile].tilemap.set_cell(tiles_to_process[tile].coords_map, 0, tiles_to_process[tile].tilemap.get_cell_atlas_coords(tiles_to_process[tile].coords_map), 2)
				tiles_enabled_navigation.get_or_add(tiles_to_process[tile].coords_map, true)
		
		# Unload the tile
		tiles_to_process[tile].free()
		tiles_to_process[tile] = null



# Returns the given Character's current altitude
func get_character_altitude(character: GameCharacter):
	
	# Store a local reference to the Tile that the Character is currently standing on in the terrain tilemap (the only map with elevation... at least as of 1/14/25)
	var current_tile = Tile.new(character.current_tilemaps[Tile.MapType.TERRAIN], Tile.MapType.TERRAIN, character.current_tile_position)
	
	# Calculate and update the Character's current altitude
	character.current_altitude = get_altitude(current_tile, character)
	
	unload_tile(current_tile)
	current_tile = null



# A function used on any type of ledge tile to return its altitude
func get_altitude(ledge_tile: Tile, character: GameCharacter):
	
	# Determine if the given Tile is not actually a ledge_tile, then return 0 because only Tiles with a 'ledge' typing have altitude
	if !ledge_tile.type or "ledge" not in ledge_tile.type:
		return 0
	
	# Determine if the given ledge_tile is not a front ledge, then fetch the closest front ledge, get it's height, and return that as the altitude
	if ledge_tile.type != "ledge_front":
		
		# Store a local reference to the closest ledge_front Tile, and store an altitude value equal to the height of that ledge_front Tile
		var nearest_ledge_front = get_nearest_ledge_front(ledge_tile, character)
		var altitude = get_ledge_height(nearest_ledge_front, 1, character)
		
		# Unload the ledge_front Tile
		unload_tile(nearest_ledge_front)
		nearest_ledge_front = null
		
		# Return the altitude
		return altitude
	
	# Otherwise the given ledge_tile is a ledge_front Tile, so return it's height as the altitude
	else:
		return get_ledge_height(ledge_tile, 1, character)



# Determines the altitude of a given ledge_front Tile
func get_ledge_height(ledge_front_tile: Tile, altitude_counter: int, character: GameCharacter):
	
	# Store a reference to the Tile below the given ledge_front_tile
	var tile_below = Tile.new(character.current_tilemaps[Tile.MapType.TERRAIN], Tile.MapType.TERRAIN, Vector2i(ledge_front_tile.coords_map.x, ledge_front_tile.coords_map.y + 1))
	
	# Determine if the Tile below is a ledge_back, which would indicate there is a platform at a lower elevation than the ledge_front_tile, then try to get the ledge_front height from there with the altitude counter incremented to 2 now
	if tile_below.type == "ledge_back":
		
		# Store a reference to the nearest ledge_front Tile
		var nearest_ledge_front = get_nearest_ledge_front(tile_below, character)
		
		# Set the altitude counter to equal the height of that ledge_front Tile
		altitude_counter = get_ledge_height(nearest_ledge_front, altitude_counter + 1, character)
		
		unload_tile(nearest_ledge_front)
		nearest_ledge_front = null
	
	
	# Otherwise, determine if the Tile below is ledge_front or a wall, which would indicate elevation, then calculate the altitude from that ledge_front with the altitude counter incremented
	elif tile_below.type == "ledge_front" or tile_below.type == "ledge_wall":
		
		# Store the altitude counter value generated by the next recursive call of this function when the altitude counter incremented by 1
		altitude_counter = get_ledge_height(tile_below, altitude_counter + 1, character)
	
	
	# Unload the tile_below
	unload_tile(tile_below)
	tile_below = null
	
	# Return the altitude counter value
	return altitude_counter



# Gets a reference to the nearest ledge_front Tile
func get_nearest_ledge_front(tile: Tile, character: GameCharacter):
	
	# Store a reference to the Tile below the given ledge_front_tile
	var tile_below = Tile.new(character.current_tilemaps[Tile.MapType.TERRAIN], Tile.MapType.TERRAIN, Vector2i(tile.coords_map.x, tile.coords_map.y + 1))
	
	# Continue checking the Tile beneath the tile_below until it is a ledge_front type
	while not (tile_below.type == "ledge_front"):
		
		# Store the map coords of the tile_below
		var coords = tile_below.coords_map
		
		# Unload the tile_below
		unload_tile(tile_below)
		tile_below = null
		
		# Set a tile_below to be equal to the tile beneath the previous tile_below
		tile_below = Tile.new(character.current_tilemaps[Tile.MapType.TERRAIN], Tile.MapType.TERRAIN, Vector2i(coords.x, coords.y + 1))
		
		# Determine if the Tile below is a ledge_front tile, then return the Tile
		if tile_below.type == "ledge_front":
			break
	
	return tile_below



# A callback function to be played when a Ground Tile is being processed
func tile_callback_ground(tile: Tile, character: GameCharacter):
	
	# Store a reference to the Tile in the same cell as the given tile but in the Terrain tilemap
	var terrain_tile = tile.get_same_cell(character.current_tilemaps[Tile.MapType.TERRAIN], Tile.MapType.TERRAIN)
	
	# Check if the Tile that is in the same cell coordinates in the terrain tilemap as this Tile in the ground tilemap is a 'ledge' Tile
	if terrain_tile.type == "ledge_back":
		
		# Set this current ground tile to be a ledge_ground tile because the tile on the terrain map is a ledge
		character.current_tilemaps[Tile.MapType.GROUND].set_cell(tile.coords_map, 0, character.current_tilemaps[Tile.MapType.GROUND].get_cell_atlas_coords(tile.coords_map), 1)
	
	
	# Unload the terrain Tile
	unload_tile(terrain_tile)
	terrain_tile = null


# A callback function to be played when a Ledge Tile is being processed
func tile_callback_ledge(tile: Tile, character: GameCharacter):

	if abs(tile.coords_local.x - character.global_position.x) > 8:
		return
	
	
	# Determine if the Character is currently standing on a platform, then update their collision and z-index to behave accordingly while they are on the platform
	if character.on_platform:
		
		character.set_collision_value(character.CollisionValues.PLATFORM)
		character.body_collider.disabled = true
		character.feet_collider.disabled = false
	
	# Determine if the Character is currently jumping in mid-air, then update their collision and z-index to behave accordingly while they are in mid-air
	elif character.is_jumping:
		character.set_collision_value(character.CollisionValues.MIDAIR)
		character.body_collider.disabled = true
		character.feet_collider.disabled = false
	
	# Otherwise, the Character is on the ground, so update their collision and z-index to behave accordingly while they are on the ground
	else:
		character.set_collision_value(character.CollisionValues.GROUND)
		
		# Determine if the given ledge Tile is a 'ledge_front', then update the Character's collision and z-index with respect to that Tile type
		if tile.type == "ledge_front":
			character.body_collider.disabled = true
			character.feet_collider.disabled = false
		
		
		# Otherwise, the given ledge Tile is a 'ledge_back', so update the Character's collision and z-index with respect to that Tile type
		else:
			
			# Set this current ground tile to be a ledge_ground tile because the tile on the terrain map is a ledge
			var tile_above = Tile.new(character.current_tilemaps[Tile.MapType.GROUND], Tile.MapType.GROUND, tile.coords_map)
			
			if "ledge" not in tile_above.type:
				character.body_collider.disabled = false
				character.feet_collider.disabled = true
			
				# Determine if the Character is standing behind the Tile
				if character.current_tile_position != tile.coords_local:
					character.z_index = -1
					
					unload_tile(tile_above)
					tile_above = null
					return
			
			unload_tile(tile_above)
			tile_above = null
		
	character.z_index = 0



# A callback function to be played when a EnvironmentAsset Tile is being processed (Trees and Rocks are currently the only EnvironmentAssets as of 1/23/25)
func tile_callback_environment_asset(_tile: Tile, character: GameCharacter):
	
	# Determine if the Character is not jumping, then adjust their collision value
	if !character.is_jumping:
		
		# Set the Character to collide with the ground physics layer, enable their body collider, and disable their feet collider
		character.set_collision_value(character.CollisionValues.GROUND)
		character.body_collider.disabled = true
		character.feet_collider.disabled = false
		character.z_index = 0



# A callback function to be played when a Bush Tile is being processed (Bushes are not included with typical EnvironmentAssets because they need to be converted into objects, as they have their own behaviors. 1/23/25)
func tile_callback_bush(tile: Tile, character: GameCharacter):
	
	# Determine if the Character is not jumping, then adjust their collision value
	if !character.is_jumping:
		
		# Set the Character to collide with the ground physics layer, enable their body collider, and disable their feet collider
		character.set_collision_value(character.CollisionValues.GROUND)
		character.body_collider.disabled = true
		character.feet_collider.disabled = false
		character.z_index = 0
	
	
	# Send a signal to the game to attempt to load the Bush Tile into the Scene Tree
	tile_object_enter_game.emit(tile)



# A callback function to be played when a Building Tile is being processed
func tile_callback_building(tile: Tile, _character: GameCharacter):
	
	# Send a signal to the game to attempt to load the Building Tile into the Scene Tree
	tile_object_enter_game.emit(tile)


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
