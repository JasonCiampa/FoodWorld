class_name LevelUpInterface

extends Control


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var text_level_up: Label
var text_choose_upgrade: Label

var button_health: TextureButton
var text_health: Label

var button_stamina: TextureButton
var text_stamina: Label

var button_power: TextureButton
var text_power: Label

var animator: AnimationPlayer

var player: Player
var active_food_buddies: Array[FoodBuddy]
var foodbuddy1: FoodBuddy
var foodbuddy2: FoodBuddy
var InterfaceCharacterStatus: CharacterStatusInterface
var frozen_subjects: Array[Node2D]

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

signal level_up_ended

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
	
	# Animate the UI onto the screen, then have it stay in place
	animator.play("enter_UI")
	animator.queue("stay_UI")
	
	# INSTEAD OF MOVING ACTUAL FOOD BUDDIES, HIDE THEM AND THEIR PROCESSING- BUT SPAWN ANIMATEDSPRITE2DS OF THOSE FOOD BUDDIES NEXT TO THE PLAYER AND MAKE EM DANCE!!
	foodbuddy1.global_position = player.global_position
	foodbuddy1.global_position.x -= 32
	
	foodbuddy2.global_position = player.global_position
	foodbuddy2.global_position.x += 32
	
	# Iterate over each tilemap that could be on screen right now and disable it
	for tilemap in player.current_tilemaps:
		tilemap.modulate.a = 0.25
	
	# Determine if the food buddies have different tilemaps than the player
	if player.current_tilemaps[0] != foodbuddy1.current_tilemaps[0] or player.current_tilemaps[0] != foodbuddy2.current_tilemaps[0]:
		
		# Iterate over each tilemap that could be on screen right now and disable it
		for tilemap in foodbuddy1.current_tilemaps:
			tilemap.modulate.a = 0.25
		
		for tilemap in foodbuddy2.current_tilemaps:
			tilemap.modulate.a = 0.25



func end():
	if player.xp_current >= player.xp_max and player.level_current != 15:
		start(frozen_subjects)
	else:
		# Pause all of the characters' processing while the interface is active
		for subject in frozen_subjects:
			subject.paused = false
		
		animator.play("RESET")
	
	self.visible = false
	self.process_mode = Node.PROCESS_MODE_DISABLED
	
	for tilemap in player.current_tilemaps:
		tilemap.modulate.a = 1
	
	if player.current_tilemaps[0] != foodbuddy1.current_tilemaps[0] or player.current_tilemaps[0] != foodbuddy2.current_tilemaps[0]:
		
		for tilemap in foodbuddy1.current_tilemaps:
			tilemap.modulate.a = 1
		
		for tilemap in foodbuddy1.current_tilemaps:
			tilemap.modulate.a = 1
	
	button_health.disabled = true
	button_stamina.disabled = true
	button_power.disabled = true



func _on_health_button_button_down() -> void:
	player.health_max += 5
	foodbuddy1.health_max += 5
	foodbuddy2.health_max += 5
	
	player.health_current = player.health_max
	foodbuddy1.health_current = foodbuddy1.health_max
	foodbuddy2.health_current = foodbuddy2.health_max
	
	InterfaceCharacterStatus.health_bar_player.max_value = player.health_max
	InterfaceCharacterStatus.health_bar_foodbuddy1.max_value = foodbuddy1.health_max
	InterfaceCharacterStatus.health_bar_foodbuddy2.max_value = foodbuddy2.health_max
	
	end()


func _on_stamina_button_button_down() -> void:
	player.stamina_max += 5
	
	player.stamina_max += 5
	player.stamina_current = player.stamina_max
	
	InterfaceCharacterStatus.stamina_bar_player.max_value = player.stamina_max
	
	end()


func _on_power_button_button_down() -> void:
	player.attack_damage["Kick"] = player.attack_damage["Kick"] + 3
	player.attack_damage["Punch"] = player.attack_damage["Punch"] + 3
	
	end()


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


func _on_animator_current_animation_changed(animation_name: String) -> void:
	
	if animation_name == "stay_UI":
		button_health.disabled = false
		button_stamina.disabled = false
		button_power.disabled = false
