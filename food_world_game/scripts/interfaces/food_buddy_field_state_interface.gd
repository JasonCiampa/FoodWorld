extends Node2D

class_name FoodBuddyFieldStateInterface


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Food Buddy FieldState Interface #
var active: bool = false
var selected_food_buddy: FoodBuddy
var unselected_food_buddy: FoodBuddy

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



# Called every frame. Updates the Enemy's physics
func _physics_process(delta: float) -> void:
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Enables the Food Buddy FieldState Interface and freezes the updating for the given subjects while the Interface is active
func enable(freeze_subjects: Array[Node2D], food_buddies_active: Array[FoodBuddy]):

	# Set Food Buddy 1 as the currently selected Food Buddy in the interface and Food Buddy 2 as the unselected Food Buddy (these are the first two subjects to freeze in the given list)
	selected_food_buddy = food_buddies_active[0]
	unselected_food_buddy = food_buddies_active[1]
	
	print("\nFood Buddy FieldState Interface Opened!\n")
	print("Press 'W' and 'S' to move through FieldState options")
	print("Press 'A' and 'D' to move between Food Buddies\n")
	
	print("Currently Selected: " + str(selected_food_buddy.name))
	print("Current FieldState: " + str(selected_food_buddy.get_enum_value_name(FoodBuddy.FieldState, selected_food_buddy.field_state_current)))
	
	# Enable the Food Buddy FieldState Interface
	active = true
	
	# Pause all of the characters' processing while the interface is active
	for subject in freeze_subjects:
		subject.paused = true



# Disables the Food Buddy FieldState Interface
func disable(unfreeze_subjects: Array[Node2D]):
	print("\nFood Buddy FieldState Interface Closed!" +"\n")
	
	# Disable the Food Buddy FieldState Interface
	active = false
	
	# Unpause all of the characters' processing now that the interface is no longer active
	for subject in unfreeze_subjects:
		subject.paused = false



# Processes all of the logic involved for the Food Buddy FieldState Interface
func process(player: Player, active_food_buddies: Array[FoodBuddy]):
	
	# Determine if the Player's FieldState is not currently FUSION, then process input (if it is Fusion, we don't want to adjust Food Buddy states because they both need to be FUSION)
	if player.field_state_current != player.FieldState.FUSION:
		
		# Store a reference to what the FieldState value is before any updates are made
		var field_state_initial: int = selected_food_buddy.field_state_current
		
		# Determine if the Player has pressed 'W', then decrement the FieldState value by 1
		if Input.is_action_just_pressed("move_up"):
			selected_food_buddy.field_state_current -= 1
			
			# Determine if the FieldState value is out of the lower bound, then set it to the last FieldState before Fusion and Player (Player can only be set by pressing '1' and '2', and Fusion can only be set by pressing '3')
			if selected_food_buddy.field_state_current < 0:
				selected_food_buddy.field_state_current = FoodBuddy.FieldState.size() - 3
			
			print("Current FieldState: " + str(selected_food_buddy.get_enum_value_name(FoodBuddy.FieldState, selected_food_buddy.field_state_current)))
		
		
		# Determine if the Player has pressed 'S', then increment the FieldState value by 1
		elif Input.is_action_just_pressed("move_down"):
			selected_food_buddy.field_state_current += 1
			
			# Determine if the FieldState value is out of the upper bound (the last FieldState before Fusion), then set it to the first FieldState (Fusion can only be set by pressing '3')
			if selected_food_buddy.field_state_current > FoodBuddy.FieldState.size() - 2:
				selected_food_buddy.field_state_current = 0
			
			print("Current FieldState: " + str(selected_food_buddy.get_enum_value_name(FoodBuddy.FieldState, selected_food_buddy.field_state_current)))
		
		
		# Determine if the two Food Buddies both have the PLAYER FieldState after the latest adjustment, then revert the latest adjustment because only one Food Buddy can have the PLAYER FieldState at a time
		if unselected_food_buddy.field_state_current == FoodBuddy.FieldState.PLAYER and selected_food_buddy.field_state_current == FoodBuddy.FieldState.PLAYER:
			selected_food_buddy.field_state_current = field_state_initial
			print("Reverted FieldState back to " + str(field_state_initial) + ". Only one Food Buddy can have the PLAYER FieldState at once!")
			return
		
		
	# Determine if the Player has pressed 'A' or 'S', then swap the currently selected Food Buddy
	if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right"):
		
		if active_food_buddies[0] == selected_food_buddy:
			selected_food_buddy = active_food_buddies[1]
			unselected_food_buddy = active_food_buddies[0]
		else:
			selected_food_buddy = active_food_buddies[0]
			unselected_food_buddy = active_food_buddies[1]
		
		print("\nCurrently Selected: " + str(selected_food_buddy.name))
		print("Current FieldState: " + str(selected_food_buddy.get_enum_value_name(FoodBuddy.FieldState, selected_food_buddy.field_state_current)))

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
