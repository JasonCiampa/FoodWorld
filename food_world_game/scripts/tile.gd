extends Node2D


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------






# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var tile_callbacks : Dictionary = {
	
	"ledge" : tile_callback_ledge
	
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
var tile_callback_ledge = func(tile_coords: Vector2i, character: Character):
	
	# Determine if the Character is horizontally in-range of the tile, then determine their vertical positioning towards the Tile
	if tile_coords.x - 8 < character.position.x - character.width / 2 or character.position.x + character.width / 2 < tile_coords.x + 8:
		
		# Determine if the Character is directly beneath the tile
		if tile_coords.y - 8 < character.position.y and character.position.y < tile_coords.y + 8:
			
			# Determine if the Character's center point is past the tile's center point and determine if the Character is jumping
			if character.position.y < tile_coords.y:
				
				# Determine if the Character is NOT jumping, then adjust the Character's y-position back to the center of the tile because the Character should have to jump above a ledge tile
				if not character.is_jumping:
					character.position.y = tile_coords.y
					
	print(character.bottom_point.y)
	print(tile_coords.y)


func process_tile_data(tilemap: TileMapLayer, tile_map_coords: Vector2i, character: Character):
	
	# Attempt to fetch and store this Tile's data using the Tile's map coords
	var tile_data = tilemap.get_cell_tile_data(tile_map_coords)
	
	# Determine if Tile data was fetched, then call the Tile's appropriate callback function
	if tile_data != null:
		
		# Store a reference to the variable holding the callback function by accessing it from the callbacks dictionary using the Tile's data as the key
		var tile_callback = tile_callbacks[tile_data.get_custom_data("tile_type")]
		
		# Store the coordinates of the Tile that the Character is standing on in Local Coordinates
		var tile_local_coords = tilemap.map_to_local(tilemap.local_to_map(character.bottom_point))
		
		# Determine if the Tile data matched a callback function, then call that function
		if tile_callback != null:
			tile_callback.call(tile_local_coords, character)


# number of layers of tiles to process as a parameter??
func process_tiles_around(tilemap: TileMapLayer, character: Character):
	
	# Store the coordinates of the Tile that the Character is standing on in Map Coordinates
	var tile_map_coords = tilemap.local_to_map(character.bottom_point)
	process_tile_data(tilemap, tile_map_coords, character)
	
	var top_tile_coords = Vector2i(tile_map_coords.y + 1, tile_map_coords.y)
	var bottom_tile_coords = Vector2i(tile_map_coords.y - 1, tile_map_coords.y)	
	process_tile_data(tilemap, top_tile_coords, character)
	process_tile_data(tilemap, bottom_tile_coords, character)
	
	var left_tile_coords = Vector2i(tile_map_coords.x - 1, tile_map_coords.y)
	var right_tile_coords = Vector2i(tile_map_coords.x + 1, tile_map_coords.y)
	process_tile_data(tilemap, left_tile_coords, character)
	process_tile_data(tilemap, right_tile_coords, character)
	
	var top_left_tile_coords = Vector2i(tile_map_coords.x - 1, tile_map_coords.y + 1)
	var top_right_tile_coords = Vector2i(tile_map_coords.x + 1, tile_map_coords.y + 1)
	process_tile_data(tilemap, top_left_tile_coords, character)
	process_tile_data(tilemap, top_right_tile_coords, character)
	
	var bottom_left_tile_coords = Vector2i(tile_map_coords.x - 1, tile_map_coords.y - 1)
	var bottom_right_tile_coords = Vector2i(tile_map_coords.x + 1, tile_map_coords.y - 1)
	process_tile_data(tilemap, bottom_left_tile_coords, character)
	process_tile_data(tilemap, bottom_right_tile_coords, character)


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
