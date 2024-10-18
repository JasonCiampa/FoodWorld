extends Node2D

# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

@onready var PLAYER: Player = $Player
@onready var ENEMY: Enemy = $Enemy

@onready var MALICK: FoodBuddy = $Malick
@onready var SALLY: FoodBuddy = $Sally

@onready var FUSION_MALICK_SALLY: FoodBuddyFusion = load("res://scenes/malick_sally.tscn").instantiate()

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

enum World { SWEETS, GARDEN, COLISEUM, MEAT, SEAFOOD, JUNKFOOD, PERISHABLE, SPUD }

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Enemies #
@onready var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")


# Food Buddies #
var food_buddies_active: Array[FoodBuddy]
var food_buddies_inactive: Array[FoodBuddy]
var food_buddies_locked: Array[FoodBuddy]


# Food Fusions # 
var food_buddy_fusion_active: FoodBuddyFusion
var food_buddy_fusions_inactive: Array[FoodBuddyFusion]
var food_buddy_fusions_locked: Array[FoodBuddyFusion]


# Food Buddy FieldState Interface #
var field_state_interface_active: bool = false
var field_state_interface_selected_food_buddy: FoodBuddy
var field_state_interface_unselected_food_buddy: FoodBuddy


# Dialogue Interface #
var dialogue_interface_active: bool = false
var dialogue_interface_sleeping: bool = false

var dialogue_interface_characters_active: Array[Node2D]
var dialogue_interface_initiator: Node2D
var dialogue_interface_current_dialogue: Dialogue
var dialogue_interface_line_displayed: bool
var dialogue_interface_current_speaker: Node2D

var dialogue_interface_directions: Dictionary = {"GAME": {"Direction": "", "Processing": false}, "DIALOGUE": {"Direction": "", "Processing": false}}

var dialogue_interface_game_direction: String
var dialogue_interface_dialogue_direction: String

var dialogue_interface_dialogue_moving_forwards: bool


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	food_buddies_active.append(MALICK)
	food_buddies_active.append(SALLY)
	
	FUSION_MALICK_SALLY.set_food_buddies(MALICK, SALLY)
	food_buddy_fusions_inactive.append(FUSION_MALICK_SALLY)
	
	# Disable the Dialogue Interface and remove any of it's stored values
	dialogue_interface_active = true
	
	# Load in the current dialogue
	dialogue_interface_current_dialogue = load("res://dialogue/Malick-Player-Sally.tres")
	
	# Set the current conversation
	dialogue_interface_current_dialogue.conversation_current = dialogue_interface_current_dialogue.conversations["Candy-Castle-Dungeon-1"]
	dialogue_interface_current_dialogue.current_line = dialogue_interface_current_dialogue.conversation_current["Player"][1]
	dialogue_interface_current_dialogue.current_line_number = 1
	dialogue_interface_current_dialogue.furthest_line_reached = 1
	dialogue_interface_current_dialogue.current_speaker_name = "Player"
	dialogue_interface_characters_active = [MALICK, PLAYER, SALLY]
	dialogue_interface_initiator = PLAYER
	dialogue_interface_line_displayed = false
	dialogue_interface_current_speaker = PLAYER
	
	#dialogue_interface_current_dialogue.create_and_save_resource("Malick-Player-Sally")
	
	# Pause all of the characters' processing while the interface is active
	MALICK.process_mode = PROCESS_MODE_DISABLED
	SALLY.process_mode = PROCESS_MODE_DISABLED
	ENEMY.process_mode = PROCESS_MODE_DISABLED
	PLAYER.paused = true



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if field_state_interface_active:
		process_field_state_interface()
	
	if dialogue_interface_active:
		process_dialogue_interface(delta)



