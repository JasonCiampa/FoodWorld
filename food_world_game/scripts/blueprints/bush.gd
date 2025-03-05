class_name Bush

extends InteractableAsset


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------






# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var RNG = RandomNumberGenerator.new()

var berries: int
var berry_regen_timer: float
var berry_regen_timer_length: int = 5

var berries_max: int = 5

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# Called every frame. Updates the Bush's physics
func _physics_process(_delta: float) -> void:
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# A custom function to execute the Bush's logic for when the Player interacts with them
func interact_with_player(player: Player, _delta: float):
	
	while player.berries < player.berries_max and berries > 0:
		player.berries += 1
		berries -= 1
	
	label_e_to_interact.hide()
	
	player.is_interacting = false
	
	berry_regen_timer = berry_regen_timer_length
	# Trigger berry collection animation

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# ABSTRACT FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# A custom ready function that each Bush subclass should personally define. This is called in the default Bush class's '_ready()' function
func ready():
	self.name = "Bush"
	
	berry_regen_timer = berry_regen_timer_length
	berries = RNG.randi_range(1, berries_max)




# A custom process function that each Bush subclass should personally define. This is called in the default Bush class's '_process()' function
func process(delta: float):
	
	# Determine if there are less than 5 berries and that the regeneration period for a berry has completed
	if berries < berries_max and berry_regen_timer <= 0:
		
		# Regenerate 1 berry in this bush
		berries += 1
		berry_regen_timer = berry_regen_timer_length
	
	# Otherwise, the berry timer needs to continue decrementing
	else:
		berry_regen_timer -= delta



# A custom physics_process function that each Bush subclass should personally define. This is called in the default Bush class's '_physics_process()' function
func physics_process(_delta: float) -> void:
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
