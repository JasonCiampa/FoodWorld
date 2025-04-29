class_name FoodBuddySelectInterface

extends Control


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var button_active_buddy1: TextureButton
var button_active_buddy2: TextureButton
var button_inactive_buddy: TextureButton

var text_active_buddy1: Label
var text_active_buddy2: Label
var text_inactive_buddy: Label

var animator: AnimationPlayer

var player: Player
var InterfaceCharacterStatus: CharacterStatusInterface
var InterfaceLevelUp: LevelUpInterface
var InterfaceFoodBuddyFieldState: FoodBuddyFieldStateInterface
var frozen_subjects: Array[Node2D]

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

signal adjust_tilemap_modulate

signal adjust_equipped_buddy

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var selected_active_foodbuddy: FoodBuddy
var selected_inactive_foodbuddy: FoodBuddy

var active_food_buddies: Array[FoodBuddy]
var active_foodbuddy1: FoodBuddy
var active_foodbuddy2: FoodBuddy

var inactive_foodbuddy: FoodBuddy
var inactive_food_buddies: Array[FoodBuddy]

var start_location_foodbuddy1: Vector2
var start_location_foodbuddy2: Vector2

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	button_active_buddy1 = $"Active Buddy Circle 1/Active Buddy Circle Button Container/Active Buddy Circle Button"
	button_active_buddy2 = $"Active Buddy Circle 2/Active Buddy Circle Button Container/Active Buddy Circle Button"
	button_inactive_buddy = $"Inactive Buddy Circle/Inactive Buddy Circle Button Container/Inactive Buddy Circle Button"
	
	text_active_buddy1 = $"Active Buddy Circle 1/Active Buddy Circle Text Container/Active Food Buddy Text"
	text_active_buddy2 = $"Active Buddy Circle 2/Active Buddy Circle Text Container/Active Food Buddy Text"
	text_inactive_buddy = $"Inactive Buddy Circle/Inactive Buddy Circle Text Container/Inactive Food Buddy Text"
	
	animator = $"Animator"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Sets the given values as the ones to use for the UI components
func setValues(_player: Player, _food_buddies_active: Array[FoodBuddy], _food_buddies_inactive: Array[FoodBuddy], _InterfaceCharacterStatus: CharacterStatusInterface, _InterfaceLevelUp: LevelUpInterface, _InterfaceFoodBuddyFieldState: FoodBuddyFieldStateInterface):
	
	player = _player
	
	active_foodbuddy1 = _food_buddies_active[0]
	active_foodbuddy2 = _food_buddies_active[1]
	active_food_buddies = _food_buddies_active
	
	inactive_foodbuddy = _food_buddies_inactive[0]
	inactive_food_buddies = _food_buddies_inactive
	
	InterfaceCharacterStatus = _InterfaceCharacterStatus
	InterfaceLevelUp = _InterfaceLevelUp
	InterfaceFoodBuddyFieldState = _InterfaceFoodBuddyFieldState
	
	button_active_buddy1.texture_normal = load(active_foodbuddy1.select_circle_texture_path_normal)
	button_active_buddy1.texture_pressed = load(active_foodbuddy1.select_circle_texture_path_pressed)
	text_active_buddy1.text = active_foodbuddy1.name
	
	button_active_buddy2.texture_normal = load(active_foodbuddy2.select_circle_texture_path_normal)
	button_active_buddy2.texture_pressed = load(active_foodbuddy2.select_circle_texture_path_pressed)
	text_active_buddy2.text = active_foodbuddy2.name
	
	button_inactive_buddy.texture_normal = load(inactive_foodbuddy.select_circle_texture_path_normal)
	button_inactive_buddy.texture_pressed = load(inactive_foodbuddy.select_circle_texture_path_pressed)
	text_inactive_buddy.text = inactive_foodbuddy.name



