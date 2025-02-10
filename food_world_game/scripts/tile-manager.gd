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

var world_tilemaps: Dictionary

var tilemaps_active: Array[TileMapLayer]

var tilemap_ground: TileMapLayer
var tilemap_environment: TileMapLayer
var tilemap_terrain: TileMapLayer
var tilemap_buildings_interior: TileMapLayer
var tilemap_buildings_exterior: TileMapLayer

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
	
	tilemap_ground = world_tilemaps["center"][0]
	tilemap_terrain = world_tilemaps["center"][1]
	tilemap_environment = world_tilemaps["center"][2]
	tilemap_buildings_interior = world_tilemaps["center"][3]
	tilemap_buildings_exterior = world_tilemaps["center"][4]
	
	tilemaps_active = [
		tilemap_ground,
		tilemap_terrain,
		tilemap_environment,
		tilemap_buildings_interior,
		tilemap_buildings_exterior
	]

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Immediately unloads the Tile from memory
func unload_tile(tile: Tile):
	tile.free()
	tile = null


# Determine where the Character is in the world and send a signal to the game to update their location (returns TileMap to process)
func update_tile_world_location(tile: Tile, _character: GameCharacter) -> Tile:
	
	# Determine if there is not any data for the given Tile in its associated Tilemap
	if tile.type == "":
	
		# Iterate over each world that contains Tilemaps
		for world in world_tilemaps:
			
			# Create a new Tile with the same type of Tilemap and the same coordinates as the given Tile in the world of this iteration
			var new_tile: Tile = Tile.new(world_tilemaps[world][tile.map_type], tile.map_type, tile.coords_map)
			
			# Determine if the newly created Tile has data in the world of this iteration
			if new_tile.type != "":
				
				# Update the TileManager's Current TileMap References to store the TileMaps from the world the newly created Tile is from
				tilemap_ground = world_tilemaps[world][0]
				tilemap_terrain = world_tilemaps[world][1]
				tilemap_environment = world_tilemaps[world][2]
				tilemap_buildings_interior = world_tilemaps[world][3]
				tilemap_buildings_exterior = world_tilemaps[world][4]
				
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


# Generates a path for a Character to follow towards a target.
func generate_path(character: GameCharacter, target_position: Vector2i, tiles_in_path: int = 0):
	
	# Create a list that will store all of the coordinates of the Tile coordinates on the path
	var tile_coords_path: Array[Vector2i] = []
	
	var starting_coords: Vector2i = character.current_tile_position
	var ending_coords: Vector2i = target_position
	
	var coords: Vector2i = starting_coords
	
	# Create a Dictionary that will store Tilemaps and the locations of Tiles within them
	var tiles_used: Dictionary = {
		
		tilemap_terrain: tilemap_terrain.get_used_cells(), 
		tilemap_environment: tilemap_environment.get_used_cells(), 
		tilemap_buildings_interior: tilemap_buildings_interior.get_used_cells(), 
		tilemap_buildings_exterior: tilemap_buildings_exterior.get_used_cells()
	
	}
	
	
	print(starting_coords)
	print(ending_coords)
	
	# Determine if a path of fixed length should be generated
	if tiles_in_path > 0:
		
		var x_change: int
		var y_change: int
		var adjusting_coords: bool
		
		for count in range(tiles_in_path):
			
			# Adjust position
			if coords.x < ending_coords.x:
				coords.x += character.Direction.RIGHT
			elif coords.x > ending_coords.x:
				coords.x += character.Direction.LEFT
				
			if coords.y < ending_coords.y:
				coords.y += character.Direction.DOWN
			elif coords.y > ending_coords.y:
				coords.y += character.Direction.UP
			
			# Iterate over each tilemap in tiles_used
			for tilemap in tiles_used:
				
				while coords in tiles_used[tilemap]:
					coords.x += 1
					coords.y += 1
				
			
			tile_coords_path.append(coords)

# A function that finds a valid tile for a Character to step on
func find_valid_tile():
	pass


# Process the Tile's designated callback function based on its type
func execute_tile_callback(tile: Tile, character: GameCharacter):
	
	# Update the Tile's world location if necessary
	var updated_tile = update_tile_world_location(tile, character)
	
	# Determine if the updated Tile is not null and if the Tile's type has a designated callback function to execute, then execute it
	if updated_tile and tile.type in tile_callbacks.keys():
		
		# Call the callback function for this Tile to process it with respect to the given Character
		tile_callbacks[tile.type].call(tile, character)


