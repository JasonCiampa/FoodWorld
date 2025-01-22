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

var tilemap_ground: TileMapLayer
var tilemap_environment: TileMapLayer
var tilemap_terrain: TileMapLayer

var tilemap_pits: TileMapLayer
var tilemap_water: TileMapLayer
var tilemap_sky: TileMapLayer

# A dictionary that maps Tile types to their designated callback functions for processing
var tile_callbacks : Dictionary = {
	"ledge_front" : tile_callback_ledge_front,
	"ledge_front_elevated" : tile_callback_ledge_front_elevated,
	
	"ledge_back" : tile_callback_ledge_back,
	"ledge_back_elevated" : tile_callback_ledge_back_elevated,
	
	"ledge_ground" : tile_callback_ledge_ground,
	"ledge_ground_elevated" : tile_callback_ledge_ground_elevated,
	
	"ground" : tile_callback_ground,
	
	"nature_asset" : tile_callback_nature_asset
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
func process_nearby_tiles(tilemaps: Array[TileMapLayer], character: GameCharacter, tiles_out: int):
	
	# Store the coordinates of the Tiles that the Character is currently standing on and was previously standing on in Map Coordinates
	character.previous_tile_position = character.current_tile_position
	character.current_tile_position = tilemaps[0].local_to_map(character.global_position)
	
	# Create a list of Tile coordinates to process
	var tiles_to_process: Array[Tile] = []
	
	# Store a local reference to the x and y coordinates of the Character's current Tile position
	var x: int = character.current_tile_position.x
	var y: int = character.current_tile_position.y
	
	# Iterate 'tiles_out' times so that all desired Tiles will be processed (lower tile_out values = less Tiles processed)
	for count in range(1, tiles_out + 1):
		
		# Iterate over each of the tilemaps that should have their Tiles processed
		for tilemap in tilemaps:
		
			# Retrieve the coordinates for the Tiles to the left and right of the Character's current Tile
			tiles_to_process.append(Tile.new(tilemap, Vector2i(x + count, y)))
			tiles_to_process.append(Tile.new(tilemap, Vector2i(x - count, y)))
			
			# Retrieve the coordinates for the Tiles diagonally above the Character's current Tile
			tiles_to_process.append(Tile.new(tilemap, Vector2i(x - count, y - count)))
			tiles_to_process.append(Tile.new(tilemap, Vector2i(x + count, y - count)))
			
			# Retrieve the coordinates for the Tiles diagonally below the Character's current Tile
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
	
	
	# Process each of the Tiles using their coordinates that were stored in the list
	for tile in range(tiles_to_process.size() - 1, -1, -1):
		
		# Execute the callback function associated with the type of Tile of this iteration
		execute_tile_callback(tiles_to_process[tile], character)
		
		# Unload the tile
		tiles_to_process[tile].free()
		tiles_to_process[tile] = null
	
	
	# Iterate over each of the tilemaps that should have their Tiles processed
	for tilemap in tilemaps:
		
		# Store references to the Tiles that are above and below the Tile that the Character is currently standing on
		var tile_current = Tile.new(tilemap, character.current_tile_position)
		var tile_above = Tile.new(tilemap, Vector2i(character.current_tile_position.x, character.current_tile_position.y - 1))
		var tile_below = Tile.new(tilemap, Vector2i(character.current_tile_position.x, character.current_tile_position.y + 1))
		
		# Determine if the Character is standing closer to the Tile above them than the Tile below them, then execute the above Tile's callback function
		if character.global_position.distance_to(tile_above.coords_local) < character.global_position.distance_to(tile_below.coords_local):
			execute_tile_callback(tile_above, character)
		
		# Otherwise the Character must be standing closer to the Tile below them, so execute the below Tile's callback function
		else:
			execute_tile_callback(tile_below, character)
		
		# Execute the callback function for the Tile that the Character is currently standing on
		execute_tile_callback(tile_current, character)
		
		# Unload each of the Tiles
		unload_tile(tile_current)
		unload_tile(tile_above)
		unload_tile(tile_below)
		tile_current = null
		tile_above = null
		tile_below = null



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
			return tile_below



# A callback function to be played when a Ledge Front Elevated Tile is being processed
func tile_callback_ledge_front(tile: Tile, character: GameCharacter):
	
	# Determine if the Character is not jumping, then adjust their collision value
	if !character.is_jumping:
		
		# Set the Character to collide with layer 1, disable their body collider, and enable their feet collider
		character.set_collision_value(1)
		character.body_collider.disabled = true
		character.feet_collider.disabled = false
	
	# Determine if the Character is on a platform, then set this cell to have the y-sort origin necessary when the Character is on the platform
	if character.on_platform:
		tilemap_terrain.set_cell(tile.coords_map, 0, tilemap_terrain.get_cell_atlas_coords(tile.coords_map), 1)



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



# A callback function to be played when a Ledge Back Tile is being processed
func tile_callback_ledge_back(tile: Tile, character: GameCharacter):
	
	# Determine if the Character is not jumping, then adjust their collision value
	if !character.is_jumping:
		
		# Set the Character to collide with layer 1, enable their body collider, and disable their feet collider
		character.set_collision_value(1)
		character.body_collider.disabled = false
		character.feet_collider.disabled = true
	
	
	# Determine if the Character is on a platform, then set this cell to have the y-sort origin necessary when the Character is on the platform
	if character.on_platform:
		tilemap_terrain.set_cell(tile.coords_map, 0, tilemap_terrain.get_cell_atlas_coords(tile.coords_map), 1)



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
	if character.on_platform:
		tilemap_ground.set_cell(tile.coords_map, 0, tilemap_ground.get_cell_atlas_coords(tile.coords_map), 2)



# A callback function to be played when a Ledge-Grass-Elevated Tile is being processed
func tile_callback_ledge_ground_elevated(tile: Tile, character: GameCharacter):
	
	# Determine if the Character is on the ground, then set this cell to have the y-sort origin necessary when the Character is on the ground
	if !character.on_platform:
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



# A callback function to be played when a NatureAsset Tile is being processed
func tile_callback_nature_asset(tile: Tile, character: GameCharacter):
	
	# Determine if the Character is not jumping, then adjust their collision value
	if !character.is_jumping:
		
		# Set the Character to collide with layer 1, enable their body collider, and disable their feet collider
		character.set_collision_value(1)
		character.body_collider.disabled = true
		character.feet_collider.disabled = false
	
	
	# Determine if the nature asset tile doesn't have an actual nature object associated with it, then create one to associate with the tile
	if tile.connected_object == null:
		tile.data.set_custom_data("connected_object", EnvironmentAsset.new(tile.coords_local))
		tile.connected_object = tile.data.get_custom_data("connected_object")
		
	# Otherwise, the nature asset tile already is connected to an actual nature object, so return
	else:
		print(tile.connected_object.global_position)
		return



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