func start(freeze_subjects: Array[Node2D]):
	
	# Pause all of the characters' processing while the interface is active
	for subject in freeze_subjects:
		subject.paused = true
		
		if subject is GameCharacter:
			subject.sprite.pause()
		
		elif subject is InteractableAsset or subject is InteractableCharacter:
			subject.label_e_to_interact.hide()
	
	
	# Store the currently frozen subjects so they can be unfrozen when selection is complete
	frozen_subjects = freeze_subjects
	
	# Set the UI to be visible and processing
	self.visible = true
	self.process_mode = Node.PROCESS_MODE_INHERIT
	
	# Animate the UI onto the screen, then have it stay in place
	animator.play("enter_UI")
	animator.queue("stay_UI")
	
	start_location_foodbuddy1 = active_foodbuddy1.global_position
	start_location_foodbuddy2 = active_foodbuddy2.global_position
	
	if active_foodbuddy1.field_state_current != FoodBuddy.FieldState.PLAYER:
		active_foodbuddy1.global_position = player.global_position
		active_foodbuddy1.global_position.x -= 32
	if active_foodbuddy2.field_state_current != FoodBuddy.FieldState.PLAYER:
		active_foodbuddy2.global_position = player.global_position
		active_foodbuddy2.global_position.x += 32
	
	for buddy in active_food_buddies:
		buddy.label_e_to_interact.hide()
		buddy.field_state_previous = buddy.field_state_current
		buddy.previous_animation = buddy.sprite.animation
		buddy.previous_animation_frame = buddy.sprite.get_frame()
		buddy.previous_animation_frame_progress = buddy.sprite.get_frame_progress()
		buddy.previous_modulate = buddy.sprite.self_modulate
		buddy.sprite.self_modulate = Color(1, 1, 1, 1)
		
		if buddy.alive:
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
	player.is_interacting = true
	
	player.direction_previous_horizontal = player.direction_current_horizontal
	player.direction_previous_vertical = player.direction_current_vertical
	
	player.direction_current_horizontal = player.Direction.IDLE
	player.direction_current_vertical = player.Direction.IDLE
	
	if "juice" in player.current_animation_name:
		player.update_animation("idle_front")
	else:
		player.update_animation()
	
	adjust_tilemap_modulate.emit(0.25)



func end():
	
	# Pause all of the characters' processing while the interface is active
	for subject in frozen_subjects:
		subject.paused = false
		
		if subject is Juicebox or subject is EnergyBall:
			
			if subject.sprite.get_frame() == subject.impact_frame:
				subject.explode.emit(self)
			
			subject.sprite.play()
		
		if subject is GameCharacter:
			subject.sprite.play()
	
	# Set the UI to be invisible and not processing
	self.visible = false
	self.process_mode = Node.PROCESS_MODE_DISABLED
	
	button_active_buddy1.disabled = true
	button_active_buddy2.disabled = true
	button_inactive_buddy.disabled = true
	
	for buddy in range(0, active_food_buddies.size()):
		active_food_buddies[buddy].sprite.play(active_food_buddies[buddy].previous_animation)
		active_food_buddies[buddy].sprite.set_frame_and_progress(active_food_buddies[buddy].previous_animation_frame, active_food_buddies[buddy].previous_animation_frame_progress)
		active_food_buddies[buddy].sprite.self_modulate = active_food_buddies[buddy].previous_modulate
		
		if player.equipped_buddy == active_food_buddies[buddy]:
			adjust_equipped_buddy.emit(buddy, true)
	
	active_foodbuddy1.global_position = start_location_foodbuddy1
	active_foodbuddy2.global_position = start_location_foodbuddy2
	
	player.direction_current_horizontal = player.direction_previous_horizontal
	player.direction_current_vertical = player.direction_previous_vertical
	
	player.sprite.play(player.previous_animation)
	player.sprite.set_frame_and_progress(player.previous_animation_frame, player.previous_animation_frame_progress)
	player.sprite.self_modulate = player.previous_modulate
	player.is_interacting = false
	animator.play("RESET")
	
	adjust_tilemap_modulate.emit(1)


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