# Called every frame. Updates the Player's physics
func _physics_process(delta: float) -> void:
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Processes all of the logic involved for the Food Buddy FieldState Interface
func process_field_state_interface():
	
	# Determine if the Player's FieldState is not currently FUSION, then process input (if it is Fusion, we don't want to adjust Food Buddy states because they both need to be FUSION)
	if PLAYER.field_state_current != PLAYER.FieldState.FUSION:
		
		# Store a reference to what the FieldState value is before any updates are made
		var field_state_initial: int = field_state_interface_selected_food_buddy.field_state_current
		
		# Determine if the Player has pressed 'W', then decrement the FieldState value by 1
		if Input.is_action_just_pressed("move_up"):
			field_state_interface_selected_food_buddy.field_state_current -= 1
			
			# Determine if the FieldState value is out of the lower bound, then set it to the last FieldState before Fusion (Fusion can only be set by pressing '3')
			if field_state_interface_selected_food_buddy.field_state_current < 0:
				field_state_interface_selected_food_buddy.field_state_current = FoodBuddy.FieldState.size() - 2
			
			print("Current FieldState: " + str(field_state_interface_selected_food_buddy.field_state_current))
		
		
		# Determine if the Player has pressed 'S', then increment the FieldState value by 1
		elif Input.is_action_just_pressed("move_down"):
			field_state_interface_selected_food_buddy.field_state_current += 1
			
			# Determine if the FieldState value is out of the upper bound (the last FieldState before Fusion), then set it to the first FieldState (Fusion can only be set by pressing '3')
			if field_state_interface_selected_food_buddy.field_state_current > FoodBuddy.FieldState.size() - 2:
				field_state_interface_selected_food_buddy.field_state_current = 0
			
			print("Current FieldState: " + str(field_state_interface_selected_food_buddy.field_state_current))
		
		
		# Determine if the two Food Buddies both have the PLAYER FieldState after the latest adjustment, then revert the latest adjustment because only one Food Buddy can have the PLAYER FieldState at a time
		if field_state_interface_unselected_food_buddy.field_state_current == FoodBuddy.FieldState.PLAYER and field_state_interface_selected_food_buddy.field_state_current == FoodBuddy.FieldState.PLAYER:
			field_state_interface_selected_food_buddy.field_state_current = field_state_initial
			print("Reverted FieldState back to " + str(field_state_initial) + ". Only one Food Buddy can have the PLAYER FieldState at once!")
			return
		
		
	# Determine if the Player has pressed 'A' or 'S', then swap the currently selected Food Buddy
	if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right"):
		
		if food_buddies_active[0] == field_state_interface_selected_food_buddy:
			field_state_interface_selected_food_buddy = food_buddies_active[1]
			field_state_interface_unselected_food_buddy = food_buddies_active[0]
		else:
			field_state_interface_selected_food_buddy = food_buddies_active[0]
			field_state_interface_unselected_food_buddy = food_buddies_active[1]
		
		print("\nCurrently Selected: " + str(field_state_interface_selected_food_buddy.name))
		print("Current FieldState: " + str(field_state_interface_selected_food_buddy.field_state_current))


# Puts the Dialogue Interface to sleep so that it will not process Dialogue and Player Input until it wakes
func dialogue_interface_sleep():
	
	# Determine if the Dialogue Interface is not already asleep, then play an animation to put it so sleep
	if not dialogue_interface_sleeping:
		pass
		# Play an animation to hide the Dialogue Interface
	
	# Set the interface to be sleeping so it remains active but none of the Dialogue is updated
	dialogue_interface_sleeping = true



# Wakes up the Dialogue Interface so that it will begin processing Dialogue and Player Input again
func dialogue_interface_wake():
	
	# Determine if the Dialogue Interface is asleep, then play an animation to wake it
	if dialogue_interface_sleeping:
		pass
		# Play an animation to show the Dialogue Interface
	
	# Set the interface to not be sleeping so it starts updating Dialogue again
	dialogue_interface_sleeping = false
	

