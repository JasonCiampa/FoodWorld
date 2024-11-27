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
	"ledge_front" : tile_callback_ledge_front,
	"ledge_front_elevated" : tile_callback_ledge_front_elevated,
	"ledge_back" : tile_callback_ledge_back,
	"ledge_back_elevated" : tile_callback_ledge_back_elevated,
	"ledge_grass" : tile_callback_ledge_grass,
	"ledge_grass_elevated" : tile_callback_ledge_grass_elevated,
	"grass" : tile_callback_grass,
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
	var tile_type = tile.get_custom_data("tile_type")
	
	# Determine if the Tile's custom data (tile type) has a designated callback function to execute, then execute it
	if tile_type != null:
		
		if tile_type == "ledge_platform" or tile_type == "ledge_wall":
			return
		
		# Call the callback function for this Tile
		tile_callbacks[tile_type].call(tile, character)



# Process the tiles nearby a given Character on the given Tilemap
func process_nearby_tiles(tilemap: TileMapLayer, character: Character, tiles_out: int):
	
	# Store the coordinates of the Tiles that the Character is currently standing on and was previously standing on in Map Coordinates
	character.previous_tile_position = character.current_tile_position
	character.current_tile_position = tilemap.local_to_map(character.position)

	# Store references to the Tiles that are above and below the Tile that the Character is currently standing on
	var tile_above = Tile.new(tilemap, Vector2i(character.current_tile_position.x, character.current_tile_position.y - 1))
	var tile_below = Tile.new(tilemap, Vector2i(character.current_tile_position.x, character.current_tile_position.y + 1))
	
	# Determine if the Character is standing closer to the Tile above them than the Tile below them, then execute the above Tile's callback function
	if character.position.distance_to(tile_above.coords_local) < character.position.distance_to(tile_below.coords_local):
		execute_tile_callback(tile_above, character)
	
	# Otherwise the Character must be standing closer to the Tile below them, so execute the below Tile's callback function
	else:
		execute_tile_callback(tile_below, character)



# A function used on any type of ledge tile to return its altitude
func get_altitude(ledge_tile: Tile):
	
	# Store a reference to the given Tile's type
	var tile_type = ledge_tile.get_custom_data("tile_type")
	
	# Determine if the given Tile is not actually a ledge_tile, then return 0 because only Tiles with a 'ledge' typing have altitude
	if !tile_type or "ledge" not in tile_type:
		return 0
	
	# Determine if the given ledge_tile is not a front ledge, then fetch the closest front ledge, get it's height, and return that as the altitude
	if tile_type != "ledge_front" and tile_type != "ledge_front_elevated":
		
		var nearest_ledge_front = get_nearest_ledge_front(ledge_tile)
		var altitude = get_ledge_height(nearest_ledge_front, 1)
		
		unload_tile(nearest_ledge_front)
		nearest_ledge_front = null
		
		return altitude
	
	# Otherwise the given ledge_tile is a ledge_front Tile, so return it's height as the altitude
	else:
		return get_ledge_height(ledge_tile, 1)



# Determines the altitude of a given ledge_front Tile
func get_ledge_height(ledge_front_tile: Tile, altitude_counter: int):
	
	# Store a reference to the Tile below the given ledge_front_tile
	var tile_below = Tile.new(tilemap_terrain, Vector2i(ledge_front_tile.coords_map.x, ledge_front_tile.coords_map.y + 1))
	var tile_below_type = tile_below.get_custom_data("tile_type")
	
	# Determine if the Tile below is a ledge_platform, which would indicate there is a platform at a lower elevation than the ledge_front_tile, then try to get the ledge_front height from there with the altitude counter incremented to 2 now
	if tile_below_type == "ledge_platform":
		
		var nearest_ledge_front = get_nearest_ledge_front(tile_below)
		
		altitude_counter = get_ledge_height(nearest_ledge_front, altitude_counter + 1)
		
		unload_tile(nearest_ledge_front)
		nearest_ledge_front = null
	
	
	# Otherwise, determine if the Tile below is ledge_front or a wall, which would indicate elevation, then try to get the height from that ledge_front with the altitude counter incremented to 2 now
	elif tile_below_type == "ledge_front" or tile_below_type == "ledge_front_elevated" or tile_below_type == "ledge_wall":
		
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
	
	while not (tile_below.get_custom_data("tile_type") == "ledge_front" or tile_below.get_custom_data("tile_type") == "ledge_front_elevated"):
		
		var coords = tile_below.coords_map
		unload_tile(tile_below)
		tile_below = null
		
		tile_below = Tile.new(tilemap_terrain, Vector2i(coords.x, coords.y + 1))
		
		# Determine if the Tile below is a ledge_front tile, then return the Tile
		if tile_below.get_custom_data("tile_type") == "ledge_front" or tile_below.get_custom_data("tile_type") == "ledge_front_elevated":
			return tile_below
	
	return tile_below



