extends Node2D


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

@onready var PLAYER: Player = $Player
@onready var ENEMY: Enemy = $Enemy

@onready var MALICK: FoodBuddy = $Malick
@onready var SALLY: FoodBuddy = $Sally

@onready var FUSION_MALICK_SALLY: FoodBuddyFusion = load("res://scenes/fusions/malick-sally.tscn").instantiate()

var food_citizen = load("res://scenes/blueprints/food-citizen.tscn").instantiate()

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

enum World { SWEETS, GARDEN, COLISEUM, MEAT, SEAFOOD, JUNKFOOD, PERISHABLE, SPUD }

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Enemies #
@onready var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")


# Food Citizens #
@onready var food_citizens: Array[Node] = get_tree().get_nodes_in_group("food_citizens")


# Interactables #
@onready var interactables: Array[Node] = get_tree().get_nodes_in_group("interactables")
var closest_interactable_to_player: Node2D


# Food Buddies #
var food_buddies_active: Array[FoodBuddy]
var food_buddies_inactive: Array[FoodBuddy]
var food_buddies_locked: Array[FoodBuddy]


# Food Fusions # 
var food_buddy_fusion_active: FoodBuddyFusion
var food_buddy_fusions_inactive: Array[FoodBuddyFusion]
var food_buddy_fusions_locked: Array[FoodBuddyFusion]


# Interfaces #
var InterfaceFoodBuddyFieldState: FoodBuddyFieldStateInterface = load("res://scenes/interfaces/food-buddy-field-state-interface.tscn").instantiate()
var InterfaceDialogue: DialogueInterface = load("res://scenes/interfaces/dialogue-interface.tscn").instantiate()


# Managers #
var GameTileManager: TileManager = load("res://scripts/tile-manager.gd").new()

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Add Malick and Sally into the active Food Buddies list
	food_buddies_active.append(MALICK)
	food_buddies_active.append(SALLY)
	
	# Set Malick and Sally as the Food Buddies to fuse, and store the fusion in the list of inactive fusions
	FUSION_MALICK_SALLY.set_food_buddies(MALICK, SALLY)
	food_buddy_fusions_inactive.append(FUSION_MALICK_SALLY)
	
	# Set the current TileMapLayers for the TileManager
	GameTileManager.tilemap_ground = $"World Map/Town Center/Ground"
	GameTileManager.tilemap_terrain = $"World Map/Town Center/Terrain"
	GameTileManager.tilemap_environment = $"World Map/Town Center/Environment"
	
	# Connect all of the Food Citizen's signals to the Game
	#food_citizen.target_player.connect(_on_character_target_player)
	#food_citizen.target_closest_food_buddy.connect(_on_character_target_closest_food_buddy)
	#food_citizen.move_towards_target.connect(_on_character_move_towards_target)
	#food_citizen.die.connect(_on_character_die)
	
	## Add the Food Citizen to the Game's SceneTree
	#add_child(food_citizen)
	
	## CREATE NEW DIALOGUE RESOURCE CODE
	#InterfaceDialogue.current_dialogue = load("res://dialogue.tres")
	#
	#var temp = ["Malick-Player-Sally", "Malick-Player", "Citizen-Player", "Player-Sally"]
	#
	#for name in temp:
		#InterfaceDialogue.current_dialogue.create_and_save_resource(name)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# Update the list of on-screen enemies, food citizens, and interactables
	enemies = get_tree().get_nodes_in_group("enemies")
	food_citizens = get_tree().get_nodes_in_group("food_citizens")
	interactables = get_tree().get_nodes_in_group("interactables")
	
	# Process the Tiles that are nearby the Player, Malick, and Sally on the ground, terrain, and environment tilemaps
	GameTileManager.process_nearby_tiles([GameTileManager.tilemap_ground, GameTileManager.tilemap_terrain, GameTileManager.tilemap_environment], PLAYER, 2)
	GameTileManager.process_nearby_tiles([GameTileManager.tilemap_ground, GameTileManager.tilemap_terrain, GameTileManager.tilemap_environment], MALICK, 3)
	GameTileManager.process_nearby_tiles([GameTileManager.tilemap_ground, GameTileManager.tilemap_terrain, GameTileManager.tilemap_environment], SALLY, 2)
	
	#var temp_tile = Tile.new(GameTileManager.tilemap_ground, PLAYER.current_tile_position)
	#print(temp_tile.type)
	#GameTileManager.unload_tile(temp_tile)
	
	# Determine if the Player is not already interacting, then process in-range potential interactions
	if not PLAYER.is_interacting:
		process_player_nearby_interactables()
	
	# Determine if the Dialogue Interface is active, then process it
	if InterfaceDialogue.active:
		InterfaceDialogue.process(delta)
	
	# Determine if the FieldState Interface is active, then process it
	if InterfaceFoodBuddyFieldState.active:
		InterfaceFoodBuddyFieldState.process(food_buddies_active)