# Processes all of the logic involved for the Dialogue Interface
func process_dialogue_interface(delta: float):
	
	# Determine if the Dialogue Interface is currently processing a Game Direction from the Dialogue Resource, then continue processing it
	if dialogue_interface_directions["GAME"]["Processing"]:
		# Process Game Direction
		print("Game Instruction: " + dialogue_interface_directions["GAME"]["Direction"])
		# If Game Direction is done being processed, set the Game value in the processing dictionary to false and remove the Game Direction from the direction dictionary, and wake up the Dialogue Interface
		dialogue_interface_directions["GAME"]["Processing"] = false
		dialogue_interface_directions["GAME"]["Direction"] = ""
		dialogue_interface_wake()
		return
	
	# Determine if the Dialogue Interface is currently processing a Dialogue Direction from the Dialogue Resource, then continue processing it
	if dialogue_interface_directions["DIALOGUE"]["Processing"]:
		# Process Dialogue Direction
		print("Dialogue Instruction: " + dialogue_interface_directions["DIALOGUE"]["Direction"])

		# If Dialogue Direction is done being processed, set the Dialogue value in the processing dictionary to false and remove the Dialogue Direction from the direction dictionary
		dialogue_interface_directions["DIALOGUE"]["Processing"] = false
		dialogue_interface_directions["DIALOGUE"]["Direction"] = ""
		return
	
	# Determine if the current line of Dialogue is a Game or Dialogue Direction, then set the interface to appropriately handle the direction
	if dialogue_interface_current_dialogue.current_speaker_name == "GAME" or dialogue_interface_current_dialogue.current_speaker_name == "DIALOGUE":
		
		# Determine if the Dialogue is moving forwards, then store the Game Direction, advance the line to the the actual Dialogue, and begin processing the Game Direction
		if dialogue_interface_dialogue_moving_forwards:
			dialogue_interface_directions[dialogue_interface_current_dialogue.current_speaker_name]["Direction"] = dialogue_interface_current_dialogue.current_line
			dialogue_interface_directions[dialogue_interface_current_dialogue.current_speaker_name]["Processing"] = true
			dialogue_interface_current_dialogue.adjust_current_line(true)
			
		# The Dialogue is moving backwards which means no Game Directions need to be executed, so adjust the current line backwards
		else:
			dialogue_interface_current_dialogue.adjust_current_line(false)
		
		# Return so that the new current line can be processed appropriately
		return
	
	
	# Determine if the current line of Dialogue hasn't been displayed, then display it
	if not dialogue_interface_line_displayed:
		
		# Iterate over characters of String and print them out (like I did in the Pokemon Game)
		print("[" + str(dialogue_interface_current_dialogue.current_line_number) + "]  " + dialogue_interface_current_dialogue.current_speaker_name + ": " + dialogue_interface_current_dialogue.current_line)
		
		# If all of the characters of the current line have been displayed:
		dialogue_interface_line_displayed = true
		
	else:
		# Detect if the Player has tried to move backwards or forwards with the Dialogue, then adjust the current line in the Dialogue, flag the line to be displayed, and store the current direction of Dialogue
		if Input.is_action_just_pressed("ability1"):
			if dialogue_interface_current_dialogue.adjust_current_line(false):
				dialogue_interface_line_displayed = false
				dialogue_interface_dialogue_moving_forwards = false
		
		elif Input.is_action_just_pressed("ability2"):
			if dialogue_interface_current_dialogue.adjust_current_line(true):
				dialogue_interface_line_displayed = false
				dialogue_interface_dialogue_moving_forwards = true


# Determines which enemies are currently on-screen and returns them in a list
func get_enemies_on_screen() -> Array[Node2D]:
	
	# Store a list of references to all of the enemies currently loaded into the game, and create an empty list that will hold any enemies on the screen
	var enemies_on_screen: Array[Node2D] = []
	
	# Iterate over all of the enemies currently loaded in the game
	for enemy in enemies:
		
		# Determine if the enemy is on-screen, then add them to a list of on-screen enemies
		if enemy.on_screen_notifier.is_on_screen():
			enemies_on_screen.append(enemy)
	
	return enemies_on_screen



