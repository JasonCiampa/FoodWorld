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
	select_circle_texture_path = "res://images/ui/png/food-buddy-selection-dan.png"
	dialogue_texture = load("res://images/ui/png/dialogue-dan.png")
	
	# Set the stamina cost for each of Dan's two abilities
	ability_stamina_cost = { 
		"Ability 1": [5, "Gradual"], 
		"Ability 2": [25, "Instant"] 
	}
	
	# Set Dan's default speed and current speed
	speed_normal = 45
	speed_sprinting = 85
	speed_current = speed_normal
	
	radius_range = 90
	
	self.name = "Dan"
	
	field_state_current = FieldState.FIGHT
	
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
	
	# Determine if the Food Buddy has an alive target Enemy currently, then move towards it.
	if target != null and target is Enemy and target.alive:
		
		if timer_ability_cooldown.is_stopped() and !using_ability:
			using_ability = true
			current_animation_name = "ability"
			sprite.play("ability_" + current_direction_name)
			target_distance = global_position.distance_to(target.global_position)
			speed_current = speed_sprinting
			generate_path()
		
		if !timer_ability_cooldown.is_stopped() and using_ability:
			generate_path(target_point)
		else:
			generate_path()
			speed_current = speed_sprinting
		
		if target.hitbox_damage in hitbox_damage.get_overlapping_areas():
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
			
			if target.current_altitude != 0 or target_distance <= target.radius_range:
				velocity.x = 0
				velocity.y = 0
				return
		
		generate_path()


func _on_sprite_animation_looped() -> void:
	
	if "ability" in sprite.animation and timer_ability_cooldown.is_stopped() and target.hitbox_damage in hitbox_damage.get_overlapping_areas():
		
		use_ability_solo.emit(self, ability_damage["Solo"])
		timer_ability_cooldown.start(1.5)
		sprite.play("idle_" + current_direction_name)
		current_animation_name = "idle"
		
		print("TARGET: ", target.global_position)
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
	
	if "moving_sideways" != sprite.animation and "ability_sideways" != sprite.animation:
		animation_player.play("RESET")
		sprinkle_sprite.play("nothing")