# Called every frame. Updates the Player's physics
func _physics_process(_delta: float) -> void:
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Determines which enemies are currently on-screen and returns them in a list
func get_enemies_on_screen() -> Array[Node2D]:
	
	# Create an empty list that will hold any enemies on the screen
	var enemies_on_screen: Array[Node2D] = []
	
	# Iterate over all of the enemies currently loaded in the game
	for enemy in enemies:
		
		# Determine if the enemy is on-screen, then add them to a list of on-screen enemies
		if enemy.on_screen_notifier.is_on_screen():
			enemies_on_screen.append(enemy)
	
	return enemies_on_screen



# Determines which interactables are currently on-screen and returns them in a list
func get_interactables_on_screen() -> Array[Node2D]:
	
	# Create an empty list that will hold any Interactable on the screen
	var interactables_on_screen: Array[Node2D] = []
	
	# Iterate over each Interactable currently loaded in the game
	for interactable in interactables:

		# Determine if the Interactable is on-screen, then add them to a list of on-screen Interactables
		if interactable.on_screen_notifier.is_on_screen():
			interactables_on_screen.append(interactable)
	
	return interactables_on_screen



# Returns a list of all assets currently in the game
func get_all_assets_on_screen() -> Array[Node2D]:
	
	# Create a list that will store all Assets currently in the game and add the Player into it
	var assets_on_screen: Array[Node2D] = [PLAYER]
	
	# Fetch all on-screen enemies and Interactables and append them to the list of on-screen assets
	for enemy in get_enemies_on_screen():
		assets_on_screen.append(enemy)
		
	for interactable in get_interactables_on_screen():
		assets_on_screen.append(interactable)
	
	return assets_on_screen



# Determines which target in a given list of targets is closest to the subject and returns that target (or returns null if no targets on-screen)
func select_closest_target(subject: Node2D, targets: Array) -> Node2D:
	
	# Determine if there are no targets in the provided list of targets, then return null because there are no targets to choose from
	if targets.size() == 0:
		return null
	
	
	# Determine if there are is only one target in the provided list of targets, then return the target because it is the only target and therefore the closest
	if targets.size() == 1:
		return targets[0]
	
	
	# Temporarily store the first target in the list of targets as the closest target, and also store it's distance from the subject
	var target_closest = targets[0]
	var target_closest_distance = subject.center_point.distance_to(target_closest.center_point)
	
	
	# Iterate over all of the targets in the given list
	for target in targets:
		
		# Calculate and store the distance between the subject and the target of this iteration
		var target_distance: float = subject.center_point.distance_to(target.center_point)
		
		# Determine if the target's distance is closer than the closest target's distance, then set that target as the new closest target
		if target_distance < target_closest_distance:
			target_closest = target
			target_closest_distance = target_distance
	
	
	return target_closest



