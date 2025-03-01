extends Control

class_name FoodBuddyFieldStateInterface


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var text_foodbuddy1_name: Label
var text_foodbuddy2_name: Label

var button_buddy1_solo: TextureButton
var button_buddy1_follow: TextureButton
var button_buddy1_forage: TextureButton

var button_buddy2_solo: TextureButton
var button_buddy2_follow: TextureButton
var button_buddy2_forage: TextureButton

var animator: AnimationPlayer

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var foodbuddy1: FoodBuddy
var foodbuddy2: FoodBuddy

var selected_button_buddy1: TextureButton
var selected_button_buddy2: TextureButton

var active_food_buddies: Array[FoodBuddy]

var frozen_subjects: Array[Node2D]

var player: Player

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass



# Called every frame. Updates the Enemy's physics
func _physics_process(_delta: float) -> void:
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Sets the given values as the ones to use for the UI components
func setValues(_player: Player, _food_buddies_active: Array[FoodBuddy]):
	
	text_foodbuddy1_name = $"Buddy 1 Field States/Buddy 1 Name Text Container/Buddy 1 Name Text"
	text_foodbuddy2_name = $"Buddy 2 Field States/Buddy 2 Name Text Container/Buddy 2 Name Text"
	
	button_buddy1_solo = $"Buddy 1 Field States/Buddy 1 SOLO State/Buddy 1 SOLO State Button Container/Buddy 1 SOLO State Button"
	button_buddy1_follow = $"Buddy 1 Field States/Buddy 1 FOLLOW State/Buddy 1 FOLLOW State Button Container/Buddy 1 FOLLOW State Button"
	button_buddy1_forage = $"Buddy 1 Field States/Buddy 1 FORAGE State/Buddy 1 FORAGE State Button Container/Buddy 1 FORAGE State Button"
	button_buddy2_solo = $"Buddy 2 Field States/Buddy 2 SOLO State/Buddy 2 SOLO State Button Container/Buddy 2 SOLO State Button"
	button_buddy2_follow = $"Buddy 2 Field States/Buddy 2 FOLLOW State/Buddy 2 FOLLOW State Button Container/Buddy 2 FOLLOW State Button"
	button_buddy2_forage = $"Buddy 2 Field States/Buddy 2 FORAGE State/Buddy 2 FORAGE State Button Container/Buddy 2 FORAGE State State Button"
	animator = $"Animator"
	
	player = _player
	
	foodbuddy1 = _food_buddies_active[0]
	foodbuddy2 = _food_buddies_active[1]
	active_food_buddies = _food_buddies_active
	
	text_foodbuddy1_name.text = foodbuddy1.name
	text_foodbuddy2_name.text = foodbuddy2.name



# Enables the Food Buddy FieldState Interface and freezes the updating for the given subjects while the Interface is active
func start(_freeze_subjects: Array[Node2D], food_buddies_active: Array[FoodBuddy]):
	
	# Store the currently frozen subjects so they can be unfrozen when selection is complete
	frozen_subjects = _freeze_subjects
	frozen_subjects.append(food_buddies_active[0])
	frozen_subjects.append(food_buddies_active[1])
	
	# Pause all of the characters' processing while the interface is active
	for subject in frozen_subjects:
		subject.paused = true
	
	# Set the UI to be visible and processing
	self.visible = true
	self.process_mode = Node.PROCESS_MODE_INHERIT
	
	if foodbuddy1.field_state_current == FoodBuddy.FieldState.SOLO:
		selected_button_buddy1 = button_buddy1_solo
	elif foodbuddy1.field_state_current == FoodBuddy.FieldState.FOLLOW:
		selected_button_buddy1 = button_buddy1_follow
	elif foodbuddy1.field_state_current == FoodBuddy.FieldState.FORAGE:
		selected_button_buddy1 = button_buddy1_forage
	
	if foodbuddy2.field_state_current == FoodBuddy.FieldState.SOLO:
		selected_button_buddy2 = button_buddy2_solo
	elif foodbuddy2.field_state_current == FoodBuddy.FieldState.FOLLOW:
		selected_button_buddy2 = button_buddy2_follow
	elif foodbuddy2.field_state_current == FoodBuddy.FieldState.FORAGE:
		selected_button_buddy2 = button_buddy2_forage
	
	selected_button_buddy1.disabled = true
	selected_button_buddy2.disabled = true
	
	
	# Animate the UI onto the screen, then have it stay in place
	animator.play("enter_UI")
	animator.queue("stay_UI")
	
	# Set Food Buddy 1 as the currently selected Food Buddy in the interface and Food Buddy 2 as the unselected Food Buddy (these are the first two subjects to freeze in the given list)
	foodbuddy1 = food_buddies_active[0]
	foodbuddy2 = food_buddies_active[1]
	
	
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



# Disables the Food Buddy FieldState Interface
func end():
	
	# Pause all of the characters' processing while the interface is active
	for subject in frozen_subjects:
		subject.paused = false
	
	# Iterate over each tilemap that could be on screen right now and disable it
	for tilemap in player.current_tilemaps:
		tilemap.modulate.a = 1
	
	# Determine if the food buddies have different tilemaps than the player
	if player.current_tilemaps[0] != foodbuddy1.current_tilemaps[0] or player.current_tilemaps[0] != foodbuddy2.current_tilemaps[0]:
		
		# Iterate over each tilemap that could be on screen right now and disable it
		for tilemap in foodbuddy1.current_tilemaps:
			tilemap.modulate.a = 1
		
		for tilemap in foodbuddy2.current_tilemaps:
			tilemap.modulate.a = 1
	
	# Set the UI to be invisible and not processing
	self.visible = false
	self.process_mode = Node.PROCESS_MODE_DISABLED
	
	selected_button_buddy1.disabled = false
	selected_button_buddy2.disabled = false
	
	animator.play("RESET")


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

func update_selected_state_buddy1(newly_selected_button: TextureButton, field_state: FoodBuddy.FieldState):
	selected_button_buddy1.disabled = false
	
	selected_button_buddy1 = newly_selected_button
	selected_button_buddy1.disabled = true
	foodbuddy1.field_state_current = field_state

func update_selected_state_buddy2(newly_selected_button: TextureButton, field_state: FoodBuddy.FieldState):
	selected_button_buddy2.disabled = false
	
	selected_button_buddy2 = newly_selected_button
	selected_button_buddy2.disabled = true
	foodbuddy2.field_state_current = field_state


func _on_buddy_1_solo_state_button_down() -> void:
	update_selected_state_buddy1(button_buddy1_solo, FoodBuddy.FieldState.SOLO)


func _on_buddy_1_follow_state_button_down() -> void:
	update_selected_state_buddy1(button_buddy1_follow, FoodBuddy.FieldState.FOLLOW)


func _on_buddy_1_forage_state_button_down() -> void:
	update_selected_state_buddy1(button_buddy1_forage, FoodBuddy.FieldState.FORAGE)


func _on_buddy_2_solo_state_button_down() -> void:
	update_selected_state_buddy2(button_buddy2_solo, FoodBuddy.FieldState.SOLO)

func _on_buddy_2_follow_state_button_down() -> void:
	update_selected_state_buddy2(button_buddy2_follow, FoodBuddy.FieldState.FOLLOW)

func _on_buddy_2_forage_state_button_down() -> void:
	update_selected_state_buddy2(button_buddy2_forage, FoodBuddy.FieldState.FORAGE)