# Determines which target in a given list of targets is closest to the subject and returns that target (or null if no targets on-screen)
func select_closest_target(subject: Node2D, targets: Array) -> Node2D:
	
	# Determine if there are no targets in the provided list of targets, then return null because there are no targets to choose from
	if targets.size() == 0:
		return null
	
	# Determine if there are is only one target in the provided list of targets, then return null because it is the only target and therefore the closest
	if targets.size() == 1:
		return targets[0]
		
	# Temporarily store the first target in the list of targets as the closest target and also store it's distance from the subject
	var target_closest = targets[0]
	var target_closest_distance = subject.position.distance_to(target_closest.position)
	
	# Iterate over all of the targets in the given list
	for target in targets:
		
		# Calculate and store the distance between the subject and the target of this iteration
		var target_distance: float = subject.position.distance_to(target.position)
		
		# Determine if the target's distance is closer than the closest target's distance, then set that target as the new closest target
		if target_distance < target_closest_distance:
			target_closest = target
			target_closest_distance = target_distance
	
	return target_closest



# Moves the subject towards a given target, stops it if it reaches the given distance, then returns the current distance between the two
func move_towards_target(subject: Node2D, target: Node2D, desired_distance: float) -> float:
	
	# Determine the subject's position compared to the target's, then adjust the subject's velocity so that they move towards the target 
	if subject.position.x < target.position.x:
		subject.velocity.x = subject.speed_current
	
	elif subject.position.x > target.position.x:
		subject.velocity.x = -subject.speed_current
	
	if subject.position.y < target.position.y:
		subject.velocity.y = subject.speed_current
	
	elif subject.position.y > target.position.y:
		subject.velocity.y = -subject.speed_current
	
	# Calculate the distance from the subject to the target
	var target_distance = subject.position.distance_to(target.position)
	
	# Determine if the subject has approximately reached the desired distance away from the target, then make them stop moving
	if target_distance <= desired_distance:
		subject.velocity.x = 0
		subject.velocity.y = 0
	
	# Return the distance from the subject to the target
	return target_distance



# Determines if an attack has landed on the target and reduces the target's health if it has. Returns true if the attack landed on the target, false if not.
func process_attack(target: Node2D, attacker: Node2D, damage: int) -> bool:
	
	# Store a list of all hitboxes that the hitbox of the attack has overlapped with
	var hitboxes = attacker.hitbox.get_overlapping_areas()
	
	# Determine if the attacked Node's hitbox is in the list of hitboxes that the attack's hitbox overlapped with, then reduce their health
	if target.hitbox in hitboxes:
		target.health_current -= damage
		
		# Determine if the attacked Node has run out of health, then emit their death signal
		if target.health_current <= 0:
			target.die.emit(target)
			target.alive = false
			attacker.killed_target.emit(attacker)
		
		return true
	
	return false



# Determines the correct Food Buddy Fusion Node based on the two given Food Buddies
func equip_food_buddy_fusion() -> FoodBuddyFusion:
	
	# Iterate over each Food Buddy Fusion
	for fusion in food_buddy_fusions_inactive:
		
		# Determine if the two currently active Food Buddies match the two Food Buddies of the fusion, then return the fusion
		if (fusion.food_buddy1 == food_buddies_active[0] and fusion.food_buddy2 == food_buddies_active[1]) or (fusion.food_buddy1 == food_buddies_active[1] and fusion.food_buddy2 == food_buddies_active[0]):
			food_buddy_fusion_active = fusion
			add_child(food_buddy_fusion_active)
		
	# Return the currently active Food Buddy Fusion
	return food_buddy_fusion_active



