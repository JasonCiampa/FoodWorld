extends FoodBuddy


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# A custom ready function that is personally defined for Link. This is called in the default Food Buddy class's '_ready()' function
func ready():
	
	health_texture_path = "res://images/ui/png/link-health.png"
	select_circle_texture_path = "res://images/ui/png/food-buddy-selection-link.png"
	dialogue_texture = load("res://images/ui/png/dialogue-link.png")
	
	# Set the stamina cost for each of Link's two abilities
	ability_stamina_cost = { 
		"Ability 1": [5, "Gradual"], 
		"Ability 2": [25, "Instant"] 
	}
	
	# Set Link's default speed and current speed
	speed_normal = 40
	speed_current = speed_normal
	
	radius_range = 30
	
	self.name = "Link"
	
	field_state_current = FieldState.FOLLOW
	
	set_collision_value(collision_values["GROUND"])
	
	sprite.play("idle_front")


# A custom process function that is personally defined for Link. This is called in the default FoodBuddy class's '_process()' function
func process(_delta: float):
	pass


# A custom physics_process function that is personally defined for Link. This is called in the default FoodBuddy class's '_physics_process()' function
func physics_process(_delta: float) -> void:
	pass



func jump_start():
	super()
		
	# Set Link to be in midair
	set_collision_value(collision_values["MIDAIR"])

func jump_end():
	super()
	
	if current_altitude == 0:
		set_collision_value(collision_values["GROUND"])
		on_platform = false
	else:
		set_collision_value(collision_values["PLATFORM"])
		on_platform = true

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
