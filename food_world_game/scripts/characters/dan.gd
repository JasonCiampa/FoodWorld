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
	
	"ability_sideways" : ability_sideways_animation,
	"moving_sideways"  : moving_sideways_animation
}

var speed_sprinting: int

var target_point: Vector2
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# A custom ready function that is personally defined for Dan. This is called in the default Food Buddy class's '_ready()' function
func ready():
	
	sprinkle_sprite = $"AnimatedSpriteSprinkles2D"
	
	field_state_current = FieldState.FIGHT
	
	health_texture_path = "res://images/ui/png/dan-health.png"
	select_circle_texture_path_normal = "res://images/ui/png/food-buddy-selection-dan.png"
	select_circle_texture_path_pressed = "res://images/ui/png/food-buddy-selection-dan-selected.png"
	dialogue_texture = load("res://images/ui/png/dialogue-dan.png")
	
	# Set the stamina cost for each of Dan's two abilities
	ability_stamina_cost = { 
		"Ability 1": [25, "Gradual"], 
		"Ability 2": [25, "Gradual"] 
	}
	
	ability_damage = { 
		"Solo": 10, 
	}
	
	# Set Dan's default speed and current speed
	speed_normal = 45
	speed_sprinting = 85
	speed_current = speed_normal
	
	radius_range = 50
	
	tile_process_shape = Vector2i(3, 10)
	
	self.name = "Dan"
	
	field_state_current = FieldState.FOLLOW
	
	set_collision_value(collision_values["GROUND"])
	
	sprite.play("idle_front")


# A custom process function that is personally defined for Dan. This is called in the default FoodBuddy class's '_process()' function
func process(_delta: float):
	
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
	
	if paused or level_up:
		return
	
	# Determine if the Food Buddy has an alive target Enemy currently, then move towards it.
	if target != null and target is Enemy and target.alive:
		
		if timer_ability_cooldown.is_stopped() and !using_ability:
			using_ability = true
			current_animation_name = "ability"
			if current_direction_name != "":
				sprite.play("ability_" + current_direction_name)
			else:
				sprite.play("ability_front")
			target_distance = global_position.distance_to(target.global_position)
			speed_current = speed_sprinting
			generate_path()
		
		if !timer_ability_cooldown.is_stopped() and using_ability:
			generate_path(target_point)
		else:
			generate_path()
			speed_current = speed_sprinting
		
		if target.hitbox_health in hitbox_damage.get_overlapping_areas():
			generate_path(-target.global_position)
	
	# Otherwise, move the Food Buddy towards the Player while they look for a new target.
	else:
		using_ability = false
		
		target_closest_enemy.emit(self)
		
		if target == null or !target.alive:
			
			target_player.emit(self)
			using_ability = false
			speed_current = speed_normal
			
			target_distance = global_position.distance_to(target.global_position)
			
			if target.current_altitude != 0 or target_distance <= max(target.radius_range, radius_range):
				velocity.x = 0
				velocity.y = 0
				return
		
		generate_path()


func player_field_state_callback() -> void:
	pass
		



# Throw a left punch
func use_ability1(player: Player, _delta: float):
	
	if !player.using_ability:
		if player.use_stamina(player.stamina_use["Punch"]):
			
			player.using_ability = true 
			
			player.hand_punching = "left"
			
			player.update_animation()
			print("The Player threw a " + player.hand_punching + " punch!")



# Throw a right punch
func use_ability2(player: Player, _delta: float):
	
	if !player.using_ability:
		if player.use_stamina(player.stamina_use["Punch"]):
			
			player.using_ability = true 
			
			player.hand_punching = "right"
			
			player.update_animation()
			print("The Player threw a " + player.hand_punching + " punch!")



func _on_sprite_animation_looped() -> void:
	
	if !paused and !level_up and target != null:
		if "ability" in sprite.animation and timer_ability_cooldown.is_stopped() and target.hitbox_health in hitbox_damage.get_overlapping_areas():
			
			if target is Enemy:
				use_ability_solo.emit(self, ability_damage["Solo"])
			
			timer_ability_cooldown.start(1.5)
			if current_direction_name == "":
				sprite.play("idle_front")
			else:
				sprite.play("idle_" + current_direction_name)
			
			current_animation_name = "idle"
			
			if RNG.randi_range(0, 1):
				if RNG.randi_range(0, 1):
					target_point = Vector2(-target.global_position.x, -target.global_position.y)
					generate_path(target_point)
				else:
					target_point = Vector2(-target.global_position.x, target.global_position.y * 2)
					generate_path(target_point)
			else:
				if RNG.randi_range(0, 1):
					target_point = Vector2(target.global_position.x * 2, -target.global_position.y)
					generate_path(target_point)
				else:
					target_point = Vector2(target.global_position.x * 2, target.global_position.y * 2)
					generate_path(target_point)
			
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


func moving_sideways_animation() -> void:
	# If sprite is facing/moving right, put trail on the left
	if sprite.flip_h:
		animation_player.play("rotate_right")
	
	# If sprite is facing/moving left, put trail on the right
	else:
		animation_player.play("rotate_left")


func _on_sprite_animation_changed() -> void:
	if !paused and !level_up:
		if "moving_sideways" != sprite.animation and "ability_sideways" != sprite.animation:
			animation_player.play("RESET")
			sprinkle_sprite.play("nothing")