# Unequips the Food Buddy Fusion that is currently active
func unequip_food_buddy_fusion():
	
	# Store local references to the Food Buddies whose FieldStates should be adjusted so we don't have to access the list multiple times
	var food_buddy1: FoodBuddy = food_buddies_active[0]
	var food_buddy2: FoodBuddy = food_buddies_active[1]

	food_buddy1.field_state_current = FoodBuddy.FieldState.FOLLOW
	food_buddy1.field_state_previous = FoodBuddy.FieldState.FUSION
	
	food_buddy2.field_state_current = FoodBuddy.FieldState.FOLLOW
	food_buddy2.field_state_previous = FoodBuddy.FieldState.FUSION
	
	add_child(food_buddy1)
	add_child(food_buddy2)
	
	remove_child(food_buddy_fusion_active)
	food_buddy_fusion_active = null



# Determines which world the Player is currently located in
func determine_player_location_world() -> World:
	
	# Implement checks to find out which world the Player is in based on the tile type that they're touching and their coordinates and return the correct world
	
	return World.COLISEUM


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# CALLBACK FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# PLAYER CALLBACKS # ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Callback function that executes whenever the Player equips or unequips a Food Buddy: finds the buddy that corresponds to the given buddy number and sets its FieldState to PLAYER if being equipped or to the appropriate FieldState if being unequipped
func _on_player_toggle_buddy_equipped(buddy_number: int) -> void:
	
	# Create variables for the two Food Buddies that will be considered in this Food Buddy equip/unequip
	var food_buddy_selected: FoodBuddy
	var food_buddy_other: FoodBuddy
	
	
	# Determine which Food Buddy was selected by the Player based on the emitted buddy_number and which Food Buddy wasn't, then store a local reference to each of them so we don't have to access the Food Buddies list multiple times
	if buddy_number >= 2:
		food_buddy_selected = food_buddies_active[1]
		food_buddy_other = food_buddies_active[0]
	else:
		food_buddy_selected = food_buddies_active[0]
		food_buddy_other = food_buddies_active[1]
	
	
	# Determine if the Player already had the Food Buddy equipped, then revert the Food Buddy back to its previous FieldState since the Player is trying to unequip it
	if food_buddy_selected.field_state_current == FoodBuddy.FieldState.PLAYER:
		food_buddy_selected.field_state_current = food_buddy_selected.field_state_previous
		food_buddy_selected.field_state_previous = FoodBuddy.FieldState.PLAYER
	else:
		
		# Determine if the Food Buddy that wasn't selected is currently the Player's active Food Buddy or if a Food Buddy Fusion is currently active
		if food_buddy_other.field_state_current == FoodBuddy.FieldState.PLAYER or food_buddy_other.field_state_current == FoodBuddy.FieldState.FUSION:
			
			# Determine if a FoodBuddyFusion is equipped, then unequip it and revert the two Food Buddies back to the FOLLOW FieldState
			if food_buddy_fusion_active != null:
				unequip_food_buddy_fusion()
			else:
				# Revert the unselected Food Buddy to their previous FieldState because the selected Food Buddy is swapping places with it (only one Food Buddy in PLAYER FieldState at a time)
				food_buddy_other.field_state_current = food_buddy_other.field_state_previous
				food_buddy_other.field_state_previous = FoodBuddy.FieldState.PLAYER
		
		# Update the selected Food Buddy's FieldState variables
		food_buddy_selected.field_state_previous = food_buddy_selected.field_state_current
		food_buddy_selected.field_state_current = FoodBuddy.FieldState.PLAYER



