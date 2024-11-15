extends Node2D

class_name Tile

# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------






# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var tilemap: TileMapLayer
var coords_local: Vector2i
var coords_map: Vector2i
var data: TileData
var custom_data: Variant

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

func _init(tilemap: TileMapLayer, coords_map: Vector2i):
	self.tilemap = tilemap
	self.coords_map = coords_map
	
	get_data()
	get_local_coords()

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

# Returns a list of all the Tile Types for each tile surrounding the given Tile
func get_surrounding_tile_types(tile_coords: Vector2i):
	pass

# Returns the coordinates of this Tile in the local format
func get_local_coords():
	tilemap.map_to_local(coords_map)

# Attempts to fetch and store this Tile's data and returns true if successful or false if unsuccessful
func get_data() -> bool:
	
	# Get this Tile's data by locating it at the map coords on the tilemap
	var tile_data = tilemap.get_cell_tile_data(coords_map)
	
	# Determine if this Tile has any data, then store the data within the Tile and return true to indicate data was retrieved
	if tile_data:
		data = tile_data
		return true
	# Otherwise, this Tile doesn't have any data, so set data to null and return false to indicate that data was not retrieved
	else:
		data = null
		return false


# Attempts to fetch and store this Tile's custom data and returns true if successful or false if unsuccessful
func get_custom_data(data_name: String) -> Variant:
	
	# Determine if this Tile has no data, then return false to indicate there isn't any data
	if !data:
		return false
	
	# Get this Tile's custom data by searching for a custom field value
	var tile_custom_data = data.get_custom_data(data_name)

	# Determine if this Tile has any custom data, then store the custom data within the Tile and return true to indicate custom data was retrieved
	if tile_custom_data:
		custom_data = tile_custom_data
		return true
	
	# Otherwise, this Tile doesn't have any custom data, so set custom data to null and return false to indicate that custom data was not retrieved
	else:
		custom_data = null
		return false



# Attempts to fetch, store, and return the Tile in the cell with map coords equivalent this Tile's coords, but in a different Tilemap
func get_same_cell(other_tilemap: TileMapLayer) -> Tile:
	return Tile.new(other_tilemap, coords_map)


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