func _on_animator_current_animation_changed(animation_name: String) -> void:
	
	if animation_name == "stay_UI":
		button_active_buddy1.disabled = false
		button_active_buddy2.disabled = false
		button_inactive_buddy.disabled = false


func _on_active_buddy1_button_down() -> void:
	
	# Determine if the active Food Buddy 1 is already selected, then unselect it
	if active_foodbuddy1 == selected_active_foodbuddy:
		selected_active_foodbuddy = null
		button_active_buddy1.texture_normal = load(active_foodbuddy1.select_circle_texture_path_normal)
		button_active_buddy1.texture_pressed = load(active_foodbuddy1.select_circle_texture_path_pressed)
	
	elif active_foodbuddy2 == selected_active_foodbuddy:
		selected_active_foodbuddy = active_foodbuddy1
		button_active_buddy1.texture_normal = load(active_foodbuddy1.select_circle_texture_path_pressed)
		button_active_buddy1.texture_pressed = load(active_foodbuddy1.select_circle_texture_path_normal)
		button_active_buddy2.texture_normal = load(active_foodbuddy2.select_circle_texture_path_normal)
		button_active_buddy2.texture_pressed = load(active_foodbuddy2.select_circle_texture_path_pressed)
	
	# Otherwise, determine if an inactive Food Buddy has not been selected yet, then set this Food Buddy as the selected active Food Buddy
	elif selected_inactive_foodbuddy == null:
		selected_active_foodbuddy = active_foodbuddy1
		button_active_buddy1.texture_normal = load(active_foodbuddy1.select_circle_texture_path_pressed)
		button_active_buddy1.texture_pressed = load(active_foodbuddy1.select_circle_texture_path_normal)
	
	# Otherwise, there is a selected inactive Food Buddy, and this active Food Buddy 1 is being selected to swap with the inactive buddy, so do that
	else:
		
		# Make a temp variable to store the currently active Food Buddy 1 before its swap out
		var temp: FoodBuddy = active_foodbuddy1
		
		# Update the active and inactive food buddy lists
		active_food_buddies[0] = inactive_food_buddies[0]
		inactive_food_buddies[0] = temp
		
		active_foodbuddy1 = active_food_buddies[0]
		inactive_foodbuddy = inactive_food_buddies[0]
		
		
		active_foodbuddy1.sprite.play("idle_front")
		
		active_foodbuddy1.active = true
		inactive_foodbuddy.active = false
		
		# Update the locations of the Food Buddies in-game
		var temp_position: Vector2 = inactive_foodbuddy.global_position
		inactive_foodbuddy.global_position = active_foodbuddy1.global_position
		active_foodbuddy1.global_position = temp_position
		
		
		active_foodbuddy1.collision_values["GROUND"] = 4
		active_foodbuddy1.collision_values["MIDAIR"] = 5
		active_foodbuddy1.collision_values["PLATFORM"] = 6
		
		active_foodbuddy1.process_mode = Node.PROCESS_MODE_INHERIT
		inactive_foodbuddy.process_mode = Node.PROCESS_MODE_DISABLED
		
		if inactive_foodbuddy.field_state_current == FoodBuddy.FieldState.PLAYER:
			player.equipped_buddy = active_foodbuddy1
			player.equipped_buddy.field_state_current = FoodBuddy.FieldState.PLAYER
			player.equipped_buddy.global_position = player.global_position
			player.equipped_buddy.process_nearby_tiles = true
			player.equipped_buddy.timer_process_tiles.start(player.equipped_buddy.time_between_tile_updates)
			
			if player.equipped_buddy.name != "Dan":
				player.equipped_buddy.visible = false
				player.sprite.offset.y = -16
				player.speed_current = player.speed_normal
			else:
				player.equipped_buddy.label_e_to_interact.visible = false
				player.shadow.visible = false
				player.sprite.offset.y = -39
				player.speed_current = player.speed_normal_dan
			
			
			inactive_foodbuddy.field_state_current = inactive_foodbuddy.field_state_previous
			if inactive_foodbuddy.field_state_current == FoodBuddy.FieldState.PLAYER:
				inactive_foodbuddy.field_state_current = FoodBuddy.FieldState.FOLLOW
		else:
			active_foodbuddy1.visible = true
			
		player.update_animation()
		
		# Update the values of this interface
		setValues(player, active_food_buddies, inactive_food_buddies, InterfaceCharacterStatus, InterfaceLevelUp, InterfaceFoodBuddyFieldState)
		
		# Update the Character Status Interface
		InterfaceCharacterStatus.setValues(player, active_food_buddies)
		InterfaceLevelUp.setValues(player, active_food_buddies, InterfaceCharacterStatus)
		InterfaceFoodBuddyFieldState.setValues(player, active_food_buddies)
		
		
		# Clear variables
		temp = null
		selected_inactive_foodbuddy = null
		selected_active_foodbuddy = null



