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
	
	# Set the stamina cost for each of Link's two abilities
	ability_stamina_cost = { 
		"Ability 1": [5, "Gradual"], 
		"Ability 2": [25, "Instant"] 
	}
	
	# Set Link's default speed and current speed
	speed_normal = 55
	speed_current = speed_normal
	
	radius_range = 24
	
	self.name = "Link"
	
	field_state_current = FieldState.FIGHT
	
	set_collision_value(collision_values["GROUND"])
	
	sprite.play("idle_front")


# A custom process function that is personally defined for Link. This is called in the default FoodBuddy class's '_process()' function
func process(_delta: float):
	pass


# A custom physics_process function that is personally defined for Link. This is called in the default FoodBuddy class's '_physics_process()' function
func physics_process(_delta: float) -> void:
	pass

# Updates the variables that keep track of previous and current movement direction
func update_movement_direction():
	
	# Store the current horizontal and vertical directions as the previous directions.
	direction_previous_horizontal = direction_current_horizontal
	direction_previous_vertical = direction_current_vertical
	
	direction_current_horizontal = sign(floor(velocity.x))
	direction_current_vertical = sign(floor(velocity.y))
	print("Horizontal: ", velocity.x)
	print("Vertical: ", velocity.y)
	print("")
	
	# Determine whether the Food Buddy is facing left or right, then flip the sprite horizontally based on the direction the Food Buddy is facing
	if direction_current_horizontal == Direction.RIGHT:
		sprite.flip_h = true
	elif direction_current_horizontal == Direction.LEFT:
		sprite.flip_h = false

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


func _on_sprite_animation_looped() -> void:
	update_animation()


func _on_sprite_animation_finished() -> void:
	update_animation()
