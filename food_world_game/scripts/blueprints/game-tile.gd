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
var type: String
var location: String

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when this class's '.new()' function is invoked
func _init(_tilemap: TileMapLayer, _coords_map: Vector2i):
	
	self.tilemap = _tilemap
	self.coords_map = _coords_map
	
	set_data()
	set_local_coords()
	
	# Determine if there is Tile data, then set the type of the Tile
	if data != null:
		self.type = data.get_custom_data("tile_type")
		self.location = data.get_custom_data("location")
	else:
		self.type = ""
		self.location = ""

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Sets the coordinates of this Tile in the local format
func set_local_coords():
	coords_local = tilemap.map_to_local(coords_map)



# Attempts to fetch and set this Tile's data variable and returns true if successful or false if unsuccessful
func set_data() -> bool:
	
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



# Attempts to fetch, store, and return the Tile in the cell with map coords equivalent this Tile's coords, but in a different Tilemap
func get_same_cell(other_tilemap: TileMapLayer) -> Tile:
	return Tile.new(other_tilemap, coords_map)

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