func _on_active_buddy2_button_down() -> void:
	
	# Determine if the active Food Buddy 2 is already selected, then unselect it
	if active_foodbuddy2 == selected_active_foodbuddy:
		selected_active_foodbuddy = null
		button_active_buddy2.texture_normal = load(active_foodbuddy2.select_circle_texture_path_normal)
		button_active_buddy2.texture_pressed = load(active_foodbuddy2.select_circle_texture_path_pressed)
	
	elif active_foodbuddy1 == selected_active_foodbuddy:
		selected_active_foodbuddy = active_foodbuddy2
		button_active_buddy2.texture_normal = load(active_foodbuddy2.select_circle_texture_path_pressed)
		button_active_buddy2.texture_pressed = load(active_foodbuddy2.select_circle_texture_path_normal)
		button_active_buddy1.texture_normal = load(active_foodbuddy1.select_circle_texture_path_normal)
		button_active_buddy1.texture_pressed = load(active_foodbuddy1.select_circle_texture_path_pressed)
	
	# Otherwise, determine if an inactive Food Buddy has not been selected yet, then set this Food Buddy as the selected active Food Buddy
	elif selected_inactive_foodbuddy == null:
		selected_active_foodbuddy = active_foodbuddy2
		button_active_buddy2.texture_normal = load(active_foodbuddy2.select_circle_texture_path_pressed)
		button_active_buddy2.texture_pressed = load(active_foodbuddy2.select_circle_texture_path_normal)
	
	# Otherwise, there is a selected inactive Food Buddy, and this active Food Buddy 1 is being selected to swap with the inactive buddy, so do that
	else:
		
		# Make a temp variable to store the currently active Food Buddy 1 before its swap out
		var temp: FoodBuddy = active_foodbuddy2
		
		# Update the active and inactive food buddy lists
		active_food_buddies[1] = inactive_food_buddies[0]
		inactive_food_buddies[0] = temp
		
		active_foodbuddy2 = active_food_buddies[1]
		inactive_foodbuddy = inactive_food_buddies[0]
		
		active_foodbuddy2.sprite.play("idle_front")
		
		active_foodbuddy2.active = true
		inactive_foodbuddy.active = false
		
		# Update the locations of the Food Buddies in-game
		
		var temp_position: Vector2 = inactive_foodbuddy.global_position
		inactive_foodbuddy.global_position = active_foodbuddy2.global_position
		active_foodbuddy2.global_position = temp_position
		
		active_foodbuddy2.collision_values["GROUND"] = 7
		active_foodbuddy2.collision_values["MIDAIR"] = 8
		active_foodbuddy2.collision_values["PLATFORM"] = 9
		
		active_foodbuddy2.process_mode = Node.PROCESS_MODE_INHERIT
		inactive_foodbuddy.process_mode = Node.PROCESS_MODE_DISABLED
		
		if inactive_foodbuddy.field_state_current == FoodBuddy.FieldState.PLAYER:
			player.equipped_buddy = active_foodbuddy2
			player.equipped_buddy.field_state_current = FoodBuddy.FieldState.PLAYER
			player.equipped_buddy.global_position = player.global_position
			player.equipped_buddy.process_nearby_tiles = true
			player.equipped_buddy.timer_process_tiles.start(player.equipped_buddy.time_between_tile_updates)
			
			if player.equipped_buddy.name != "Dan":
				player.equipped_buddy.visible = false
				player.sprite.offset.y = -16
				player.speed_current = player.speed_normal
			else:
				player.equipped_buddy.label_e_to_interact.visible = false
				player.shadow.visible = false
				player.sprite.offset.y = -39
				player.speed_current = player.speed_normal_dan
			
			
			inactive_foodbuddy.field_state_current = inactive_foodbuddy.field_state_previous
			if inactive_foodbuddy.field_state_current == FoodBuddy.FieldState.PLAYER:
				inactive_foodbuddy.field_state_current = FoodBuddy.FieldState.FOLLOW
			
		else:
			active_foodbuddy2.visible = true
		
		player.update_animation()
		
		# Update the values of this interface
		setValues(player, active_food_buddies, inactive_food_buddies, InterfaceCharacterStatus, InterfaceLevelUp, InterfaceFoodBuddyFieldState)
		
		# Update the Character Status Interface
		InterfaceCharacterStatus.setValues(player, active_food_buddies)
		InterfaceLevelUp.setValues(player, active_food_buddies, InterfaceCharacterStatus)
		InterfaceFoodBuddyFieldState.setValues(player, active_food_buddies)
		
		# Clear variables
		temp = null
		selected_inactive_foodbuddy = null
		selected_active_foodbuddy = null