# Moves the subject towards a given target, stops it if it reaches the given distance, then returns the current distance between the two
func move_towards_target(subject: GameCharacter, target: Node2D, desired_distance: float) -> float:
	
	# Determine the subject's position compared to the target's, then adjust the subject's velocity so that they move towards the target 
	if subject.center_point.x < target.center_point.x:
		subject.velocity.x = subject.speed_current
	
	elif subject.center_point.x > target.center_point.x:
		subject.velocity.x = -subject.speed_current
	
	if subject.center_point.y < target.center_point.y:
		subject.velocity.y = subject.speed_current
	
	elif subject.center_point.y > target.center_point.y:
		subject.velocity.y = -subject.speed_current
	
	# Calculate the distance from the subject to the target
	var target_distance = subject.global_position.distance_to(target.global_position)
	
	# Determine if the subject has approximately reached the desired distance away from the target, then make them stop moving
	if target_distance <= desired_distance:
		subject.velocity.x = 0
		subject.velocity.y = 0
	
	# Return the distance from the subject to the target
	return target_distance



# Determines if an attack has landed on the target and reduces the target's health if it has. Returns true if the attack landed on the target, false if not.
func process_attack(target: Node2D, attacker: Node2D, damage: int) -> bool:
	
	# Store a list of all hitboxes that the hitbox of the attack has overlapped with
	var hitboxes = attacker.hitbox_damage.get_overlapping_areas()
	
	# Determine if the target's hitbox is in the list of hitboxes that the attack's hitbox overlapped with, then reduce their health
	if target.hitbox_damage in hitboxes:
		
		target.health_current -= damage
		
		# Determine if the attacked Node has run out of health, then emit their death signal
		if target.health_current <= 0:
			target.die.emit(target)
			target.alive = false
			attacker.killed_target.emit(attacker)
		
		return true
	
	return false



# Checks if the Player's Hitbox has overlapped with any other Interactable Asset's Interaction Hitboxes (meaning they are in range of the Player) and enables/disables a label above the Interactable that says to 'Press 'E' To Interact'
func process_player_nearby_interactables():
	
	# Store a list of the coordinates for every Tile in the environment tilemap
	var tile_coords = GameTileManager.tilemap_environment.get_used_cells()
	
	# Iterate over each Tile's coordinates
	for coords in tile_coords:
		
		# Create an instance of the Tile in the environment tilemap at the coords of this iteration
		var tile = Tile.new(GameTileManager.tilemap_environment, coords)
		
		# Determine if the EnvironmentAsset Tile is within range of the Player (range equals the average of half the Player's height plus half the Player's width)
		if coords.distance_to(Vector2i(PLAYER.global_position)) < ((PLAYER.width / 2 + PLAYER.height / 2) / 2):
			
			# Add the EnvironmentAsset Tile to the list of interactables since it is in-range of the Player
			interactables.append(EnvironmentAsset.new())     # Use Tile data as parameters for the environemtasset's .new function (tile type (bush/tree/rock), coords, etc.)
			pass # Instantiate a new EnvironmentAsset Node (derived from Interactable) and set its position to be the exact coordinates of the 
		
		# Unload the Tile of this iteration
		GameTileManager.unload_tile(tile)
		tile = null
	
	
	# Determine if there are no interactables to process, then return the function because there aren't any Interactables to process
	if interactables.size() == 0:
		return
	
	
	# Store a list of all hitboxes that are overlapping with the Player's Hitbox
	var overlapping_hitboxes = PLAYER.hitbox_damage.get_overlapping_areas()
	
	
	# Determine if the closest Interactable to the Player hasn't been stored yet, then store the current in-range Interactable as the closest (temporarily)
	if closest_interactable_to_player == null:
		closest_interactable_to_player = interactables[0]
	
	
	# Iterate over every Asset on-screen that can be Interacted with
	for interactable in get_interactables_on_screen():
		
		# Determine if the Interactable's Interaction hitbox is included in the list of hitboxes that are overlapping with the Player's hitbox, then set the Interactable to be classified as in or out of range of the Player
		if interactable.hitbox_interaction in overlapping_hitboxes:
			interactable.in_range = true
		else:
			interactable.in_range = false
		
		# Determine if the Interactable of this iteration is closer to the Player than the latest closest Interactable is, then set this Interactable as the new current closest
		if interactable.center_point.distance_to(PLAYER.center_point) < closest_interactable_to_player.center_point.distance_to(PLAYER.center_point):
			closest_interactable_to_player.label_e_to_interact.hide()
			closest_interactable_to_player = interactable
	
	
	# Determine whether or not the closest Interactable to the Player is in range of the Player's hitbox, then show/hide their interaction prompt
	if closest_interactable_to_player.in_range:
		closest_interactable_to_player.label_e_to_interact.show()
	else:
		closest_interactable_to_player.label_e_to_interact.hide()