# Callback function that executes whenever the Player equips or unequips a Food Buddy Fusion: sets the Food Buddies to the FOLLOW FieldState if a Food Buddy Fusion is already active & sets the Food Buddy Fusion to null, or updates the FieldStates of the Food Buddies to FUSION if they are being equipped
func _on_player_toggle_buddy_fusion_equipped() -> void:
	
	# Determine if a FoodBuddyFusion is already equipped, then unequip it and revert the two Food Buddies back to their previous FieldStates
	if food_buddy_fusion_active != null:
		unequip_food_buddy_fusion()
		return
	
	# Store local references to the Food Buddies whose FieldStates should be adjusted so we don't have to access the list multiple times
	var food_buddy1: FoodBuddy = food_buddies_active[0]
	var food_buddy2: FoodBuddy = food_buddies_active[1]
	
	# Determine if a valid Food Buddy Fusion for the currently active Food Buddies was found, then update the field states of the Player and Food Buddies
	if equip_food_buddy_fusion() != null:
		
		# Update the Food Buddy's FieldState variables
		food_buddy1.field_state_previous = food_buddy1.field_state_current
		food_buddy2.field_state_previous = food_buddy2.field_state_current
		
		food_buddy1.field_state_current = FoodBuddy.FieldState.FUSION
		food_buddy2.field_state_current = FoodBuddy.FieldState.FUSION
		
		# Remove the individual Food Buddies from the SceneTree while the Food Buddy Fusion occurs since they'll all be merged into one animation
		remove_child(food_buddy1)
		remove_child(food_buddy2)
	else:
		PLAYER.field_state_current = PLAYER.field_state_previous



# Callback function that executes whenever the Player wants to trigger the Food Buddy FieldState updating interface: opens/closes the interface depending on the interface's current state
func _on_player_toggle_field_state_interface() -> void:
	
	# Determine if the Food Buddy FieldState Interface isn't currently active, then activate it
	if not field_state_interface_active:
		
		# Set Food Buddy 1 as the currently selected Food Buddy in the interface and Food Buddy 2 as the unselected Food Buddy
		field_state_interface_selected_food_buddy = food_buddies_active[0]
		field_state_interface_unselected_food_buddy = food_buddies_active[1]
		
		print("\nFood Buddy FieldState Interface Opened!\n")
		print("Press 'W' and 'S' to move through FieldState options")
		print("Press 'A' and 'D' to move between Food Buddies\n")

		print("Currently Selected: " + str(field_state_interface_selected_food_buddy.name))
		print("Current FieldState: " + str(field_state_interface_selected_food_buddy.field_state_current))
		
		# Enable the Food Buddy FieldState Interface
		field_state_interface_active = true
		
		# Pause all of the characters' processing while the interface is active
		MALICK.process_mode = PROCESS_MODE_DISABLED
		SALLY.process_mode = PROCESS_MODE_DISABLED
		ENEMY.process_mode = PROCESS_MODE_DISABLED
		PLAYER.paused = true
		
	else:
		print("\nFood Buddy FieldState Interface Closed!" +"\n")

		# Disable the Food Buddy FieldState Interface
		field_state_interface_active = false
		
		# Unpause all of the characters' processing now that the interface is no longer active
		MALICK.process_mode = PROCESS_MODE_ALWAYS
		SALLY.process_mode = PROCESS_MODE_ALWAYS
		ENEMY.process_mode = PROCESS_MODE_ALWAYS
		PLAYER.paused = false



