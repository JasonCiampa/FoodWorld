extends FoodBuddy


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var text_press_f_for_berry_bot: Label
var hitbox_attack: Area2D

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

signal fire_energy_ball

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
	
	field_state_current = FieldState.FIGHT
	
	hitbox_attack = $"Attack Hitbox"
	text_press_f_for_berry_bot = $"Press 'F' to Manage Berry Bot"
	health_texture_path = "res://images/ui/png/brittany-health.png"
	select_circle_texture_path_normal = "res://images/ui/png/food-buddy-selection-brittany.png"
	select_circle_texture_path_pressed = "res://images/ui/png/food-buddy-selection-brittany-selected.png"
	dialogue_texture = load("res://images/ui/png/dialogue-brittany.png")
	
	
	# Set the stamina cost for each of Brittany's two abilities
	ability_stamina_cost = { 
		"Ability 1": [5, "Instant"], 
		"Ability 2": [10, "Instant"] 
	}
	
	ability_damage = { 
		"Solo": 20, 
	}
	
	# Set Brittany's default speed and current speed
	speed_normal = 35
	speed_current = speed_normal
	
	radius_range = 65
	tile_process_shape = Vector2i(3, 5)
	
	self.name = "Brittany"
	
	set_collision_value(collision_values["GROUND"])
	
	field_state_current = FieldState.FORAGE
	
	sprite.play("idle_front")


# A custom process function that is personally defined for Brittany. This is called in the default FoodBuddy class's '_process()' function
func process(_delta: float):
	
	if !using_ability and "ability" in sprite.animation and sprite.get_frame() == 5:
		using_ability = true
		fire_energy_ball.emit(Vector2(target.global_position.x, target.global_position.y - target.height / 2))



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
			if target.current_altitude != 0 or global_position.distance_to(target.global_position) <= max(target.radius_range, radius_range):
				velocity.x = 0
				velocity.y = 0
				return

		
		generate_path()
	
	
	
	# Determine if the Food Buddy is in range of an Enemy, then make them stop moving and launch their solo attack
	if target is Enemy:
		
		if target.hitbox_health in hitbox_attack.get_overlapping_areas():
			velocity.x = 0
			velocity.y = 0
			
			if timer_ability_cooldown.is_stopped() and !using_ability:
				current_animation_name = "ability"
				if current_direction_name != "":
					sprite.play("ability_" + current_direction_name)
				else:
					sprite.play("ability_front")
				target_distance = global_position.distance_to(target.global_position)


func _on_sprite_animation_finished() -> void:
	
	if !paused:
		if "ability" in sprite.animation:
			
			timer_ability_cooldown.start(1.5)
			using_ability = false
			
			if current_direction_name != "":
				sprite.play("idle_" + current_direction_name)
			else:
				sprite.play("idle_front")
			
			current_animation_name = "idle"
		
		update_animation()


# Throw a punch as the Player
func use_ability1(player: Player, _delta: float):
	if !player.using_ability:
		if player.use_stamina(player.stamina_use["Punch"]):
			
			player.using_ability = true 
			
			if player.hand_punching == "left":
				player.hand_punching = "right"
			else:
				player.hand_punching = "left"
			
		
			player.update_animation()
			print("The Player threw a " + player.hand_punching + " punch!")


# Throw a juicebox while on the player's back
func use_ability2(player: Player, _delta: float):
	if player.juiceboxes > 0:
		if player.use_stamina(player.stamina_use["Juice Throw"]):
			print("Brittany threw a juicebox!")
			player.throw_juicebox.emit(get_global_mouse_position())
		
		player.juiceboxes -= 1