func _on_inactive_buddy_button_button_down() -> void:
	
	# Determine if the inactive Food Buddy is already selected, then unselect it
	if inactive_foodbuddy == selected_inactive_foodbuddy:
		selected_inactive_foodbuddy = null
		button_inactive_buddy.texture_normal = load(inactive_foodbuddy.select_circle_texture_path_normal)
		button_inactive_buddy.texture_pressed = load(inactive_foodbuddy.select_circle_texture_path_pressed)
	
	# Otherwise, determine if an active Food Buddy has not been selected yet, then set this Food Buddy as the selected inactive Food Buddy
	elif selected_active_foodbuddy == null:
		selected_inactive_foodbuddy = inactive_foodbuddy
		button_inactive_buddy.texture_normal = load(inactive_foodbuddy.select_circle_texture_path_pressed)
		button_inactive_buddy.texture_pressed = load(inactive_foodbuddy.select_circle_texture_path_normal)
	
	# Otherwise, there is a selected active Food Buddy, and this inactive Food Buddy is being selected to swap with the active buddy, so do that
	else:
		
		# Make a temp variable to store the currently active Food Buddy 1 before its swap out
		var temp: FoodBuddy
		var temp_position: Vector2
		
		# Update the active and inactive food buddy lists
		if selected_active_foodbuddy == active_foodbuddy1:
			temp = active_foodbuddy1
			
			active_food_buddies[0] = inactive_food_buddies[0]
			inactive_food_buddies[0] = temp
			
			active_foodbuddy1 = active_food_buddies[0]
			inactive_foodbuddy = inactive_food_buddies[0]
			
			active_foodbuddy1.sprite.play("idle_front")
			
			active_foodbuddy1.active = true
			inactive_foodbuddy.active = false
			
			# Update the locations of the Food Buddies in-game
			temp_position = inactive_foodbuddy.global_position
			inactive_foodbuddy.global_position = active_foodbuddy1.global_position
			active_foodbuddy1.global_position = temp_position
			
			active_food_buddies[0].process_mode = Node.PROCESS_MODE_INHERIT
			inactive_food_buddies[0].process_mode = Node.PROCESS_MODE_DISABLED
			
			active_foodbuddy1.collision_values["GROUND"] = 4
			active_foodbuddy1.collision_values["MIDAIR"] = 5
			active_foodbuddy1.collision_values["PLATFORM"] = 6
			
			active_foodbuddy1.process_mode = Node.PROCESS_MODE_INHERIT
			inactive_foodbuddy.process_mode = Node.PROCESS_MODE_DISABLED
			
			selected_active_foodbuddy = active_foodbuddy1
		
		else:
			temp = active_foodbuddy2
			
			active_food_buddies[1] = inactive_food_buddies[0]
			inactive_food_buddies[0] = temp
			
			active_foodbuddy2 = active_food_buddies[1]
			inactive_foodbuddy = inactive_food_buddies[0]
			
			active_foodbuddy2.sprite.play("idle_front")
			
			active_foodbuddy2.active = true
			inactive_foodbuddy.active = false
			
			# Update the locations of the Food Buddies in-game
			temp_position = inactive_foodbuddy.global_position
			inactive_foodbuddy.global_position = active_foodbuddy2.global_position
			active_foodbuddy2.global_position = temp_position
			
			active_food_buddies[0].process_mode = Node.PROCESS_MODE_INHERIT
			inactive_food_buddies[0].process_mode = Node.PROCESS_MODE_DISABLED
			
			active_foodbuddy2.collision_values["GROUND"] = 7
			active_foodbuddy2.collision_values["MIDAIR"] = 8
			active_foodbuddy2.collision_values["PLATFORM"] = 9
			
			active_foodbuddy2.process_mode = Node.PROCESS_MODE_INHERIT
			inactive_foodbuddy.process_mode = Node.PROCESS_MODE_DISABLED
			
			selected_active_foodbuddy = active_foodbuddy2
			
		if inactive_foodbuddy.field_state_current == FoodBuddy.FieldState.PLAYER:
			player.equipped_buddy = selected_active_foodbuddy
			player.equipped_buddy.field_state_current = FoodBuddy.FieldState.PLAYER
			player.equipped_buddy.global_position = player.global_position
			player.equipped_buddy.process_nearby_tiles = true
			player.equipped_buddy.timer_process_tiles.start(player.equipped_buddy.time_between_tile_updates)
			
			if player.equipped_buddy.name != "Dan":
				player.equipped_buddy.visible = false
				player.sprite.offset.y = -16
				player.speed_current = player.speed_normal
			else:
				player.equipped_buddy.label_e_to_interact.visible = false
				player.shadow.visible = false
				player.sprite.offset.y = -39
				player.speed_current = player.speed_normal_dan
			
			inactive_foodbuddy.field_state_current = inactive_foodbuddy.field_state_previous
			if inactive_foodbuddy.field_state_current == FoodBuddy.FieldState.PLAYER:
				inactive_foodbuddy.field_state_current = FoodBuddy.FieldState.FOLLOW
		
		else:
			selected_active_foodbuddy.visible = true
		
		
		player.update_animation()
		
		# Update the values of this interface
		setValues(player, active_food_buddies, inactive_food_buddies, InterfaceCharacterStatus, InterfaceLevelUp, InterfaceFoodBuddyFieldState)
		
		# Update the Character Status Interface
		InterfaceCharacterStatus.setValues(player, active_food_buddies)
		InterfaceLevelUp.setValues(player, active_food_buddies, InterfaceCharacterStatus)
		InterfaceFoodBuddyFieldState.setValues(player, active_food_buddies)
		
		
		# Clear variables
		temp = null
		selected_inactive_foodbuddy = null
		selected_active_foodbuddy = null
