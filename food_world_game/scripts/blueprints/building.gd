class_name Building

extends InteractableAsset


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

signal player_enter
signal player_exit

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------






# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var resource: Resource

var usual_occupants: Array
var current_occupants: Array

var playerEntering: bool = false
var playerExiting: bool = false

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# Called every frame. Updates the Building's physics
func _physics_process(_delta: float) -> void:
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# A custom function to execute the Building's logic for when the Player interacts with them
func interact_with_player(player: Player, delta: float):
	
	# If the Player is not one of the occupants of the house, emit the enter signal because they're entering by interacting with the door
	if player not in current_occupants:
		player_enter.emit(self, delta)
		playerEntering = true
	
	
	# Otherwise, the Player is already one of the occupants of the house, so emit the player_enter signal because they're leaving by interacting with the door
	else:
		player_exit.emit(self, delta)
		playerExiting = true
	
	
	
	
		# start timer (2 seconds?), after timer fade back in to new tilemap


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# ABSTRACT FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# A custom ready function that each Building subclass should personally define. This is called in the default Building class's '_ready()' function
func ready():
	pass



# A custom process function that each Building subclass should personally define. This is called in the default Building class's '_process()' function
func process(_delta: float):
	pass


# A custom physics_process function that each Building subclass should personally define. This is called in the default Building class's '_physics_process()' function
func physics_process(_delta: float) -> void:
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