# A callback function to be played when a Ledge Front Elevated Tile is being processed
func tile_callback_ledge_front(tile: Tile, character: Character):
	
	if !character.is_jumping:
		
		# Set the Character to collide with layer 1, disable their body collider, and enable their feet collider
		character.set_collision_value(1)
		character.body_collider.disabled = true
		character.feet_collider.disabled = false
	
	# Determine if the Character is on a platform, then set this cell to have the y-sort origin necessary when the Character is on the platform
	if character.on_platform:
		tilemap_terrain.set_cell(tile.coords_map, 0, tilemap_terrain.get_cell_atlas_coords(tile.coords_map), 1)



# A callback function to be played when a Ledge Front Elevated Tile is being processed
func tile_callback_ledge_front_elevated(tile: Tile, character: Character):
	
	if !character.is_jumping:
		
		# Set the Character to collide with layer 3, disable their body collider, and enable their feet collider
		character.set_collision_value(3)
		character.body_collider.disabled = true
		character.feet_collider.disabled = false
	
	# Determine if the Character is on the ground, then set this cell to have the y-sort origin necessary when the Character is on the ground
	if !character.on_platform:
		tilemap_terrain.set_cell(tile.coords_map, 0, tilemap_terrain.get_cell_atlas_coords(tile.coords_map))



# A callback function to be played when a Ledge Front Elevated Tile is being processed
func tile_callback_ledge_back(tile: Tile, character: Character):
	
	if !character.is_jumping:
		
		# Set the Character to collide with layer 1, enable their body collider, and disable their feet collider
		character.set_collision_value(1)
		character.body_collider.disabled = false
		character.feet_collider.disabled = true
	
	
	# Determine if the Character is on a platform, then set this cell to have the y-sort origin necessary when the Character is on the platform
	if character.on_platform:
		tilemap_terrain.set_cell(tile.coords_map, 0, tilemap_terrain.get_cell_atlas_coords(tile.coords_map), 1)



# A callback function to be played when a Ledge Front Elevated Tile is being processed
func tile_callback_ledge_back_elevated(tile: Tile, character: Character):
	
	if !character.is_jumping:
		
		# Set the Character to collide with layer 1, enable their body collider, and disable their feet collider
		character.set_collision_value(1)
		character.body_collider.disabled = false
		character.feet_collider.disabled = true
	
	# Determine if the Character is on the ground, then set this cell to have the y-sort origin necessary when the Character is on the ground
	if !character.on_platform:
		tilemap_terrain.set_cell(tile.coords_map, 0, tilemap_terrain.get_cell_atlas_coords(tile.coords_map))



# A callback function to be played when a Ledge-Grass Tile is being processed
func tile_callback_ledge_grass(tile: Tile, character: Character):
	
	# Determine if the Character is on a platform, then set this cell to have the y-sort origin necessary when the Character is on the platform
	if character.on_platform:
		tilemap_ground.set_cell(tile.coords_map, 0, tilemap_ground.get_cell_atlas_coords(tile.coords_map), 2)



# A callback function to be played when a Ledge-Grass-Elevated Tile is being processed
func tile_callback_ledge_grass_elevated(tile: Tile, character: Character):
	
	# Determine if the Character is on the ground, then set this cell to have the y-sort origin necessary when the Character is on the ground
	if !character.on_platform:
		tilemap_ground.set_cell(tile.coords_map, 0, tilemap_ground.get_cell_atlas_coords(tile.coords_map), 1)



# A callback function to be played when a Grass Tile is being processed
func tile_callback_grass(tile: Tile, character: Character):
	
	# Store a reference to the Tile in the same cell as the given tile but in the Terrain tilemap
	var terrain_tile = tile.get_same_cell(tilemap_terrain)
	var terrain_tile_type = terrain_tile.get_custom_data("tile_type")
	
	# Check if the the Tile that is in the same cell coordinates as this Tile but in the terrain tile map is a 'ledge' tile
	if terrain_tile_type != null and terrain_tile_type != "ledge_wall":
		
		# Determine if the Character is on a platform, then set this cell to have the y-sort origin necessary when the Character is on the platform
		if character.on_platform:
			
			# Set this current grass tile to be a ledge_grass tile because the tile on the terrain map is a ledge
			tilemap_ground.set_cell(tile.coords_map, 0, tilemap_ground.get_cell_atlas_coords(tile.coords_map), 2)
		
		else:
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
