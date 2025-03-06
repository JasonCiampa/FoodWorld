extends FoodBuddy


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var text_press_f_for_berry_bot

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

# A custom ready function that is personally defined for Brittany. This is called in the default Food Buddy class's '_ready()' function
func ready():
	text_press_f_for_berry_bot = $"Press 'F' to Manage Berry Bot"
	health_texture_path = "res://images/ui/png/brittany-health.png"
	select_circle_texture_path = "res://images/ui/png/food-buddy-selection-brittany.png"
	
	# Set the stamina cost for each of Brittany's two abilities
	ability_stamina_cost = { 
		"Ability 1": [5, "Gradual"], 
		"Ability 2": [25, "Instant"] 
	}
	
	# Set Brittany's default speed and current speed
	speed_normal = 45
	speed_current = speed_normal
	
	radius_range = 16
	
	self.name = "Brittany"
	
	set_collision_value(collision_values["GROUND"])


# A custom process function that is personally defined for Brittany. This is called in the default FoodBuddy class's '_process()' function
func process(_delta: float):
	pass



# A custom physics_process function that is personally defined for Brittany. This is called in the default FoodBuddy class's '_physics_process()' function
func physics_process(_delta: float) -> void:
	pass



func jump_start():
	super()
		
	# Set Brittany to be in midair
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
