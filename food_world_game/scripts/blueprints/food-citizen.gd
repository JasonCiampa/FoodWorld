class_name FoodCitizen

extends InteractableCharacter


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	
	self.name = "Citizen"
	
	# Call the custom ready function that subclasses may have defined manually
	ready()
	
	update_dimensions()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if not paused:
		
		# Call the custom process function that subclasses may have defined manually
		process(delta)



# Called every frame. Updates the Enemy's physics
func _physics_process(_delta: float) -> void:
	
	if not paused:
		
		#target_player.emit(self)
		#get_target_distance.emit(self, target)
		move_and_slide()
	
	update_dimensions()

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ABSTRACT FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# A custom ready function that each Food Citizen subclass should personally define. This is called in the default Food Citizen class's '_ready()' function
func ready():
	pass



# A custom process function that each Food Citizen subclass should personally define. This is called in the default Food Citizen class's '_process()' function
func process(_delta: float):
	pass



# A custom physics_process function that each Food Citizen subclass should personally define. This is called in the default Food Citizen class's '_physics_process()' function
func physics_process(_delta: float) -> void:
	pass



# A custom function to execute the Food Citizen's logic for when the Player interacts with them
func interact_with_player(player: Player, _characters_in_range: Array[Node2D], _delta: float) -> Array[Node2D]:
	
	# Create a list that will store all of the Characters that should be involved in the conversation that is about to start
	var characters_to_involve: Array[Node2D] = [player, self]
	
	# Check some sort of Game-Story-Tracking Variable to determine if any characters should be added to or removed from the list so that a specific Dialogue file can be be played at specific moments of the game
	# If location == SweetsWorldCandyCastle and "Link" in characters_in_range:
		# characters_to_involve.append(characters_in_range["Link"])
	
	#return characters_to_involve
	
	# Include the Player's Food Buddies in the conversation if they're in-range
	#for character in characters_in_range:
		#if character is FoodBuddy:
			#characters_to_involve.append(character)
	
	return characters_to_involve

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
