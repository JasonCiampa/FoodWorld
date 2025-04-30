extends Enemy


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var carrot_damage: int = 20

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ABSTRACT FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# A callback function that should execute repeatedly while the Enemy is in the FORAGE FieldState
func aggressive_field_state_callback() -> void:
	
	if target == null or !target.alive:
		field_state_current = FieldState.PASSIVE
		velocity.x = 0
		velocity.y = 0
		target = null
		return
	
	# Determine if the Enemy is in range of an Enemy, then make them stop moving and launch their solo attack
	if target.hitbox_health in current_damage_hitbox.get_overlapping_areas():
		
		if timer_ability_cooldown.is_stopped():
			using_ability = true
			target_distance = global_position.distance_to(target.global_position)
		else:
			generate_path()
		
		if target.global_position.distance_to(global_position) <= max(target.radius_range, radius_range):
			velocity.x = 0
			velocity.y = 0
	else:
		generate_path()



# A custom ready function that each Enemy subclass should personally define. This is called in the default Enemy class's '_ready()' function
func ready():
	pass



# A custom process function that each Enemy subclass should personally define. This is called in the default Enemy class's '_process()' function
func process(_delta: float):
	pass



# A custom physics_process function that each Enemy subclass should personally define. This is called in the default Enemy class's '_physics_process()' function
func physics_process(_delta: float) -> void:
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


func _on_sprite_animation_finished() -> void:
	
	if !paused:
		if "ability" in sprite.animation:
			
			timer_ability_cooldown.start(2.5)
			using_ability = false
			
			if current_direction_name != "":
				sprite.play("idle_" + current_direction_name)
			else:
				sprite.play("idle_front")
			
			current_animation_name = "idle"
		
		update_animation()


func _on_sprite_frame_changed() -> void:
	if "ability" in sprite.animation and sprite.get_frame() == 1:
		fire_projectile.emit("res://scenes/blueprints/carrot-projectile.tscn", Vector2(target.global_position.x, target.global_position.y - 8), carrot_damage, 5, self)