# Processes the use of a Food Buddy or Food Buddy Fusion's ability
func process_food_ability_use(food_entity, ability_number: int):
	
	# Determine if Ability 1 is being used, then process and launch it
	if ability_number == 1:
		
		# Determine if the Player has enough stamina to use the ability, then use the ability
		if process_food_stamina_use(food_entity.ability_stamina_cost["Ability 1"][0], food_entity.ability_stamina_cost["Ability 1"][1]):
			food_entity.use_ability1()
	
	# Otherwise, determine if Ability 2 is being used, then process and launch it
	elif ability_number == 2:
		
		# Determine if the Player has enough stamina to use the ability, then use the ability
		if process_food_stamina_use(food_entity.ability_stamina_cost["Ability 2"][0], food_entity.ability_stamina_cost["Ability 2"][1]):
			food_entity.use_ability2()
	
	# Otherwise, a special attack is being used, so process and launch it
	else:
		food_buddy_fusion_active.use_special_attack()



# Processes a Food Buddy or Food Buddy Fusion's stamina use at the expense of the Player's stamina
func process_food_stamina_use(stamina_cost: int, stamina_depletion_type: String) -> bool:
	
	# Determine if the stamina should be depleted all at once
	if stamina_depletion_type == "Instant":
		
		# Determine if the Player has enough stamina to use the ability, then use it
		if PLAYER.stamina_current >= stamina_cost:
			PLAYER.use_stamina(stamina_cost)
			return true
		
		
	# Determine if the stamina should be depleted over time
	elif stamina_depletion_type == "Gradual":
		
		# Determine if the Player has any stamina left to use the ability, then use it
		if PLAYER.stamina_current >= 0:
			PLAYER.use_stamina(stamina_cost)
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
	
	# Update the Food Buddies' FieldStates to FOLLOW and store FUSION as their previous state
	food_buddy1.field_state_current = FoodBuddy.FieldState.FOLLOW
	food_buddy1.field_state_previous = FoodBuddy.FieldState.FUSION
	
	food_buddy2.field_state_current = FoodBuddy.FieldState.FOLLOW
	food_buddy2.field_state_previous = FoodBuddy.FieldState.FUSION
	
	# Add the individual Food Buddies back into the game
	add_child(food_buddy1)
	add_child(food_buddy2)
	
	# Remove the Food Buddy Fusion from the game
	remove_child(food_buddy_fusion_active)
	food_buddy_fusion_active = null



# Determines which world the Player is currently located in
func determine_player_location_world() -> World:
	
	# Implement checks to find out which world the Player is in based on the tile type that they're touching and their coordinates and return the correct world
	
	return World.COLISEUM

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# CALLBACK FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# PLAYER CALLBACKS #