# Callback function that executes whenever the Player wants to trigger the Dialogue interface: opens/closes the interface depending on the interface's current state
func _on_player_toggle_dialogue_interface(characters: Array[Node2D], dialogue_initiator: Node2D) -> void:
	
	# Determine if the Dialogue Interface isn't currently active, then activate it
	if not field_state_interface_active:
		
		# Create an empty Array that will hold Character names
		var character_names: Array[String] = []
		
		# Add each Character's name to the list
		for character in characters:
			character_names.append(character.name)
		
		# Sort the Array of Character names alphabetically
		character_names.sort()
		
		# Create an empty String that will hold the name of the Dialogue Resource file to load into the Dialogue Interface
		var file_name: String = "-"
		
		# Generate the name of the Dialogue Resource file by formatting each Character's name into the file name
		for name in character_names:
			file_name += (name + "-")
		
		# Load in the Dialogue Resource File, then store it into the Dialogue Interface along with the Characters involved and the Character who initiated the Dialogue
		dialogue_interface_current_dialogue = load("res://" + file_name + ".tres")
		dialogue_interface_characters_active = characters
		dialogue_interface_initiator = dialogue_initiator
		
		dialogue_interface_current_dialogue = load("res://dialogue.tres")
		dialogue_interface_current_dialogue.conversation_current = dialogue_interface_current_dialogue.conversations[0]["Violent Intro Conversation"]
		dialogue_interface_current_dialogue.current_line = dialogue_interface_current_dialogue.conversation_current["Player"][1]
		dialogue_interface_current_dialogue.current_line_number = 1
		
		dialogue_interface_characters_active = [PLAYER, MALICK]
		dialogue_interface_initiator = PLAYER
		dialogue_interface_line_displayed = false
		dialogue_interface_current_speaker = PLAYER
		
		# Enable the Dialogue Interface
		dialogue_interface_active = true
		
		# Pause all of the characters' processing while the interface is active
		MALICK.process_mode = PROCESS_MODE_DISABLED
		SALLY.process_mode = PROCESS_MODE_DISABLED
		ENEMY.process_mode = PROCESS_MODE_DISABLED
		PLAYER.paused = true
		
	else:
		# Disable the Dialogue Interface and remove any of it's stored values
		dialogue_interface_active = false
		dialogue_interface_current_dialogue = null
		dialogue_interface_characters_active = []
		dialogue_interface_initiator = null
		
		# Unpause all of the characters' processing now that the interface is no longer active
		MALICK.process_mode = PROCESS_MODE_ALWAYS
		SALLY.process_mode = PROCESS_MODE_ALWAYS
		ENEMY.process_mode = PROCESS_MODE_ALWAYS
		PLAYER.paused = false


# Callback function that executes whenever the Player wants to use a solo ability: processes the solo attack against enemies
func _on_player_use_ability_solo(damage: int) -> void:
	
	# Iterate over every enemy currently on the screen to check if the Player's attack landed on them, then stop checking if the attack landed because the Player's solo ability can only damage one enemy at a time
	for enemy in get_enemies_on_screen():
		if process_attack(enemy, PLAYER, damage):
			return



# Callback function that executes whenever the Player has triggered the use of an ability while using a Food Buddy: executes the Food Buddy's ability
func _on_player_use_ability_buddy(buddy_number: int, ability_number: int) -> void:
	if ability_number == 1:
		food_buddies_active[buddy_number -1].use_ability1()
	elif ability_number == 2:
		food_buddies_active[buddy_number -1].use_ability2()
	else:
		food_buddies_active[buddy_number -1].use_special_attack()



# Callback function that executes whenever the Player has triggered the use of an ability while using a Food Buddy Fusion: executes the Food Buddy Fusion's ability
func _on_player_use_ability_buddy_fusion(ability_number: int) -> void:
	if ability_number == 1:
		food_buddy_fusion_active.use_ability1()
	elif ability_number == 2:
		food_buddy_fusion_active.use_ability2()
	else:
		food_buddy_fusion_active.use_special_attack()



# Callback function that executes whenever the Player has killed their target: sets the Player's target to null
func _on_player_killed_target() -> void:
	# Increase XP for killing an enemy
	pass



# Callback function that executes whenever the Player dies: removes the Player from the SceneTree
func _on_player_die(player: Player) -> void:
	remove_child(player)
	print("Player has died!")



# FOOD BUDDY CALLBACKS # ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	

# Callback function that executes whenever the Food Buddy wants to use a solo ability: processes the solo attack against enemies
func _on_food_buddy_use_ability_solo(food_buddy: FoodBuddy, damage: int) -> void:
	
	# Iterate over every enemy currently on the screen to check if the Food Buddy's attack landed on them
	for enemy in get_enemies_on_screen():
		process_attack(enemy, food_buddy, damage)



