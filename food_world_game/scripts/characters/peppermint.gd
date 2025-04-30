extends Enemy


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var trail_sprite: AnimatedSprite2D

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

var roll_damage: int = 10
var target_point: Vector2

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ABSTRACT FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# A callback function that should execute repeatedly while the Enemy is in the FORAGE FieldState
func aggressive_field_state_callback() -> void:
	
	if target == null or !target.alive:
		field_state_current = FieldState.PASSIVE
		using_ability = false
		velocity.x = 0
		velocity.y = 0
		target = null
		update_animation()
		print("animation updated")
		return
	
	# Determine if the Enemy is in range of an Enemy, then make them stop moving and launch their solo attack
	if target.hitbox_health in hitbox_interaction.get_overlapping_areas():
		
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
		
		if target.hitbox_health in hitbox_interaction.get_overlapping_areas():
			generate_path(-target.global_position)
		
	else:
		generate_path()
	
	update_animation()



# A custom ready function that each Enemy subclass should personally define. This is called in the default Enemy class's '_ready()' function
func ready():
	trail_sprite = $"AnimatedSpriteTrail"
	
	speed_normal = 40
	speed_sprinting = 80
	
	name = "Peppermint"



# A custom process function that each Enemy subclass should personally define. This is called in the default Enemy class's '_process()' function
func process(_delta: float):
	if sprite.animation in animation_callbacks.keys():
		animation_callbacks.get(sprite.animation).call()



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
		fire_projectile.emit("res://scenes/blueprints/carrot-projectile.tscn", Vector2(target.global_position.x, target.global_position.y - 8), roll_damage, 5, self)



func _on_sprite_animation_looped() -> void:
	
	if !paused:
		if target != null:
			if "ability" in sprite.animation and timer_ability_cooldown.is_stopped() and target.hitbox_health in current_damage_hitbox.get_overlapping_areas():
				
				use_ability.emit(self, roll_damage)
				
				timer_ability_cooldown.start(2)
				
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
	#print("Dan using ability sideways")
	
	# If sprite is facing/moving right, put trail on the left
	if sprite.flip_h:
		trail_sprite.play("trail_left")
		animation_player.play("rotate_right_fast")
	
	# If sprite is facing/moving left, put trail on the right
	else:
		trail_sprite.play("trail_right")
		animation_player.play("rotate_left_fast")


func moving_sideways_animation() -> void:
	#print("Dan moving sideways")
	
	# If sprite is facing/moving right, put trail on the left
	if sprite.flip_h:
		animation_player.play("rotate_right")
	
	# If sprite is facing/moving left, put trail on the right
	else:
		animation_player.play("rotate_left")


func _on_sprite_animation_changed() -> void:
	if !paused:
		if "moving_sideways" != sprite.animation and "ability_sideways" != sprite.animation:
			animation_player.play("RESET")
			trail_sprite.play("nothing")
