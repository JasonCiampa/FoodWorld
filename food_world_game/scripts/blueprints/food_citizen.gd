class_name FoodCitizen

extends Character



# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Hitbox #
var hitbox_interaction: Area2D

# Press 'E' To Interact Label #
var label_e_to_interact: Label

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
	
	# Store references to the Citizen's Nodes
	sprite = $AnimatedSprite2D
	animation_player = $AnimationPlayer
	on_screen_notifier = $VisibleOnScreenNotifier2D
	hitbox_damage = $"Damage Hitbox"
	hitbox_interaction = $"Interaction Hitbox"
	label_e_to_interact = $"Press 'E' to Interact"
	
	self.name = "Citizen"
	
	# Call the custom ready function that subclasses may have defined manually
	ready()
	
	update_center_point()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if not paused:
		#print(target_distance)
		# Call the custom process function that subclasses may have defined manually
		process(delta)



# Called every frame. Updates the Enemy's physics
func _physics_process(delta: float) -> void:
	
	if not paused:
		
		#target_player.emit(self)
		#move_towards_target.emit(self, target, 40)
		move_and_slide()
	
	update_center_point()

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------






# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





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
