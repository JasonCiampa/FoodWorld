class_name LevelUpInterface

extends Control


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var text_level_up: Label
var text_choose_upgrade: Label

var button_health: TextureButton
var text_health: Label
var health_reward: int = 10

var button_stamina: TextureButton
var text_stamina: Label
var stamina_reward: int = 10

var button_power: TextureButton
var text_power: Label
var power_reward: int = 2

var animator: AnimationPlayer

var player: Player
var active_food_buddies: Array[FoodBuddy]
var foodbuddy1: FoodBuddy
var foodbuddy2: FoodBuddy
var InterfaceCharacterStatus: CharacterStatusInterface
var frozen_subjects: Array[Node2D]

var start_location_foodbuddy1: Vector2
var start_location_foodbuddy2: Vector2

var inactive_foodbuddy: FoodBuddy

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

signal level_up_ended
signal adjust_tilemap_modulate

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	text_level_up = $"Level-Up/Level-up Text Container/Level-up Text"
	text_choose_upgrade = $"Choose Upgrade/Choose Upgrade Container/Choose Upgrade Text"
	
	button_health = $"Health/Health Button Container/Health Button"
	text_health = $"Health/Health Text Container/Health Text"
	
	button_stamina = $"Stamina/Stamina Button Container/Stamina Button"
	text_stamina = $"Stamina/Stamina Text Container/Stamina Text"
	
	button_power = $"Power/Power Button Container/Power Button"
	text_power = $"Power/Power Text Container/Power Text"
	
	animator = $"Animator"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Sets the given values as the ones to use for the UI components
func setValues(_player: Player, _food_buddies_active: Array[FoodBuddy], _InterfaceCharacterStatus: CharacterStatusInterface):
	
	player = _player
	active_food_buddies = _food_buddies_active
	foodbuddy1 = active_food_buddies[0]
	foodbuddy2 = active_food_buddies[1]
	InterfaceCharacterStatus = _InterfaceCharacterStatus



func start(freeze_subjects: Array[Node2D]):
	
	# Pause all of the characters' processing while the interface is active
	for subject in freeze_subjects:
		if subject is FoodBuddy and subject not in active_food_buddies:
			inactive_foodbuddy = subject
		
		if subject is GameCharacter:
			subject.sprite.pause()
		
		subject.paused = true
	
	frozen_subjects = freeze_subjects
	
	# Fill up the character's stamina and health as a reward for leveling up
	player.health_current = player.health_max
	player.stamina_current = player.stamina_max
	
	if player.level_current != 15:
		player.level_current += 1
		
		# Set the Character's xp to be at 0 + whatever amount they exceeded over the maximum and increment their level and max XP
		player.xp_current = abs(player.xp_max - player.xp_current)
		player.xp_max = player.xp_max * 2
		
		# Update the text on the Character's status bar, as well as the status bar's max xp and current xp
		InterfaceCharacterStatus.text_level_player.text = "Lvl " + str(player.level_current)
		InterfaceCharacterStatus.xp_bar_player.value = player.xp_current
		InterfaceCharacterStatus.xp_bar_player.max_value = player.xp_max
	else:
		player.xp_current = player.xp_max
		level_up_ended.emit()
		return
	
	# Update the text on the Character's status bar, as well as the status bar's max xp and current xp
	InterfaceCharacterStatus.text_level_player.text = "Lvl " + str(player.level_current)
	InterfaceCharacterStatus.xp_bar_player.value = player.xp_current
	InterfaceCharacterStatus.xp_bar_player.max_value = player.xp_max
	
	# Set the UI to be visible and processing
	self.visible = true
	self.process_mode = Node.PROCESS_MODE_INHERIT
	
	foodbuddy1.sprite.play("idle_front")
	foodbuddy2.sprite.play("idle_front")
	
	foodbuddy1.animation_player.play("RESET")
	foodbuddy2.animation_player.play("RESET")
	
	# Animate the UI onto the screen, then have it stay in place
	animator.play("enter_UI")
	animator.queue("stay_UI")
	
	start_location_foodbuddy1 = foodbuddy1.global_position
	start_location_foodbuddy2 = foodbuddy2.global_position
	
	if foodbuddy1.field_state_current != FoodBuddy.FieldState.PLAYER:
		foodbuddy1.global_position = player.global_position
		foodbuddy1.global_position.x -= 32
	if foodbuddy2.field_state_current != FoodBuddy.FieldState.PLAYER:
		foodbuddy2.global_position = player.global_position
		foodbuddy2.global_position.x += 32
	
	for buddy in active_food_buddies:
		buddy.label_e_to_interact.hide()
		buddy.sprite.speed_scale = 1
		
		if buddy.health_current <= 0:
			buddy.revive_time_remaining = buddy.revive_time_total
			buddy.alive = true
			buddy.active = true
			buddy.level_up = true
			buddy.label_e_to_interact.text = "press 'e' to interact"
		
		buddy.health_current = buddy.health_max
		
		buddy.previous_animation = buddy.sprite.animation
		buddy.previous_animation_frame = buddy.sprite.get_frame()
		buddy.previous_animation_frame_progress = buddy.sprite.get_frame_progress()
		buddy.previous_modulate = buddy.sprite.self_modulate
		buddy.sprite.self_modulate = Color(1, 1, 1, 1)
		
		buddy.sprite.play("idle_front")
		buddy.animation_player.play("RESET")
		
		if buddy.name == "Dan":
			buddy.sprinkle_sprite.play("nothing")
		elif buddy.name == "Brittany":
			buddy.text_press_f_for_berry_bot.hide()
	
	player.previous_animation = player.sprite.animation
	player.previous_animation_frame = player.sprite.get_frame()
	player.previous_animation_frame_progress = player.sprite.get_frame_progress()
	player.previous_modulate = player.sprite.self_modulate
	player.sprite.self_modulate = Color(1, 1, 1, 1)
	player.sprite.speed_scale = 1
	
	player.direction_current_horizontal = player.Direction.IDLE
	player.direction_current_vertical = player.Direction.IDLE
	player.level_up = true
	
	if "juice" in player.current_animation_name:
		player.update_animation("idle_front")
	else:
		player.update_animation()
	
	
	InterfaceCharacterStatus.setValues(player, [foodbuddy1, foodbuddy2])
	adjust_tilemap_modulate.emit(0.25)


