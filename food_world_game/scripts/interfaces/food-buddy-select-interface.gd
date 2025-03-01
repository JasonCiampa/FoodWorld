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
var frozen_subjects: Array[Node2D]

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var selected_active_foodbuddy
var selected_inactive_foodbuddy

var active_foodbuddy1
var active_foodbuddy2
var inactive_foodbuddy

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
func setValues(_player: Player, _food_buddies_active: Array[FoodBuddy], _food_buddies_inactive: Array[FoodBuddy], _InterfaceCharacterStatus: CharacterStatusInterface):
	
	player = _player
	active_foodbuddy1 = _food_buddies_active[0]
	active_foodbuddy2 = _food_buddies_active[1]
	inactive_foodbuddy = _food_buddies_inactive[0]
	InterfaceCharacterStatus = _InterfaceCharacterStatus



func start_selecting(freeze_subjects: Array[Node2D]):
	
	print("begin selecting!")
	
	# Pause all of the characters' processing while the interface is active
	for subject in freeze_subjects:
		subject.paused = true
	
	# Store the currently frozen subjects so they can be unfrozen when selection is complete
	frozen_subjects = freeze_subjects
	
	# Set the UI to be visible and processing
	self.visible = true
	self.process_mode = Node.PROCESS_MODE_INHERIT
	
	# Animate the UI onto the screen, then have it stay in place
	animator.play("enter_UI")
	animator.queue("stay_UI")
	
	# INSTEAD OF MOVING ACTUAL FOOD BUDDIES, HIDE THEM AND THEIR PROCESSING- BUT SPAWN ANIMATEDSPRITE2DS OF THOSE FOOD BUDDIES NEXT TO THE PLAYER AND MAKE EM DANCE!!
	active_foodbuddy1.global_position = player.global_position
	active_foodbuddy1.global_position.x -= 32
	
	active_foodbuddy2.global_position = player.global_position
	active_foodbuddy2.global_position.x += 32
	
	# Iterate over each tilemap that could be on screen right now and disable it
	for tilemap in player.current_tilemaps:
		tilemap.modulate.a = 0.25
	
	# Determine if the food buddies have different tilemaps than the player
	if player.current_tilemaps[0] != active_foodbuddy1.current_tilemaps[0] or player.current_tilemaps[0] != active_foodbuddy2.current_tilemaps[0]:
		
		# Iterate over each tilemap that could be on screen right now and disable it
		for tilemap in active_foodbuddy1.current_tilemaps:
			tilemap.modulate.a = 0.25
		
		for tilemap in active_foodbuddy2.current_tilemaps:
			tilemap.modulate.a = 0.25


func end_selecting():
	
	# Pause all of the characters' processing while the interface is active
	for subject in frozen_subjects:
		subject.paused = false
	
	
	# Iterate over each tilemap that could be on screen right now and disable it
	for tilemap in player.current_tilemaps:
		tilemap.modulate.a = 1
	
	# Determine if the food buddies have different tilemaps than the player
	if player.current_tilemaps[0] != active_foodbuddy1.current_tilemaps[0] or player.current_tilemaps[0] != active_foodbuddy2.current_tilemaps[0]:
		
		# Iterate over each tilemap that could be on screen right now and disable it
		for tilemap in active_foodbuddy1.current_tilemaps:
			tilemap.modulate.a = 1
		
		for tilemap in active_foodbuddy2.current_tilemaps:
			tilemap.modulate.a = 1
	
	# Set the UI to be invisible and not processing
	self.visible = false
	self.process_mode = Node.PROCESS_MODE_DISABLED
	
	button_active_buddy1.disabled = true
	button_active_buddy2.disabled = true
	button_inactive_buddy.disabled = true
	
	animator.play("RESET")



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




func _on_animator_current_animation_changed(animation_name: String) -> void:
	
	if animation_name == "stay_UI":
		button_active_buddy1.disabled = false
		button_active_buddy2.disabled = false
		button_inactive_buddy.disabled = false


func _on_active_buddy1_button_down() -> void:
	print("1")
	pass # Replace with function body.


func _on_active_buddy2_button_down() -> void:
	print("2")
	pass # Replace with function body.

func _on_inactive_buddy_button_button_down() -> void:
	print("3")
	pass # Replace with function body.