# Callback function that executes whenever the Player presses 'E' to interact with something
func _on_player_interact() -> void:
	
	var interactables_on_screen = get_interactables_on_screen()
	
	# Determine if the closest Interactable to the Player is in range for an interaction, then trigger the interaction
	if closest_interactable_to_player.in_range:
		
		# Set the Player to be interacting and remove the label above the Interactable
		PLAYER.is_interacting = true
		closest_interactable_to_player.label_e_to_interact.hide()
		
		# Determine if the closest Interactable is an Interactable Character
		if closest_interactable_to_player is FoodCitizen or closest_interactable_to_player is FoodBuddy:
			
			# Create a variable to store all of the in-range Interactable Characters after they're filtered out of from the non-Character Interactables
			var characters_in_range: Array[Node2D] = []
			
			# Iterate over each on-screen Interactable and add the Interactable Characters that are in range of the Player to the previously created list
			for interactable in interactables_on_screen:
				if interactable.in_range and (interactable is FoodBuddy or interactable is FoodCitizen):
					characters_in_range.append(interactable)
			
			# Trigger the interaction in the closest Interactable Character, then save the list of Characters that should be included in the Dialogue
			_on_player_enable_dialogue_interface(closest_interactable_to_player.interact_with_player(PLAYER, characters_in_range))
		
		# Otherwise, determine if the closest Interactable is an EnvironmentAsset
		elif closest_interactable_to_player is EnvironmentAsset:
			
			# Create a variable to store all of the in-range Interactable EnvironmentAsset after they're filtered out of from the non-EnvironmentAsset Interactables
			var characters_in_range: Array[EnvironmentAsset] = []
			
			# Iterate over each Interactable and add the Interactable Characters that are in range of the Player to the previously created list
			for interactable in interactables_on_screen:
				
				if interactable.in_range is EnvironmentAsset:
					characters_in_range.append(interactable)
			
			closest_interactable_to_player.interact_with_player(PLAYER, characters_in_range)



# Callback function that executes whenever the Player presses 'ESC' to escape an active menu/interface: Closes any open Interface
func _on_player_escape_menu() -> void:
	
	if InterfaceDialogue.active:
		_on_player_disable_dialogue_interface()
		PLAYER.is_interacting = false
	
	if InterfaceFoodBuddyFieldState.active:
		InterfaceFoodBuddyFieldState.disable(get_all_assets_on_screen())



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
	
	# Determine if the Dialogue Interface is active, then return because the FieldState Interface shouldn't be opened while the Dialogue Interface is active
	if InterfaceDialogue.active:
		return
	
	# Determine if the Field State interface is active/inactive, then disable/enable it
	if InterfaceFoodBuddyFieldState.active:
		InterfaceFoodBuddyFieldState.disable(get_all_assets_on_screen())
	else:
		InterfaceFoodBuddyFieldState.enable(get_all_assets_on_screen(), food_buddies_active)



# Callback function that executes whenever the Player wants to enable the Dialogue interface
func _on_player_enable_dialogue_interface(characters: Array[Node2D], conversation_name: String = "") -> void:
	
	# Determine if the Dialogue Interface is already active or if the Food Buddy FieldState Interface is active, then return because the Dialogue Interface doesn't need the 'enable' function called.
	if InterfaceDialogue.active or InterfaceFoodBuddyFieldState.active:
		return
	
	# Enable the Dialogue Interface
	InterfaceDialogue.enable(characters, PLAYER, get_all_assets_on_screen(), conversation_name)



# Callback function that executes whenever the Player wants to disable the Dialogue interface
func _on_player_disable_dialogue_interface():
	
	# Determine if the Dialogue Interface is active, then disable it
	if InterfaceDialogue.active:
		InterfaceDialogue.disable(get_all_assets_on_screen())



# Callback function that executes whenever the Player wants to use a solo ability: processes the solo attack against enemies
func _on_player_use_ability_solo(damage: int) -> void:
	
	# Iterate over every enemy currently on the screen to check if the Player's attack landed on them, then stop checking if the attack landed because the Player's solo ability can only damage one enemy at a time
	for enemy in get_enemies_on_screen():
		if process_attack(enemy, PLAYER, damage):
			return



# Callback function that executes whenever the Player has triggered the use of an ability while using a Food Buddy: executes the Food Buddy's ability
func _on_player_use_ability_buddy(buddy_number: int, ability_number: int) -> void:
	
	# Process the usage of the target Food Buddy's target ability
	process_food_ability_use(food_buddies_active[buddy_number - 1], ability_number)
	print(food_buddies_active[buddy_number - 1].name + " has used ability " + str(ability_number))


# Callback function that executes whenever the Player has triggered the use of an ability while using a Food Buddy Fusion: executes the Food Buddy Fusion's ability
func _on_player_use_ability_buddy_fusion(ability_number: int) -> void:
	process_food_ability_use(food_buddy_fusion_active, ability_number)