func end():
	animator.play("RESET")
	
	if player.xp_current >= player.xp_max and player.level_current != 15:
		start(frozen_subjects)
	else:
		# Pause all of the characters' processing while the interface is active
		for subject in frozen_subjects:
			subject.paused = false
			
			if subject is Juicebox or subject is EnergyBall:
				
				if subject.sprite.get_frame() == subject.impact_frame:
					subject.explode.emit(self)
				
				subject.sprite.play()
			
			if subject is GameCharacter:
				subject.sprite.play()
	
	self.visible = false
	self.process_mode = Node.PROCESS_MODE_DISABLED
	
	foodbuddy1.global_position = start_location_foodbuddy1
	foodbuddy2.global_position = start_location_foodbuddy2
	
	foodbuddy1.level_up = false
	foodbuddy2.level_up = false
	for buddy in active_food_buddies:
		
		if buddy.field_state_current == FoodBuddy.FieldState.FIGHT and (!buddy.target == null or buddy.target.alive):
			buddy.using_ability = false
		
		if ("die" not in buddy.previous_animation) and ("ability" in buddy.previous_animation and buddy.target.alive):
			buddy.sprite.play(buddy.previous_animation)
			buddy.sprite.set_frame_and_progress(buddy.previous_animation_frame, buddy.previous_animation_frame_progress)
		else:
			buddy.sprite.play("idle_front")
	
	
	player.level_up = false
	player.using_ability = false
	player.clicked_this_frame = true
	
	button_health.disabled = true
	button_stamina.disabled = true
	button_power.disabled = true
	
	animator.play("RESET")
	
	adjust_tilemap_modulate.emit(1)



func _on_health_button_button_down() -> void:
	player.health_max += health_reward
	foodbuddy1.health_max += health_reward
	foodbuddy2.health_max += health_reward
	
	player.health_current = player.health_max
	foodbuddy1.health_current = foodbuddy1.health_max
	foodbuddy2.health_current = foodbuddy2.health_max
	
	InterfaceCharacterStatus.setValues(player, [foodbuddy1, foodbuddy2])
	
	end()


func _on_stamina_button_button_down() -> void:
	player.stamina_max += stamina_reward
	player.stamina_current = player.stamina_max
	InterfaceCharacterStatus.stamina_bar_player.max_value = player.stamina_max
	
	end()


func _on_power_button_button_down() -> void:
	player.attack_damage["Punch"] += power_reward
	foodbuddy1.ability_damage["Solo"] += power_reward
	foodbuddy2.ability_damage["Solo"] += power_reward
	
	end()


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


func _on_animator_current_animation_changed(animation_name: String) -> void:
	
	if animation_name == "stay_UI":
		button_health.disabled = false
		button_stamina.disabled = false
		button_power.disabled = false