# Process the tiles nearby a given Character on the given Tilemap(s)
func process_nearby_tiles(character: GameCharacter, tiles_above: int):
	
	# Note: tiles_above is the number of tiles that should be processed above the one that the Character is standing on
	# 	Ex: if trying to process three tiles above the tile that the Character is standing on, tiles_above = 3
	
	# Store the coordinates of the Tiles that the Character is currently standing on and was previously standing on in Map Coordinates
	character.previous_tile_position = character.current_tile_position
	character.current_tile_position = tilemap_ground.local_to_map(character.global_position)
	
	# Create a list of Tile coordinates to process
	var tiles_to_process: Array[Tile] = []
	var tilemaps_to_process: Array[TileMapLayer] = [tilemap_ground, tilemap_terrain, tilemap_environment, tilemap_buildings_interior, tilemap_buildings_exterior]
	
	# Store a local reference to the x and y coordinates of the Character's current Tile position
	var x: int = character.current_tile_position.x
	var y: int = character.current_tile_position.y
	
	
	# Iterate over each of the tilemaps that should have their Tiles processed
	for map_type in tilemaps_to_process.size():
		
		# Add the Tiles in the row beneath the Character's current Tile into the list of Tiles to be processed
		tiles_to_process.append(Tile.new(tilemaps_to_process[map_type], map_type, Vector2i(x + 1, y + 1)))
		tiles_to_process.append(Tile.new(tilemaps_to_process[map_type], map_type, Vector2i(x, y + 1)))
		tiles_to_process.append(Tile.new(tilemaps_to_process[map_type], map_type, Vector2i(x - 1, y + 1)))
		
		# Add the Tiles in the row including the Character's current Tile into the list of Tiles to be processed
		tiles_to_process.append(Tile.new(tilemaps_to_process[map_type], map_type, Vector2i(x + 1, y)))
		tiles_to_process.append(Tile.new(tilemaps_to_process[map_type], map_type, Vector2i(x, y)))
		tiles_to_process.append(Tile.new(tilemaps_to_process[map_type], map_type, Vector2i(x - 1, y)))
		
		# Add the Tiles in the row above the Character's current Tile into the list of Tiles to be processed
		tiles_to_process.append(Tile.new(tilemaps_to_process[map_type], map_type, Vector2i(x + 1, y - 1)))
		tiles_to_process.append(Tile.new(tilemaps_to_process[map_type], map_type, Vector2i(x, y - 1)))
		tiles_to_process.append(Tile.new(tilemaps_to_process[map_type], map_type, Vector2i(x - 1, y - 1)))
		
		# Iterate (tiles_above - 1) times to add extra rows of Tiles to process above the Character
		for count in range(2, tiles_above + 1):
			
			# Note: Loop starts at 2 instead of 1 because one row above the Character is already processed automatically (y - 1), so the next row to be added must start at (y = 2).
			
			# Add the Tiles 'count' row(s) above the Character's current Tile into the list of Tiles to be processed
			tiles_to_process.append(Tile.new(tilemaps_to_process[map_type], map_type, Vector2i(x + 1, y - count)))
			tiles_to_process.append(Tile.new(tilemaps_to_process[map_type], map_type, Vector2i(x, y - count)))
			tiles_to_process.append(Tile.new(tilemaps_to_process[map_type], map_type, Vector2i(x - 1, y - count)))
	
	
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
	var current_tile = Tile.new(tilemap_terrain, Tile.MapType.TERRAIN, character.current_tile_position)
	
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
	if ledge_tile.type != "ledge_front":
		
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
	var tile_below = Tile.new(tilemap_terrain, Tile.MapType.TERRAIN, Vector2i(ledge_front_tile.coords_map.x, ledge_front_tile.coords_map.y + 1))
	
	# Determine if the Tile below is a ledge_back, which would indicate there is a platform at a lower elevation than the ledge_front_tile, then try to get the ledge_front height from there with the altitude counter incremented to 2 now
	if tile_below.type == "ledge_back":
		
		# Store a reference to the nearest ledge_front Tile
		var nearest_ledge_front = get_nearest_ledge_front(tile_below)
		
		# Set the altitude counter to equal the height of that ledge_front Tile
		altitude_counter = get_ledge_height(nearest_ledge_front, altitude_counter + 1)
		
		unload_tile(nearest_ledge_front)
		nearest_ledge_front = null
	
	
	# Otherwise, determine if the Tile below is ledge_front or a wall, which would indicate elevation, then calculate the altitude from that ledge_front with the altitude counter incremented
	elif tile_below.type == "ledge_front" or tile_below.type == "ledge_wall":
		
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
	var tile_below = Tile.new(tilemap_terrain, Tile.MapType.TERRAIN, Vector2i(tile.coords_map.x, tile.coords_map.y + 1))
	
	# Continue checking the Tile beneath the tile_below until it is a ledge_front type
	while not (tile_below.type == "ledge_front"):
		
		# Store the map coords of the tile_below
		var coords = tile_below.coords_map
		
		# Unload the tile_below
		unload_tile(tile_below)
		tile_below = null
		
		# Set a tile_below to be equal to the tile beneath the previous tile_below
		tile_below = Tile.new(tilemap_terrain, Tile.MapType.TERRAIN, Vector2i(coords.x, coords.y + 1))
		
		# Determine if the Tile below is a ledge_front tile, then return the Tile
		if tile_below.type == "ledge_front":
			break
	
	return tile_below



# A callback function to be played when a Ground Tile is being processed
func tile_callback_ground(tile: Tile, _character: GameCharacter):
	
	# Store a reference to the Tile in the same cell as the given tile but in the Terrain tilemap
	var terrain_tile = tile.get_same_cell(tilemap_terrain, Tile.MapType.TERRAIN)
	
	# Check if the Tile that is in the same cell coordinates in the terrain tilemap as this Tile in the ground tilemap is a 'ledge' Tile
	if terrain_tile.type == "ledge_back":
		
		# Set this current ground tile to be a ledge_ground tile because the tile on the terrain map is a ledge
		tilemap_ground.set_cell(tile.coords_map, 0, tilemap_ground.get_cell_atlas_coords(tile.coords_map), 1)
	
	
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
			var tile_above = Tile.new(tilemap_ground, Tile.MapType.GROUND, Vector2i(character.current_tile_position.x, character.current_tile_position.y - 1))
			
			if "ledge" not in tile_above.type:
				character.body_collider.disabled = false
				character.feet_collider.disabled = true
			
				# Determine if the Character is standing behind the Tile
				if character.global_position.y > tile.coords_local.y + tile.data.y_sort_origin:
					character.z_index = -1
					
					unload_tile(tile_above)
					tile_above = null
					return
			
			unload_tile(tile_above)
			tile_above = null
		
	character.z_index = 0



# A callback function to be played when a EnvironmentAsset Tile is being processed (Trees and Rocks are currently the only EnvironmentAssets as of 1/23/25)
func tile_callback_environment_asset(tile: Tile, character: GameCharacter):
	
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
