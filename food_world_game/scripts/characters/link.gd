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
	select_circle_texture_path_normal = "res://images/ui/png/food-buddy-selection-link.png"
	select_circle_texture_path_pressed = "res://images/ui/png/food-buddy-selection-link-selected.png"
	dialogue_texture = load("res://images/ui/png/dialogue-link.png")
	
	# Set the stamina cost for each of Link's two abilities
	ability_stamina_cost = { 
		"Ability 1": [5, "Gradual"], 
		"Ability 2": [25, "Instant"] 
	}
	
	ability_damage = { 
		"Solo": 6.5, 
		"Ability 1": 20
	}
	
	# Set Link's default speed and current speed
	speed_normal = 40
	speed_current = speed_normal
	
	radius_range = 35
	tile_process_shape = Vector2i(3, 5)
	
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


# Throw a punch as the Player
func use_ability1(player: Player, _delta: float):
	if !player.using_ability:
		if player.use_stamina(ability_damage["Ability 1"]):
			
			player.using_ability = true 
			
			player.update_animation()
			print("The Player used the sausage whip!")


# Throw a juicebox while on the player's back
func use_ability2(player: Player, _delta: float):
	if !player.using_ability:
		if player.use_stamina(ability_damage["Ability 1"]):
			
			player.using_ability = true 
			
			player.update_animation()
			print("The Player used the sausage whip!")