# Callback function that executes whenever the Food Buddy wants to set the Player as it's target: sets the Player as the target of the Food Buddy
func _on_food_buddy_target_player(food_buddy: FoodBuddy) -> void:
	food_buddy.target = PLAYER



# Callback function that executes whenever the Food Buddy wants to select the closest enemy as it's target: sets the closest enemy as the Food Buddy's target
func _on_food_buddy_target_closest_enemy(food_buddy: FoodBuddy) -> void:
	
	# Stores a local reference to the result of searching for the closest Enemy target
	var target_closest = select_closest_target(food_buddy, get_enemies_on_screen())
	
	# Determines if the target exists, then set them as the Food Buddy's target and update the target distance
	if target_closest != null:
		food_buddy.target = target_closest
		food_buddy.target_distance = food_buddy.position.distance_to(target_closest.position)
	else:
		food_buddy.target = null
		food_buddy.target_distance = 0



# Callback function that executes whenever the Food Buddy wants to move towards an enemy: moves the Food Buddy towards the given enemy
func _on_food_buddy_move_towards_target(food_buddy: FoodBuddy, target: Node2D, desired_distance: float) -> void:
	food_buddy.target_distance = move_towards_target(food_buddy, target, desired_distance)



# Callback function that executes whenever the Food Buddy has killed their target: sets the Food Buddy's target to null
func _on_food_buddy_killed_target(food_buddy: FoodBuddy) -> void:
	food_buddy.target = null
	# Increase XP for killing an enemy



# Callback function that executes whenever the Food Buddy dies: removes the Food Buddy from the SceneTree
func _on_food_buddy_die(food_buddy: FoodBuddy) -> void:
	
	# Determine which Food Buddy in the list of active Food Buddies just died, then remove it from the list since it is no longer active
	if food_buddy == food_buddies_active[0]:
		food_buddies_active.remove_at(0)
	else:
		food_buddies_active.remove_at(1)
	
	# Remove the Food Buddy from the Game's SceneTree
	remove_child(food_buddy)
	
	print("Food Buddy has died!")



# ENEMY CALLBACKS # -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Callback function that executes whenever the Enemy wants to use an ability: processes the ability against the Enemy's target
func _on_enemy_use_ability(enemy: Enemy, damage: int) -> void:
	process_attack(enemy.target, enemy, damage)



# Callback function that executes whenever the Enemy wants to set the Player as it's target: sets the Player as the target of the Enemy
func _on_enemy_target_player(enemy: Enemy) -> void:
	enemy.target = PLAYER



# Callback function that executes whenever the Enemy wants to set the closest Food Buddy as it's target: sets the closest Food Buddy as the target of the Enemy
func _on_enemy_target_closest_food_buddy(enemy: Enemy) -> void:
	
	# Store a local reference to the result of searching for the closest Food Buddy target
	var target_closest = select_closest_target(enemy, food_buddies_active)
		
	# Determine if the target exists, then set them as the Enemy's target and update the target distance
	if target_closest != null:
		enemy.target = target_closest
		enemy.target_distance = enemy.position.distance_to(target_closest.position)
	else:
		enemy.target = null
		enemy.target_distance = 0



# Callback function that executes whenever the Enemy wants to move towards an enemy: moves the Enemy towards the given enemy
func _on_enemy_move_towards_target(enemy: Enemy, target: Node2D, desired_distance: float) -> void:
	enemy.target_distance = move_towards_target(enemy, target, desired_distance)



# Callback function that executes whenever the Enemy has killed their target: sets the Enemy's target to null
func _on_enemy_killed_target(enemy: Enemy) -> void:
	enemy.target = null
	enemy.target_distance = 0



# Callback function that executes whenever an Enemy dies: removes the Enemy from the SceneTree
func _on_enemy_die(enemy: Enemy) -> void:
	remove_child(enemy)
	print("Enemy has died!")