# Callback function that executes whenever the Player has killed their target: sets the Player's target to null
func _on_player_killed_target() -> void:
	# Increase XP for killing an enemy
	pass



# Callback function that executes whenever the Player dies: removes the Player from the SceneTree
func _on_player_die(player: Player) -> void:
	remove_child(player)
	print("Player has died!")






# CHARACTER CALLBACKS

# Callback function that executes whenever the Character wants to update their altitude: updates the Character's altitude
func _on_character_update_altitude(character) -> void:
	GameTileManager.get_character_altitude(character)



# Callback function that executes whenever the Character wants to set the Player as it's target: sets the Player as the target of the Character
func _on_character_target_player(character: CharacterBody2D) -> void:
	character.target = PLAYER



# Callback function that executes whenever the Character wants to move towards an enemy: moves the Character towards the given target
func _on_character_move_towards_target(character: CharacterBody2D, target: Node2D, desired_distance: float) -> void:
	character.target_distance = move_towards_target(character, target, desired_distance)



# Callback function that executes whenever the Character has killed their target: sets the Character's target to null
func _on_character_killed_target(character: CharacterBody2D) -> void:
	character.target = null
	character.target_distance = 0
	# Increase XP for killing a target



# Callback function that executes whenever the Character wants to set the closest Food Buddy as it's target: sets the closest Food Buddy as the target of the Character
func _on_character_target_closest_food_buddy(character: CharacterBody2D) -> void:
	
	# Store a local reference to the result of searching for the closest Food Buddy target
	var target_closest = select_closest_target(character, food_buddies_active)
	
	# Determine if the target exists, then set them as the Enemy's target and update the target distance
	if target_closest != null and target_closest.alive:
		character.target = target_closest
		character.target_distance = character.center_point.distance_to(target_closest.center_point)
	else:
		character.target = null
		character.target_distance = 0



# Callback function that executes whenever a Character dies: removes the Character from the SceneTree
func _on_character_die(character: CharacterBody2D) -> void:
	print(character.name + " has died!")
	remove_child(character)






# FOOD BUDDY CALLBACKS #

# Callback function that executes whenever the Food Buddy wants to use a solo ability: processes the solo attack against the Food Buddy's target enemy
func _on_food_buddy_use_ability_solo(food_buddy: FoodBuddy, damage: int) -> void:
	process_attack(food_buddy.target, food_buddy, damage)



# Callback function that executes whenever the Food Buddy wants to select the closest enemy as it's target: sets the closest enemy as the Food Buddy's target
func _on_food_buddy_target_closest_enemy(food_buddy: FoodBuddy) -> void:
	
	# Stores a local reference to the result of searching for the closest Enemy target
	var target_closest = select_closest_target(food_buddy, get_enemies_on_screen())
	
	# Determines if the target exists, then set them as the Food Buddy's target and update the target distance
	if target_closest != null and target_closest.alive:
		food_buddy.target = target_closest
		food_buddy.target_distance = food_buddy.center_point.distance_to(target_closest.center_point)
	else:
		food_buddy.target = null
		food_buddy.target_distance = 0



# Callback function that executes whenever the Food Buddy has killed their target: sets the Food Buddy's target to null
func _on_food_buddy_killed_target() -> void:
	# Increase XP for killing an enemy
	pass



# Callback function that executes whenever the Food Buddy dies: removes the Food Buddy from the SceneTree
func _on_food_buddy_die(food_buddy: FoodBuddy) -> void:
	
	# Determine which Food Buddy in the list of active Food Buddies just died, then remove it from the list since it is no longer active
	if food_buddy == food_buddies_active[0]:
		food_buddies_active.remove_at(0)
	else:
		food_buddies_active.remove_at(1)
	
	_on_character_die(food_buddy)






# ENEMY CALLBACKS #

# Callback function that executes whenever the Enemy wants to use an ability: processes the ability against the Enemy's target
func _on_enemy_use_ability(enemy: Enemy, damage: int) -> void:
	process_attack(enemy.target, enemy, damage)
