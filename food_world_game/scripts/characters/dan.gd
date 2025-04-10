extends FoodBuddy


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var sprinkle_sprite: AnimatedSprite2D

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var animation_callbacks: Dictionary = {
	
	"ability_sideways" : ability_sideways_animation
}

var speed_sprinting: int

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# A custom ready function that is personally defined for Dan. This is called in the default Food Buddy class's '_ready()' function
func ready():
	
	sprinkle_sprite = $"AnimatedSpriteSprinkles2D"
	
	field_state_current = FieldState.FIGHT
	
	health_texture_path = "res://images/ui/png/dan-health.png"
	select_circle_texture_path = "res://images/ui/png/food-buddy-selection-dan.png"
	
	# Set the stamina cost for each of Dan's two abilities
	ability_stamina_cost = { 
		"Ability 1": [5, "Gradual"], 
		"Ability 2": [25, "Instant"] 
	}
	
	# Set Dan's default speed and current speed
	speed_normal = 65
	speed_sprinting = 100
	speed_current = speed_normal
	
	radius_range = 60
	
	self.name = "Dan"
	
	field_state_current = FieldState.FIGHT
	
	set_collision_value(collision_values["GROUND"])
	
	sprite.play("idle_front")


# A custom process function that is personally defined for Dan. This is called in the default FoodBuddy class's '_process()' function
func process(_delta: float):
	#print(sprite.animation)
	
	if sprite.animation in animation_callbacks.keys():
		animation_callbacks.get(sprite.animation).call()



# A custom physics_process function that is personally defined for Dan. This is called in the default FoodBuddy class's '_physics_process()' function
func physics_process(_delta: float) -> void:
	pass



func jump_start():
	super()
		
	# Set Dan to be in midair
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


# A callback function that should execute repeatedly while the Food Buddy is in the FIGHT FieldState
func fight_field_state_callback() -> void:
	
	# Determine if the Food Buddy has an alive target Enemy currently, then move towards it.
	if target != null and target is Enemy and target.alive:
		generate_path()
	
	# Otherwise, move the Food Buddy towards the Player while they look for a new target.
	else:
		
		target_closest_enemy.emit(self)
		
		if target == null or !target.alive:
			
			target_player.emit(self)
			
			target_distance = global_position.distance_to(target.global_position)
			
			if target.current_altitude != 0 or target_distance <= target.radius_range:
				velocity.x = 0
				velocity.y = 0
				return
		
		generate_path()
	
	
	# Determine if the Food Buddy is in range of an Enemy, then make them stop moving and launch their solo attack
	if target is Enemy:
		
		if target_distance <= float(200):
			
			if timer_ability_cooldown.is_stopped() and !using_ability:
				using_ability = true
				current_animation_name = "ability"
				sprite.play("ability_" + current_direction_name)
				target_distance = global_position.distance_to(target.global_position)
				speed_current = speed_sprinting
				generate_path()
			
			if target_distance <= float((radius_range + target.radius_range) / 2):
				velocity.x = -50
				velocity.y = 0
				# HERE
				# It seems like there is some other line of code that is still adjusting the donut's velocity towards the target despite it being reversed to -50


func _on_sprite_animation_looped() -> void:
	
	if "ability" in sprite.animation and timer_ability_cooldown.is_stopped() and target_distance <= float((radius_range + target.radius_range) / 2):
		
		use_ability_solo.emit(self, ability_damage["Solo"])
		timer_ability_cooldown.start(6.5)
		sprite.play("idle_" + current_direction_name)
		current_animation_name = "idle"
		speed_current = speed_normal
		
		velocity.x = 0
		velocity.y = 0
		print("ANIMATION LOOP DE LOOPED")
		if target.alive:
			using_ability = true
		else:
			using_ability = false
		
		return
	
	update_animation()


func ability_sideways_animation() -> void:
	
	# If sprite is facing/moving right, put trail on the left
	if sprite.flip_h:
		sprinkle_sprite.play("sprinkle_trail_left")
		animation_player.play("rotate_right_fast")
	
	# If sprite is facing/moving left, put trail on the right
	else:
		sprinkle_sprite.play("sprinkle_trail_right")
		animation_player.play("rotate_left_fast")


func _on_sprite_animation_changed() -> void:
	
	if "ability" not in sprite.animation:
		
		# If sprite is facing/moving right, put trail on the left
		if sprite.flip_h:
			sprinkle_sprite.play("nothing")
			animation_player.play("RESET")
		
		# If sprite is facing/moving left, put trail on the right
		else:
			sprinkle_sprite.play("nothing")
			animation_player.play("RESET")
