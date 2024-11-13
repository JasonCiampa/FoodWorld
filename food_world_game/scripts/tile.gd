extends Node2D


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------






# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var tile_callbacks : Dictionary = {
	
	"ledge" : Callable(TileData, "process_ledge")
	
}

var fart = "fart"
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

var tile_callback_ledge = func(character: Character, on_tile: bool = false):
	
	# Find out how to get this specific tile's local coordinates and compare it to the Player's bottom.
	# If the character isn't jumping, isn't on top of the tile (meaning they are below it
	#if not character.is_jumping and not on_tile and character.bottom_point.y < FILL IN THIS PART HERE!!!! :
		
		pass

func process_tiles_around(tilemap: TileMapLayer, character: Character):
	#var test = character.to_local(character.bottom_point)
	#print("Local X: " + str(test.x))
	#print("Local Y: " + str(test.y))
	#print(" ")
	
	var tile_coords = tilemap.local_to_map(character.center_point)
	var tile_x = tile_coords.x
	var tile_y = tile_coords.y
	
	#FIGURE OUT A SMART WAY TO ITERATE AND GET ACCESS TO THE SURROUNDING TILES
	for i in range(1, 4):
		var nearby 
		var tile_data = tilemap.get_cell_tile_data(tile_coords)
		
		#MAYBE PASS THE CHARACTER'S COORDS INTO THE CALLBACK AND USE THEM IN THE PROCESSING 
		if tile_data != null:
			var tile_callback = tile_callbacks[tile_data.get_custom_data("tile_type")]
			tile_callback.call(character)

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
