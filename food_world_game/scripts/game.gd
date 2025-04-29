extends Node2D


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

@onready var PLAYER: Player = $Player
@onready var ENEMY: Enemy = $Enemy

#@onready var MALICK: FoodBuddy = $Malick
#@onready var SALLY: FoodBuddy = $Sally
@onready var LINK: FoodBuddy = $Link
@onready var DAN: FoodBuddy = $Dan
@onready var BRITTANY: FoodBuddy = $Brittany


#@onready var FUSION_MALICK_SALLY: FoodBuddyFusion = load("res://scenes/fusions/malick-sally.tscn").instantiate()

@onready var MUSIC: AudioStreamPlayer = $WorldCenter

var food_citizen = load("res://scenes/blueprints/food-citizen.tscn").instantiate()

@onready var WorldCenterSong: AudioStreamPlayer = $WorldCenter
@onready var BatterBadlandsSong: AudioStreamPlayer = $BatterBadlands
@onready var GardenSong: AudioStreamPlayer = $GardenWorld

@onready var animation_player: AnimationPlayer = $AnimationPlayer

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

enum World { SWEETS, GARDEN, COLISEUM, MEAT, SEAFOOD, JUNKFOOD, PERISHABLE, SPUD }

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var test_cases_complete: bool = false

@onready var scene_tree = get_tree()

@onready var ocean_tilemap: TileMapLayer = $"World Map/Ocean/Water"

var map_zoomed_in: bool = true
var map_zooming: bool = false

var update_food_buddy_equipped: int = 0

var level_up_pending: bool = false

# Node Groups #
var enemies: Array[Node]
var food_citizens: Array[Node]
var interactables: Array[Node]
var interactable_assets: Dictionary
var bushes: Array[Vector2i]

var recently_foraged_bushes: Dictionary
var next_bush_index_to_add: int = 0
var next_bush_index_to_remove: int = 0
var bush_history_cap: int = 20

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
var InterfaceCharacterStatus: CharacterStatusInterface
var InterfaceLevelUp: LevelUpInterface
var InterfaceFoodBuddyFieldState: FoodBuddyFieldStateInterface
var InterfaceFoodBuddySelection: FoodBuddySelectInterface
var InterfaceGameOver: GameOverInterface
var InterfaceDialogue: DialogueInterface
var InterfaceBerryBot: BerryBotInterface

# Managers #
var GameTileManager: TileManager

var timer_fade: Timer
var timer_process_tiles: Timer
var timer_process_enemy_tiles: Timer
var timer_fade_music: Timer
var screen_fading: bool = false
var current_building: Building

var world_tilemaps: Dictionary

var musicStarted : bool = false
var next_song: AudioStreamPlayer
var empty_song: AudioStreamPlayer
var transitioning_songs: bool = false
var music_fade_in_duration: float = 3.5
var music_fade_out_duration: float = 2

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	timer_fade = $"Fade Timer"
	timer_process_tiles = $"Process Tiles Timer"
	timer_process_enemy_tiles = $"Process Enemy Tiles Timer"
	timer_fade_music = $"Fade Music Timer"
	
	# Add Malick and Sally into the active Food Buddies list
	food_buddies_active.append(DAN)
	food_buddies_active.append(BRITTANY)
	
	food_buddies_inactive.append(LINK)
	
	food_buddies_inactive[0].active = false
	
	empty_song = AudioStreamPlayer.new()

	#
	## Set Malick and Sally as the Food Buddies to fuse, and store the fusion in the list of inactive fusions
	#FUSION_MALICK_SALLY.set_food_buddies(MALICK, SALLY)
	#food_buddy_fusions_inactive.append(FUSION_MALICK_SALLY)
	
	
	world_tilemaps = {
		"center" : [$"World Map/World Center/Ground", $"World Map/World Center/Terrain", $"World Map/World Center/Environment", $"World Map/World Center/Building Interiors", $"World Map/World Center/Building Exteriors"],
		"sweets" : [$"World Map/Sweets World/Ground", $"World Map/Sweets World/Terrain", $"World Map/Sweets World/Environment", $"World Map/Sweets World/Building Interiors", $"World Map/Sweets World/Building Exteriors"],
		"garden" : [$"World Map/Garden World/Ground", $"World Map/Garden World/Terrain", $"World Map/Garden World/Environment", $"World Map/Garden World/Building Interiors", $"World Map/Garden World/Building Exteriors"],
	}
	
	# Create the instance of the Game's Tile Manager and pass it all of the tilemaps in the game
	GameTileManager = load("res://scripts/tile-manager.gd").new(world_tilemaps)
	add_child(GameTileManager.timer)
	
	# Connect the TileManager's signal that allows a Tile's associated object to be loaded into the game
	GameTileManager.tile_object_enter_game.connect(_on_tile_object_enter_game)
	GameTileManager.world_changed.connect(_on_character_changed_world)
	GameTileManager.set_to_player_world.connect(set_to_player_world)
	bushes = GameTileManager.get_bushes()

	#MALICK.current_tilemaps = world_tilemaps["center"]
	#SALLY.current_tilemaps = world_tilemaps["center"]
	LINK.current_tilemaps = world_tilemaps["center"]
	DAN.current_tilemaps = world_tilemaps["center"]
	BRITTANY.current_tilemaps = world_tilemaps["center"]
	PLAYER.current_tilemaps = world_tilemaps["center"]
	
	for enemy in scene_tree.get_nodes_in_group("enemies"):
		enemy.current_tilemaps = world_tilemaps["center"]
	
	# Connect all of the Food Citizen's signals to the Game
	#food_citizen.target_player.connect(_on_character_target_player)
	#food_citizen.target_closest_food_buddy.connect(_on_character_target_closest_food_buddy)
	#food_citizen.get_target_distance.connect(_on_character_get_target_distance)
	#food_citizen.die.connect(_on_character_die)
	
	## Add the Food Citizen to the Game's SceneTree
	#add_child(food_citizen)

	
	InterfaceCharacterStatus = $"Player/Character Status"
	InterfaceLevelUp = $"Player/Level-up"
	InterfaceFoodBuddyFieldState = $"Player/Food Buddy Field State"
	InterfaceFoodBuddySelection = $"Player/Food Buddy Select"
	InterfaceGameOver = $"Player/Game Over"
	InterfaceDialogue = $"Player/Dialogue Interface"
	InterfaceBerryBot = $"Player/Berry Bot Interface"
	
	InterfaceCharacterStatus.setValues(PLAYER, food_buddies_active)
	InterfaceLevelUp.setValues(PLAYER, food_buddies_active, InterfaceCharacterStatus)
	InterfaceLevelUp.adjust_tilemap_modulate.connect(adjust_tilemap_modulate)
	
	InterfaceFoodBuddyFieldState.setValues(PLAYER, food_buddies_active)
	InterfaceFoodBuddyFieldState.update_character_status_UI.connect(update_character_status_UI)
	InterfaceFoodBuddyFieldState.adjust_tilemap_modulate.connect(adjust_tilemap_modulate)
	
	InterfaceFoodBuddySelection.setValues(PLAYER, food_buddies_active, food_buddies_inactive, InterfaceCharacterStatus, InterfaceLevelUp, InterfaceFoodBuddyFieldState)
	InterfaceFoodBuddySelection.adjust_tilemap_modulate.connect(adjust_tilemap_modulate)
	InterfaceFoodBuddySelection.adjust_equipped_buddy.connect(_on_player_toggle_buddy_equipped)
	
	InterfaceGameOver.setValues(PLAYER, food_buddies_active, InterfaceCharacterStatus)
	InterfaceGameOver.adjust_tilemap_modulate.connect(adjust_tilemap_modulate)
	
	InterfaceDialogue.setValues(PLAYER)
	
	InterfaceBerryBot.setValues(PLAYER, BRITTANY)
	InterfaceBerryBot.update_character_status_UI.connect(update_character_status_UI)
	InterfaceBerryBot.adjust_tilemap_modulate.connect(adjust_tilemap_modulate)
	
	DAN.collision_values["GROUND"] = 4
	DAN.collision_values["MIDAIR"] = 5
	DAN.collision_values["PLATFORM"] = 6
	
	BRITTANY.collision_values["GROUND"] = 7
	BRITTANY.collision_values["MIDAIR"] = 8
	BRITTANY.collision_values["PLATFORM"] = 9
	
	## CREATE NEW DIALOGUE RESOURCE CODE
	#InterfaceDialogue.current_dialogue = load("res://resources/dialogue/dialogue.tres")
	#
	#var temp = ["Brittany-Link-Player", "Brittany-Player", "Dan-Link-Player", "Dan-Player", "Link-Player"]
	#
	#for character_name in temp:
		#InterfaceDialogue.current_dialogue.create_and_save_resource(character_name)
	
	
	timer_fade.start(0.1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if !musicStarted and timer_fade.is_stopped():
		musicStarted = true
		MUSIC.play()
	else:
		if transitioning_songs:
			process_music_fade(delta)
	
	if level_up_pending:
		if !PLAYER.equipping_buddy:
			InterfaceLevelUp.start(get_all_assets_in_game())
			level_up_pending = false
	
	
	if !map_zooming and Input.is_action_just_pressed("toggle_map"):
		if map_zoomed_in:
			zoom_out_map()
		else:
			zoom_in_map()
	
	
	if !PLAYER.paused and update_food_buddy_equipped != 0:
		_on_player_toggle_buddy_equipped(update_food_buddy_equipped)
	
		
	# Update the list of on-screen enemies, food citizens, and interactables
	enemies = scene_tree.get_nodes_in_group("enemies")
	food_citizens = scene_tree.get_nodes_in_group("food_citizens")
	interactables = scene_tree.get_nodes_in_group("interactables")
	
	
	for interactable_asset in scene_tree.get_nodes_in_group("interactable-assets"):
		interactable_assets.get_or_add(interactable_asset.global_position, interactable_asset)
	
	
	
	# Process the Tiles that are nearby the Player, Malick, and Sally on the ground, terrain, and environment tilemaps
	#if timer_process_tiles.is_stopped():
		#GameTileManager.process_nearby_tiles(PLAYER, 3)
		#GameTileManager.process_nearby_tiles(food_buddies_active[0], 5)
		#GameTileManager.process_nearby_tiles(food_buddies_active[1], 5)
		#timer_process_tiles.start(0.4)
	#
	#if timer_process_enemy_tiles.is_stopped():
		#for enemy in enemies:
			#if enemy.on_screen_notifier.is_on_screen():
				#enemy.process_mode = Node.PROCESS_MODE_INHERIT
				#GameTileManager.process_nearby_tiles(enemy, 3)
			#else:
				#enemy.process_mode = Node.PROCESS_MODE_DISABLED
		#
		#timer_process_enemy_tiles.start(0.9)
		

	
	
	# Determine if the Player is not already interacting, then process in-range potential interactions
	if not PLAYER.is_interacting:
		process_player_nearby_interactables(delta)
	
	
	if screen_fading:
		fade_screen(0, delta)
	
	# Determine if the Player is currently in a Building and if they are entering/exiting
	if current_building != null:
		
		if current_building.playerEntering:
			_on_player_enter_building(current_building, delta)
			
		elif current_building.playerExiting:
			_on_player_exit_building(current_building, delta)



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



func get_all_assets_in_game() -> Array[Node2D]:
	
	# Create a list that will store all Assets currently in the game and add the Player into it
	var assets_in_game: Array[Node2D] = [PLAYER]
	
	for enemy in enemies:
		assets_in_game.append(enemy)
	
	for citizen in food_citizens:
		assets_in_game.append(citizen)
	
	for interactable in interactables:
		assets_in_game.append(interactable)
	
	for projectile in scene_tree.get_nodes_in_group("projectiles"):
		assets_in_game.append(projectile)
	
	return assets_in_game



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
	var target_closest_distance = subject.global_position.distance_to(target_closest.global_position)
	
	
	# Iterate over all of the targets in the given list
	for target in targets:
		
		# Calculate and store the distance between the subject and the target of this iteration
		var target_distance: float = subject.global_position.distance_to(target.global_position)
		
		# Determine if the target's distance is closer than the closest target's distance, then set that target as the new closest target
		if target_distance < target_closest_distance:
			target_closest = target
			target_closest_distance = target_distance
	
	
	return target_closest



# Moves the subject towards a given target, stops it if it reaches the given distance, then returns the current distance between the two
func get_target_distance(subject: GameCharacter, target: Node2D) -> float:
	
	# Calculate the distance from the subject to the target
	var target_distance = subject.global_position.distance_to(target.global_position)
	
	# Return the distance from the subject to the target
	return target_distance


# Determines if an attack has landed on the target and reduces the target's health if it has. Returns true if the attack landed on the target, false if not.
func process_attack(target: GameCharacter, attacker: GameCharacter, damage: int, attacker_hitbox: Area2D = null) -> bool:
	
	var hitboxes: Array[Area2D]
	
	if attacker_hitbox != null:
		# Store a list of all hitboxes that the hitbox of the attack has overlapped with
		hitboxes = attacker_hitbox.get_overlapping_areas()
	else:
		# Store a list of all hitboxes that the hitbox of the attack has overlapped with
		hitboxes = attacker.current_damage_hitbox.get_overlapping_areas()
	
	
	# Determine if the target's hitbox is in the list of hitboxes that the attack's hitbox overlapped with, then reduce their health
	if target.hitbox_health in hitboxes:
		target.health_current -= damage
		target.target = attacker
		target.taking_damage = true
		
		if target is Enemy:
			target.field_state_current = Enemy.FieldState.AGGRESSIVE
		
		# Determine if the attacked Node has run out of health, then emit their death signal
		if target.health_current <= 0:
			target.health_current = 0
			target.die.emit(target)
			target.alive = false
			attacker.killed_target.emit(attacker)
			
			if attacker is FoodBuddy:
				attacker.using_ability = false
			
			if (attacker is Player or attacker is FoodBuddy) and (target is Enemy):
				PLAYER.xp_current += target.xp_drop
				
				if PLAYER.xp_current >= PLAYER.xp_max:
					if !PLAYER.equipping_buddy:
						InterfaceLevelUp.start(get_all_assets_in_game())
					else:
						level_up_pending = true
			
		InterfaceCharacterStatus.setValues(PLAYER, food_buddies_active)
		return true
	
	InterfaceCharacterStatus.setValues(PLAYER, food_buddies_active)
	return false



# Checks if the Player's Hitbox has overlapped with any other Interactable Asset's Interaction Hitboxes (meaning they are in range of the Player) and enables/disables a label above the Interactable that says to 'Press 'E' To Interact'
func process_player_nearby_interactables(delta):
	
	# Determine if there are no interactables to process, then return the function because there aren't any Interactables to process
	if interactables.size() == 0:
		return
	
	# Store a list of all hitboxes that are overlapping with the Player's Hitbox
	var overlapping_hitboxes = PLAYER.hitbox_interaction.get_overlapping_areas()
	
	if closest_interactable_to_player is FoodBuddy and closest_interactable_to_player.field_state_current == closest_interactable_to_player.FieldState.PLAYER:
		print(closest_interactable_to_player.name)
		closest_interactable_to_player = null
	
	# Determine if the closest Interactable to the Player hasn't been stored yet, then store the current in-range Interactable as the closest (temporarily)
	if closest_interactable_to_player == null:
		var count: int = 0
		
		while closest_interactable_to_player == null:
			
			if interactables[count].active and not (interactables[count] is FoodBuddy and interactables[count].field_state_current == interactables[count].FieldState.PLAYER):
				closest_interactable_to_player = interactables[count]
				break
			
			count += 1
	
	
	if PLAYER.level_up or PLAYER.is_interacting:
		closest_interactable_to_player.label_e_to_interact.hide()
		return
	
	
	# Iterate over every Asset on-screen that can be Interacted with
	for interactable in get_interactables_on_screen():
		
		if not (interactable is FoodBuddy and interactable.field_state_current == interactable.FieldState.PLAYER):
			
			# Determine if the Interactable's Interaction hitbox is included in the list of hitboxes that are overlapping with the Player's hitbox, then set the Interactable to be classified as in or out of range of the Player
			if interactable.hitbox_interaction in overlapping_hitboxes:
				interactable.in_range = true
			else:
				interactable.in_range = false
			
			# Determine if the Interactable of this iteration is closer to the Player than the latest closest Interactable is, then set this Interactable as the new current closest
			if interactable.global_position.distance_to(PLAYER.global_position) < closest_interactable_to_player.global_position.distance_to(PLAYER.global_position):
				if closest_interactable_to_player.name == "Brittany":
					closest_interactable_to_player.text_press_f_for_berry_bot.hide()
				
				closest_interactable_to_player.label_e_to_interact.hide()
				closest_interactable_to_player = interactable
	
	# Determine whether or not the closest Interactable to the Player is in range of the Player's hitbox, then show/hide their interaction prompt
	if closest_interactable_to_player.in_range:
		
		# If the interactable closest to the Player is a Bush and has no berries or the Player is full on berries, don't consider it for interaction
		if "Bush" in closest_interactable_to_player.name and (closest_interactable_to_player.berries == 0 or PLAYER.berries == PLAYER.berries_max):
			return
		
		closest_interactable_to_player.label_e_to_interact.show()
		
		if closest_interactable_to_player.name == "Brittany":
			closest_interactable_to_player.text_press_f_for_berry_bot.show()
	
	else:
		closest_interactable_to_player.label_e_to_interact.hide()
		
		if closest_interactable_to_player.name == "Brittany":
			closest_interactable_to_player.text_press_f_for_berry_bot.hide()
		
	
	if closest_interactable_to_player is FoodBuddy and closest_interactable_to_player.field_state_current == closest_interactable_to_player.FieldState.PLAYER:
		closest_interactable_to_player.label_e_to_interact.hide()
		
		if closest_interactable_to_player.name == "Brittany":
			closest_interactable_to_player.text_press_f_for_berry_bot.hide()
	
	if closest_interactable_to_player is FoodBuddy and !closest_interactable_to_player.alive:
		
		if closest_interactable_to_player.revive_time_remaining < closest_interactable_to_player.revive_time_total:
			closest_interactable_to_player.revive_time_remaining += delta
			closest_interactable_to_player.label_e_to_interact.text = str(round(float(closest_interactable_to_player.revive_time_remaining) * 10) / 10.0)
		else:
			closest_interactable_to_player.revive_time_remaining = closest_interactable_to_player.revive_time_total
			closest_interactable_to_player.label_e_to_interact.text = "Hold 'E' To Revive"
	
# Processes the use of a Food Buddy or Food Buddy Fusion's ability
func process_food_ability_use(food_entity, ability_number: int, delta: float):
	
	# Determine if Ability 1 is being used, then process and launch it
	if ability_number == 1:
		
		food_entity.use_ability1(PLAYER, delta)
	
	# Otherwise, determine if Ability 2 is being used, then process and launch it
	elif ability_number >= 2:
		
		food_entity.use_ability2(PLAYER, delta)
	
	## Otherwise, a special attack is being used, so process and launch it
	#else:
		#food_buddy_fusion_active.use_special_attack()



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
func _on_player_interact(delta: float) -> void:
	
	if PLAYER.interaction_delay_timer.time_left != 0:
		PLAYER.is_interacting = false
		return
	
	var interactables_on_screen = get_interactables_on_screen()
	
	# Determine if the closest Interactable to the Player is in range for an interaction, then trigger the interaction
	if closest_interactable_to_player.in_range:
		
		
		# Determine if Brittany is the closest interactable, then ensure her berry bot prompt is disabled too.
		if closest_interactable_to_player == BRITTANY:
			closest_interactable_to_player.text_press_f_for_berry_bot.hide()
		
		# Set the Player to be interacting and remove the label above the Interactable
		PLAYER.is_interacting = true
		closest_interactable_to_player.label_e_to_interact.hide()
		
		# Determine if the closest Interactable is an Interactable Character
		if closest_interactable_to_player is FoodCitizen or closest_interactable_to_player is FoodBuddy:
			
			# Create a variable to store all of the in-range Interactable Characters after they're filtered out of from the non-Character Interactables
			var characters_in_range: Array[Node2D] = []
			
			if closest_interactable_to_player is FoodBuddy and closest_interactable_to_player.alive == false:
				closest_interactable_to_player.revive_time_remaining -= delta * 2
				closest_interactable_to_player.label_e_to_interact.text = str(round(float(closest_interactable_to_player.revive_time_remaining) * 10) / 10.0)
				
				if closest_interactable_to_player.revive_time_remaining <= 0:
					closest_interactable_to_player.revive_time_remaining = 10
					closest_interactable_to_player.alive = true
					closest_interactable_to_player.active = true
					closest_interactable_to_player.health_current = int(closest_interactable_to_player.health_max * 0.25)
					closest_interactable_to_player.sprite.play("idle_front")
					closest_interactable_to_player.label_e_to_interact.text = "press 'e' to interact"
					InterfaceCharacterStatus.setValues(PLAYER, food_buddies_active)
					PLAYER.interaction_delay_timer.start(1)
				
				PLAYER.is_interacting = false
				closest_interactable_to_player.label_e_to_interact.show()
				return
			
			# Iterate over each on-screen Interactable and add the Interactable Characters that are in range of the Player to the previously created list
			for interactable in interactables_on_screen:
				if interactable.in_range and (interactable is FoodBuddy or interactable is FoodCitizen):
					characters_in_range.append(interactable)
			
			# Trigger the interaction in the closest Interactable Character, then save the list of Characters that should be included in the Dialogue
			_on_player_enable_dialogue_interface(closest_interactable_to_player.interact_with_player(PLAYER, characters_in_range, delta))
		
		# Otherwise, determine if the closest Interactable is a Bush or Building, then trigger the interaction with them
		elif closest_interactable_to_player is Bush or Building:
			if "Bush" in closest_interactable_to_player.name:
				if closest_interactable_to_player.berries != 0 and PLAYER.berries != PLAYER.berries_max:
					closest_interactable_to_player.interact_with_player(PLAYER, delta)
					update_character_status_UI()
					
				PLAYER.is_interacting = false
			else:
				closest_interactable_to_player.interact_with_player(PLAYER, delta)
				PLAYER.is_interacting = true
			




# Callback function that executes whenever the Player presses 'ESC' to escape an active menu/interface: Closes any open Interface
func _on_player_escape_menu() -> void:
	pass



# Callback function that executes whenever the Player equips or unequips a Food Buddy: finds the buddy that corresponds to the given buddy number and sets its FieldState to PLAYER if being equipped or to the appropriate FieldState if being unequipped
func _on_player_toggle_buddy_equipped(buddy_number: int, instant_equip: bool = false) -> void:
	
	PLAYER.equipping_buddy = true
	
	# Create variables for the two Food Buddies that will be considered in this Food Buddy equip/unequip
	var food_buddy_selected: FoodBuddy
	var food_buddy_other: FoodBuddy
	
	# Determine which Food Buddy was selected by the Player based on the emitted buddy_number and which Food Buddy wasn't, then store a local reference to each of them so we don't have to access the Food Buddies list multiple times
	if !instant_equip and update_food_buddy_equipped == 0 and buddy_number >= 2:
		food_buddy_selected = food_buddies_active[1]
		update_food_buddy_equipped = 2
		
		if PLAYER.field_state_current != PLAYER.FieldState.BUDDY2:
			
			if food_buddy_selected.alive and PLAYER.global_position.distance_to(food_buddy_selected.global_position) > 48:
				update_food_buddy_equipped = 0
				PLAYER.equipping_buddy = false
				return
		
		PLAYER.field_state_current = PLAYER.FieldState.BUDDY2
		
		print("Player's FieldState has been updated to BUDDY2")
		
		PLAYER.fuse_sprite.play("fuse")
		PLAYER.animation_player.play("fuse")
		PLAYER.animation_player.queue("RESET")
		return
		
	elif !instant_equip and update_food_buddy_equipped == 0 and buddy_number <= 1:
		
		food_buddy_selected = food_buddies_active[0]
		update_food_buddy_equipped = 1
		
		if PLAYER.field_state_current != PLAYER.FieldState.BUDDY1:
			
			if food_buddy_selected.alive and PLAYER.global_position.distance_to(food_buddy_selected.global_position) > 48:
				update_food_buddy_equipped = 0
				PLAYER.equipping_buddy = false
				return
		
		PLAYER.field_state_current = PLAYER.FieldState.BUDDY1
		
		print("Player's FieldState has been updated to BUDDY1")
		
		PLAYER.fuse_sprite.play("fuse")
		PLAYER.animation_player.play("fuse")
		PLAYER.animation_player.queue("RESET")
		return
	
	else:
		if PLAYER.animation_player.current_animation == "fuse" and PLAYER.animation_player.current_animation_position < 0.3:
			return
		
		if instant_equip:
			update_food_buddy_equipped = buddy_number
			PLAYER.equipping_buddy = false
		
		if update_food_buddy_equipped == 1:
			food_buddy_selected = food_buddies_active[0]
			food_buddy_other = food_buddies_active[1]
		else:
			food_buddy_selected = food_buddies_active[1]
			food_buddy_other = food_buddies_active[0]
		
		update_food_buddy_equipped = 0
	
	# Determine if the Player already had the Food Buddy equipped, then revert the Food Buddy back to its previous FieldState since the Player is trying to unequip it
	if food_buddy_selected.field_state_current == FoodBuddy.FieldState.PLAYER:
		if food_buddy_selected.field_state_previous == FoodBuddy.FieldState.PLAYER:
			food_buddy_selected.field_state_current = FoodBuddy.FieldState.FOLLOW
		else:
			food_buddy_selected.field_state_current = food_buddy_selected.field_state_previous
			food_buddy_selected.field_state_previous = FoodBuddy.FieldState.PLAYER
		
		food_buddy_selected.process_mode = Node.PROCESS_MODE_INHERIT
		food_buddy_selected.global_position = Vector2(PLAYER.global_position.x, PLAYER.global_position.y - 1)
		food_buddy_selected.visible = true
		food_buddy_selected.active = true
		food_buddy_selected.process_nearby_tiles = true
		food_buddy_selected.timer_process_tiles.start(food_buddy_selected.time_between_tile_updates)
		
		if food_buddy_selected.name == "Dan":
			food_buddy_selected.label_e_to_interact.visible = true
			PLAYER.shadow.visible = false
			PLAYER.sprite.offset.y = -16
			PLAYER.speed_current = PLAYER.speed_normal
			PLAYER.time_between_tile_updates = randf_range(0.65, 0.7)
		
		elif food_buddy_selected.name == "Link":
			PLAYER.current_damage_hitbox.process_mode = Node.PROCESS_MODE_DISABLED
			PLAYER.current_damage_hitbox = PLAYER.hitbox_damage
			PLAYER.current_damage_hitbox.process_mode = Node.PROCESS_MODE_INHERIT
			
		PLAYER.field_state_current = PLAYER.FieldState.SOLO
		PLAYER.equipped_buddy = null
		PLAYER.shadow.visible = true
	
	else:
		
		# Determine if the Food Buddy that wasn't selected is currently the Player's active Food Buddy or if a Food Buddy Fusion is currently active
		if food_buddy_other.field_state_current == FoodBuddy.FieldState.PLAYER or food_buddy_other.field_state_current == FoodBuddy.FieldState.FUSION:
			
			## Determine if a FoodBuddyFusion is equipped, then unequip it and revert the two Food Buddies back to the FOLLOW FieldState
			#if food_buddy_fusion_active != null:
				#unequip_food_buddy_fusion()
			#else:
			# Revert the unselected Food Buddy to their previous FieldState because the selected Food Buddy is swapping places with it (only one Food Buddy in PLAYER FieldState at a time)
			if food_buddy_other.field_state_previous == FoodBuddy.FieldState.PLAYER:
				food_buddy_other.field_state_current = FoodBuddy.FieldState.FOLLOW
			else:
				food_buddy_other.field_state_current = food_buddy_other.field_state_previous
				food_buddy_other.field_state_previous = FoodBuddy.FieldState.PLAYER
			
			food_buddy_other.process_mode = Node.PROCESS_MODE_INHERIT
			food_buddy_other.global_position = Vector2(PLAYER.global_position.x, PLAYER.global_position.y - 1)
			food_buddy_other.visible = true
			food_buddy_other.active = true
			
			if food_buddy_other.name == "Dan":
				food_buddy_other.label_e_to_interact.visible = true
				PLAYER.shadow.visible = false
				PLAYER.sprite.offset.y = -16
				PLAYER.speed_current = PLAYER.speed_normal
				PLAYER.time_between_tile_updates = randf_range(0.65, 0.7)
				PLAYER.juicebox_ready = false
			
			elif food_buddy_selected.name == "Link":
				PLAYER.current_damage_hitbox.process_mode = Node.PROCESS_MODE_DISABLED
				PLAYER.current_damage_hitbox = PLAYER.hitbox_damage
				PLAYER.current_damage_hitbox.process_mode = Node.PROCESS_MODE_INHERIT
				
			
			food_buddy_other.process_nearby_tiles = true
		
		# Update the selected Food Buddy's FieldState variables
		food_buddy_selected.field_state_previous = food_buddy_selected.field_state_current
		food_buddy_selected.closest_bush = Vector2i(-1, -1)
		food_buddy_selected.field_state_current = FoodBuddy.FieldState.PLAYER
		food_buddy_selected.active = false
		food_buddy_selected.process_nearby_tiles = false
		
		if food_buddy_selected.name != "Dan":
			food_buddy_selected.visible = false
			food_buddy_selected.process_mode = Node.PROCESS_MODE_DISABLED
		else:
			food_buddy_selected.label_e_to_interact.visible = false
			PLAYER.shadow.visible = false
			PLAYER.sprite.offset.y = -39
			PLAYER.speed_current = PLAYER.speed_normal_dan
			PLAYER.time_between_tile_updates = randf_range(0.35, 0.4)
		
		if food_buddy_selected.name == "Link":
			PLAYER.current_damage_hitbox.process_mode = Node.PROCESS_MODE_DISABLED
			PLAYER.current_damage_hitbox = PLAYER.hitbox_damage_sausage_whip
			PLAYER.current_damage_hitbox.process_mode = Node.PROCESS_MODE_INHERIT

		
		PLAYER.equipped_buddy = food_buddy_selected
		
		if PLAYER.equipped_buddy == closest_interactable_to_player:
			closest_interactable_to_player = null
	
	PLAYER.is_interacting = false
	PLAYER.update_animation()
	PLAYER.is_interacting = true
	
	InterfaceCharacterStatus.setValues(PLAYER, food_buddies_active)



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
	if InterfaceDialogue.visible or InterfaceLevelUp.visible or InterfaceFoodBuddySelection.visible or InterfaceGameOver.visible or InterfaceBerryBot.visible:
		return
	
	# Determine if the Field State interface is active/inactive, then disable/enable it
	if InterfaceFoodBuddyFieldState.visible:
		InterfaceFoodBuddyFieldState.end()
	else:
		InterfaceFoodBuddyFieldState.setValues(PLAYER, food_buddies_active)
		InterfaceFoodBuddyFieldState.start(get_all_assets_in_game(), food_buddies_active)



# Callback function that executes whenever the Player wants to trigger the Food Buddy FieldState updating interface: opens/closes the interface depending on the interface's current state
func _on_player_toggle_select_interface() -> void:
	
	# Determine if the Dialogue Interface is active, then return because the FieldState Interface shouldn't be opened while the Dialogue Interface is active
	if InterfaceDialogue.visible or InterfaceLevelUp.visible or InterfaceGameOver.visible or InterfaceFoodBuddyFieldState.visible or InterfaceBerryBot.visible:
		return
	
	# Determine if the Field State interface is active/inactive, then disable/enable it
	if InterfaceFoodBuddySelection.visible:
		InterfaceFoodBuddySelection.end()
	else:
		InterfaceFoodBuddySelection.setValues(PLAYER, food_buddies_active, food_buddies_inactive, InterfaceCharacterStatus, InterfaceLevelUp, InterfaceFoodBuddyFieldState)
		InterfaceFoodBuddySelection.start(get_all_assets_in_game())


# Callback function that executes whenever the Player wants to enable the Dialogue interface
func _on_player_enable_dialogue_interface(characters: Array[Node2D], conversation_name: String = "") -> void:
	
	# Determine if the Dialogue Interface is already active or if any other Interfaces are active, then return because the Dialogue Interface doesn't need the 'enable' function called.
	if InterfaceDialogue.visible or InterfaceFoodBuddyFieldState.visible or InterfaceLevelUp.visible or InterfaceFoodBuddySelection.visible or InterfaceGameOver.visible or InterfaceBerryBot.visible:
		return
	
	# Enable the Dialogue Interface
	InterfaceDialogue.start(characters, get_all_assets_in_game(), conversation_name)


func _on_player_toggle_berry_bot_interface():
	
	# Determine if the Dialogue Interface is already active or if any other Interfaces are active, then return because the Dialogue Interface doesn't need the 'enable' function called.
	if InterfaceDialogue.visible or InterfaceFoodBuddyFieldState.visible or InterfaceLevelUp.visible or InterfaceFoodBuddySelection.visible or InterfaceGameOver.visible:
		return
	
	
	if InterfaceBerryBot.visible:
		InterfaceBerryBot.end()
		return
	
	if BRITTANY.field_state_current == BRITTANY.FieldState.PLAYER:
		InterfaceBerryBot.start(get_all_assets_in_game())
		return
	
	if closest_interactable_to_player == BRITTANY and closest_interactable_to_player.in_range:
		# Set the Player to be interacting and remove the label above the Interactable
		PLAYER.is_interacting = true
		closest_interactable_to_player.label_e_to_interact.hide()
		closest_interactable_to_player.text_press_f_for_berry_bot.hide()
		
		InterfaceBerryBot.start(get_all_assets_in_game())



# Callback function that executes whenever the Player wants to use a solo ability: processes the solo attack against enemies
func _on_player_use_ability_solo(damage: int) -> void:
	
	if damage > 0:
		
		# Stores a local reference to the result of searching for the closest Enemy target
		var target_closest = select_closest_target(PLAYER, get_enemies_on_screen())
		
		# Determines if the target exists, then set them as the Food Buddy's target and update the target distance
		if target_closest != null and target_closest.alive:
			PLAYER.target = target_closest
			PLAYER.target_distance = PLAYER.global_position.distance_to(target_closest.global_position)
			process_attack(PLAYER.target, PLAYER, damage)
		
		else:
			PLAYER.target = null
			PLAYER.target_distance = 0


# Callback function that executes whenever the Player has triggered the use of an ability while using a Food Buddy: executes the Food Buddy's ability
func _on_player_use_ability_buddy(buddy_number: int, ability_number: int, delta: float) -> void:
	
	# Process the usage of the target Food Buddy's target ability
	process_food_ability_use(food_buddies_active[buddy_number - 1], ability_number, delta)
	print(food_buddies_active[buddy_number - 1].name + " has used ability " + str(ability_number))



# Callback function that executes whenever the Player has triggered the use of an ability while using a Food Buddy Fusion: executes the Food Buddy Fusion's ability
func _on_player_use_ability_buddy_fusion(ability_number: int, delta) -> void:
	process_food_ability_use(food_buddy_fusion_active, ability_number, delta)



# Callback function that executes whenever the Player has killed their target: sets the Player's target to null
func _on_player_killed_target() -> void:
	# Increase XP for killing an enemy
	pass



# Callback function that executes whenever the Player dies: removes the Player from the SceneTree
func _on_player_die(_player: Player) -> void:
	InterfaceGameOver.game_over(get_all_assets_in_game())
	transition_music("end")
	PLAYER.sprite.play("die")
	print("Player has died!")
	
	InterfaceCharacterStatus.visible = false
	InterfaceDialogue.visible = false
	InterfaceFoodBuddyFieldState.visible = false
	InterfaceFoodBuddySelection.visible = false
	InterfaceLevelUp.visible = false

	InterfaceCharacterStatus.process_mode = Node.PROCESS_MODE_DISABLED
	InterfaceDialogue.process_mode = Node.PROCESS_MODE_DISABLED
	InterfaceFoodBuddyFieldState.process_mode = Node.PROCESS_MODE_DISABLED
	InterfaceFoodBuddySelection.process_mode = Node.PROCESS_MODE_DISABLED
	InterfaceLevelUp.process_mode = Node.PROCESS_MODE_DISABLED


# CHARACTER CALLBACKS

# Callback function that executes whenever the Character wants to update their altitude: updates the Character's altitude
func _on_character_update_altitude(character) -> void:
	GameTileManager.get_character_altitude(character)



# Callback function that executes whenever the Character wants to set the Player as it's target: sets the Player as the target of the Character
func _on_character_target_player(character: CharacterBody2D) -> void:
	character.target = PLAYER



# Callback function that executes whenever the Character wants to move towards an enemy: moves the Character towards the given target
func _on_character_get_target_distance(character: CharacterBody2D, target: Node2D) -> void:
	character.target_distance = get_target_distance(character, target)



# Callback function that executes whenever the Character has killed their target: sets the Character's target to null
func _on_character_killed_target(character: CharacterBody2D) -> void:
	character.target = PLAYER
	character.target_distance = 0



# Callback function that executes whenever the Character wants to set the closest Food Buddy as it's target: sets the closest Food Buddy as the target of the Character
func _on_character_target_closest_food_buddy(character: CharacterBody2D) -> void:
	
	# Store a local reference to the result of searching for the closest Food Buddy target
	var target_closest = select_closest_target(character, food_buddies_active)
	
	# Determine if the target exists, then set them as the Enemy's target and update the target distance
	if target_closest != null and target_closest.alive:
		character.target = target_closest
		character.target_distance = character.global_position.distance_to(target_closest.global_position)
	else:
		character.target = null
		character.target_distance = 0



# Callback function that executes whenever a Character dies: removes the Character from the SceneTree
func _on_character_die(character: CharacterBody2D) -> void:
	print(character.name + " has died!")
	remove_child(character)






# FOOD BUDDY CALLBACKS #

# Callback function that executes whenever the Food Buddy wants to use a solo ability: processes the solo attack against the Food Buddy's target enemy
func _on_food_buddy_use_ability_solo(food_buddy: FoodBuddy, damage: int, _attack_hitbox: Area2D = null) -> void:
	process_attack(food_buddy.target, food_buddy, damage)



# Callback function that executes whenever the Food Buddy wants to select the closest enemy as it's target: sets the closest enemy as the Food Buddy's target
func _on_food_buddy_target_closest_enemy(food_buddy: FoodBuddy) -> void:
	
	# Stores a local reference to the result of searching for the closest Enemy target
	var target_closest = select_closest_target(food_buddy, get_enemies_on_screen())
	
	# Determines if the target exists, then set them as the Food Buddy's target and update the target distance
	if target_closest != null and target_closest.alive:
		food_buddy.target = target_closest
		food_buddy.target_distance = food_buddy.global_position.distance_to(target_closest.global_position)
	else:
		food_buddy.target = null
		food_buddy.target_distance = 0


func _on_food_buddy_find_nearest_bush(foodbuddy: FoodBuddy, _next_nearest: int = 0) -> void:
	
	var bush_distances: Array[float]
	var bush_distance_maps: Dictionary
	
	var other_foodbuddy: FoodBuddy
	
	for foodbuddy_active in range(0, food_buddies_active.size()):
		if foodbuddy != food_buddies_active[foodbuddy_active]:
			other_foodbuddy = food_buddies_active[foodbuddy_active]
			break
	
	# ACCESS BUSHES LIST THAT WE CREATED
	for index in range(0, bushes.size()):
		var distance = PLAYER.global_position.distance_squared_to(bushes[index])
		bush_distances.append(distance)
		bush_distance_maps.get_or_add(distance, index)
	
	bush_distances.sort()
	
	for distance in bush_distances:
		if recently_foraged_bushes.find_key(bushes[bush_distance_maps[distance]]) == null and bushes[bush_distance_maps[distance]] != other_foodbuddy.closest_bush:
			foodbuddy.closest_bush = bushes[bush_distance_maps[distance]]
			return
	
	foodbuddy.closest_bush = Vector2(-1, -1)


func _on_food_buddy_deposit_berries(food_buddy: FoodBuddy):
	while (food_buddy.berries > 0 and InterfaceBerryBot.sauna_occupancy_current < InterfaceBerryBot.sauna_occupancy_max):
		
		if !InterfaceBerryBot._on_deposit_button_down(food_buddy):
			break
			

func _on_food_buddy_forage_bush(food_buddy: FoodBuddy):
	
	var bush: Bush = interactable_assets.get(Vector2(food_buddy.closest_bush))
	
	if bush != null:
		
		while (bush.berries > 0 and food_buddy.berries < food_buddy.berries_max):
			bush.berries -= 1
			food_buddy.berries += 1
		
		print(bush.berries)

func _on_food_buddy_target_brittany(food_buddy: FoodBuddy):
	food_buddy.target = BRITTANY

func _on_food_buddy_update_recently_foraged_bushes(closest_bush_coords: Vector2i):
	recently_foraged_bushes.get_or_add(next_bush_index_to_add, closest_bush_coords)
	
	next_bush_index_to_add += 1
	
	if next_bush_index_to_add % bush_history_cap == 0:
		next_bush_index_to_add = 0
	
	if recently_foraged_bushes.size() == bush_history_cap:
		
		# Erase the cell from the dictionary so it is ready to be overwritten
		recently_foraged_bushes.erase(next_bush_index_to_remove)
		
		# Increment the cell and see if we need to loop around to start removing older cells at the beginning
		next_bush_index_to_remove += 1
		
		if next_bush_index_to_remove % bush_history_cap == 0:
			next_bush_index_to_remove = 0

# Callback function that executes whenever the Food Buddy dies: removes the Food Buddy from the SceneTree
func _on_food_buddy_die(food_buddy: FoodBuddy) -> void:
	
	food_buddy.sprite.play("die_front")
	food_buddy.alive = false
	food_buddy.active = false
	food_buddy.label_e_to_interact.text = "Hold 'E' To Revive"
	
	## Determine which Food Buddy in the list of active Food Buddies just died, then remove it from the list since it is no longer active
	#if food_buddy == food_buddies_active[0]:
		#food_buddies_active[0] = food_buddies_inactive[0]
	#else:
		#food_buddies_active[1] = food_buddies_inactive[0]






# ENEMY CALLBACKS #

# Callback function that executes whenever the Enemy wants to use an ability: processes the ability against the Enemy's target
func _on_enemy_use_ability(enemy: Enemy, damage: int) -> void:
	process_attack(enemy.target, enemy, damage)


func _on_enemy_killed_target(enemy: Enemy) -> void:
	
	# Determine if the enemy's target was the first food buddy
	if enemy.target == food_buddies_active[0]:
		
		if PLAYER.alive:
			
			if food_buddies_active[1].alive:
		
				# Determine if the enemy is closer to the other food buddy
				if enemy.global_position.distance_to(PLAYER.global_position) <= enemy.global_position.distance_to(food_buddies_active[1].global_position):
					enemy.target = PLAYER
				else:
					enemy.target = food_buddies_active[1]
		
		elif food_buddies_active[1].alive:
			enemy.target = food_buddies_active[1]
	
	# Otherwise, determine if the enemy's target was the second food buddy
	elif enemy.target == food_buddies_active[1]:
		
		if PLAYER.alive and food_buddies_active[0].alive:
		
			# Determine if the enemy is closer to the other food buddy
			if enemy.global_position.distance_to(PLAYER.global_position) <= enemy.global_position.distance_to(food_buddies_active[0].global_position):
				enemy.target = PLAYER
			else:
				enemy.target = food_buddies_active[0]
		
		elif food_buddies_active[0].alive:
			enemy.target = food_buddies_active[0]



# TILEMANAGER CALLBACKS #

# Callback function that executes whenever the TileManager is attempting to load a Tile's Object form into the game: adds the Tile Object into the game's scene tree
func _on_tile_object_enter_game(tile: Tile):
	
	var tile_object_location: Vector2
	
	if "building" == tile.type:
		tile_object_location = tile.data.get_custom_data("global_position")
		if tile_object_location == Vector2(0, 0):
			
			tile_object_location = tile.coords_local
	else:
		tile_object_location = tile.coords_local
	
	# Determine if a Tile Object already exists at the location that this Tile Object is trying to be created at
	if interactable_assets.get(tile_object_location) == null:
		
		# Load and store the Tile Object
		var tile_object: Node2D = load("res://scenes/blueprints/" + tile.type + ".tscn").instantiate()
		
		# Determine if the Tile Object is a building
		if "building" in tile.type:
			
			# Connect the Tile Object's signals to the game
			tile_object.player_enter.connect(_on_player_enter_building)
			tile_object.player_exit.connect(_on_player_enter_building)
			tile_object.connect_occupant_to_game.connect(connect_character_to_game)
			tile_object.player_offset = tile.data.get_custom_data("player_offset")
			tile_object.foodbuddy1_offset = tile.data.get_custom_data("foodbuddy1_offset")
			tile_object.foodbuddy2_offset = tile.data.get_custom_data("foodbuddy2_offset")
			
			# Iterate over each file path for the occupants of the building and store them in the buildings list
			for occupant_path in tile.data.get_custom_data("occupant_paths"):
				tile_object.usual_occupants.append(occupant_path)
		
		elif "bush" in tile.type:
			tile_object.berries_max = PLAYER.level_current + 4
		
		tile_object.global_position = tile_object_location
		
		#print("Added new Tile Object!")
		
		# Add the Tile Object into the Game and list of Interactable Assets
		add_child(tile_object)
		interactable_assets.get_or_add(tile_object_location, tile_object)
		
		tile_object = null



# BUILDING CALLBACKS #

# Fades the screen to black for the given "fade out" parameter, then back to the game for the given "fade in" parameter
func fade_screen(final_opacity: float, delta: float):
	
	# Determine if the timer_fade is stopped and that the opacity isn't all the way down yet, then decrement the opacity further
	if timer_fade.is_stopped() and modulate.a > final_opacity:
		modulate.a = modulate.a - 0.7 * delta
		
		# Ensure the opacity doesn't go out of bounds, then start a 0.5 second delay until the fade back in occurs
		if modulate.a <= final_opacity:
			modulate.a = final_opacity
			timer_fade.start(0.5)
	
	# Otherwise, the opacity is all the way down, so...
	elif modulate.a == final_opacity:
		
		# Determine if the timer_fade is stopped (meaning it is time to fade back in)
		if timer_fade.is_stopped():
			
			var interior: TileMapLayer = PLAYER.current_tilemaps[Tile.MapType.BUILDINGS_INTERIOR]
			var exterior: TileMapLayer = PLAYER.current_tilemaps[Tile.MapType.BUILDINGS_EXTERIOR]
			
			# Determine if the interiors of the buildings are currently not visible (meaning the player is entering from outside)
			if !interior.visible:
				
				# Enable the interiors' visibility and collisions
				interior.visible = true
				interior.collision_enabled = true
				
				# Disable the exterior's visibility and collisions
				exterior.visible = false
				exterior.collision_enabled = false
				
				# Iterate over each Tilemap aside from the building-related Tilemaps
				for tilemap in range(final_opacity, PLAYER.current_tilemaps.size() - 2):
					
					# Disable the visibility and collisions of the outdoor tilemaps now that the player is going inside
					PLAYER.current_tilemaps[tilemap].visible = false
					PLAYER.current_tilemaps[tilemap].collision_enabled = false
				
				ocean_tilemap.visible = false
			
			# Otherwise, the exteriors of the building are not currently visible (meaning the player is exiting from outside) 
			else:
				
				# Enable the exteriors' visibility and collisions
				exterior.visible = true
				exterior.collision_enabled = true
				
				# Disable the interiors' visibility and collisions
				interior.visible = false
				interior.collision_enabled = false
				
				# Iterate over each Tilemap aside from the building-related Tilemaps
				for tilemap in range(0, PLAYER.current_tilemaps.size() - 2):
					
					# Enable the visibility and collisions of the outdoor tilemaps now that the player is going back outside
					PLAYER.current_tilemaps[tilemap].visible = true
					PLAYER.current_tilemaps[tilemap].collision_enabled = true
				
				ocean_tilemap.visible = true
			# Start the timer_fade for 100 seconds so this code doesn't break by thinking the timer_fade is stopped when it shouldnt be affecting it anymore
			timer_fade.start(100)
			
			# Begin incrementing the opacity
			modulate.a = modulate.a + 0.7 * delta
	
	else:
		modulate.a = modulate.a + 0.7 * delta
		
		if modulate.a >= 1:
			modulate.a = 1
			screen_fading = false
			timer_fade.stop()
			PLAYER.is_interacting = false
		
			if current_building != null:
				for occupant in current_building.usual_occupants:
					occupant.process_mode = Node.PROCESS_MODE_INHERIT
					occupant.paused = false
			else:
				for asset in get_all_assets_in_game():
					if asset is GameCharacter and not asset is Enemy:
						if !asset.in_building:
							asset.paused = false
							asset.process_mode = Node.PROCESS_MODE_INHERIT
					else:
						asset.paused = false
						#asset.process_mode = Node.PROCESS_MODE_INHERIT
				
			
			PLAYER.paused = false
			PLAYER.process_mode = Node.PROCESS_MODE_INHERIT
			
			food_buddies_active[0].paused = false
			food_buddies_active[0].process_mode = Node.PROCESS_MODE_INHERIT
			food_buddies_active[0].target = null
			
			food_buddies_active[1].paused = false
			food_buddies_active[1].process_mode = Node.PROCESS_MODE_INHERIT
			food_buddies_active[1].target = null




# Callback function that executes whenever a Building is being entered by the Player: fades the screen to transition from exterior to interior and adjusts the Player's and Food Buddy's location to be positioned appropriately in the map
func _on_player_enter_building(building: Building, _delta: float):
	
	if current_building != building:
		screen_fading = true
		current_building = building
		
		for asset in get_all_assets_in_game():
			asset.paused = true
			asset.process_mode = Node.PROCESS_MODE_DISABLED
			
			if asset is CharacterBody2D:
				asset.velocity = Vector2(0, 0)
		
		# Freeze processing of everything except the game itself
	else:
		
		if screen_fading and modulate.a == 0:
			
			PLAYER.global_position = current_building.global_position - current_building.player_offset
			PLAYER.in_building = true
			
			food_buddies_active[0].closest_bush = Vector2i(-1, -1)
			food_buddies_active[1].closest_bush = Vector2i(-1, -1)
			
			if food_buddies_active[0].field_state_current != FoodBuddy.FieldState.PLAYER:
				food_buddies_active[0].global_position = PLAYER.global_position - current_building.foodbuddy1_offset
			else:
				food_buddies_active[0].global_position = PLAYER.global_position
			
			food_buddies_active[0].in_building = true
			
			
			if food_buddies_active[1].field_state_current != FoodBuddy.FieldState.PLAYER:
				food_buddies_active[1].global_position = PLAYER.global_position - current_building.foodbuddy2_offset
			else:
				food_buddies_active[1].global_position = PLAYER.global_position
			
			food_buddies_active[1].in_building = true
			
			
			current_building.playerEntering = false
			current_building.label_e_to_interact.text = "Press 'E' to\nExit"
			
			for asset in get_all_assets_in_game():
				asset.visible = false
				asset.process_mode = Node.PROCESS_MODE_DISABLED
			
			current_building.current_occupants.append(PLAYER)
			current_building.current_occupants.append(food_buddies_active[0])
			current_building.current_occupants.append(food_buddies_active[1])
			
			for occupant in current_building.usual_occupants:
				occupant.visible = true
				occupant.global_position = Vector2(PLAYER.global_position.x + 50, PLAYER.global_position.y - 20)
				occupant.target = PLAYER
				current_building.current_occupants.append(occupant)
			
			current_building.paused = false
			current_building.process_mode = Node.PROCESS_MODE_INHERIT
			current_building.visible = true
			
			PLAYER.visible = true
			if food_buddies_active[0].field_state_current == FoodBuddy.FieldState.PLAYER:
				if food_buddies_active[0].name == "Dan":
					food_buddies_active[0].visible = true
			else:
				food_buddies_active[0].visible = true
			
			if food_buddies_active[1].field_state_current == FoodBuddy.FieldState.PLAYER:
				if food_buddies_active[1].name == "Dan":
					food_buddies_active[1].visible = true
			else:
				food_buddies_active[1].visible = true



# Callback function that executes whenever a Building is being exited by the Player: fades the screen to transition from interior to exterior and adjusts the Player's and Food Buddy's location to be positioned appropriately in the map
func _on_player_exit_building(_building: Building, _delta: float):
	
	if !screen_fading:
		screen_fading = true
		
		for asset in get_all_assets_in_game():
			asset.paused = true
			asset.process_mode = Node.PROCESS_MODE_DISABLED
			
			if asset is CharacterBody2D:
				asset.velocity = Vector2(0, 0)
		
		if food_buddies_active[0].field_state_current == FoodBuddy.FieldState.PLAYER:
			if food_buddies_active[0].name == "Dan":
				food_buddies_active[0].visible = true
		else:
			food_buddies_active[0].visible = true
		
		if food_buddies_active[1].field_state_current == FoodBuddy.FieldState.PLAYER:
			if food_buddies_active[1].name == "Dan":
				food_buddies_active[1].visible = true
		else:
			food_buddies_active[1].visible = true
		
		PLAYER.visible = true

		
	else:
		if screen_fading and modulate.a == 0:
			
			PLAYER.global_position = current_building.global_position + current_building.player_offset
			PLAYER.in_building = false
			
			if food_buddies_active[0].field_state_current != FoodBuddy.FieldState.PLAYER:
				food_buddies_active[0].global_position = PLAYER.global_position + current_building.foodbuddy1_offset
			else:
				food_buddies_active[0].global_position = PLAYER.global_position
			
			food_buddies_active[0].in_building = false
			
			if food_buddies_active[1].field_state_current != FoodBuddy.FieldState.PLAYER:
				food_buddies_active[1].global_position = PLAYER.global_position + current_building.foodbuddy2_offset
			else:
				food_buddies_active[1].global_position = PLAYER.global_position
			
			food_buddies_active[1].in_building = false
			
			
			# Remove the Player and their Food Buddies from the list of current occupants
			for occupant in range(current_building.current_occupants.size() - 1, -1, -1):
				if current_building.current_occupants[occupant] is Player or current_building.current_occupants[occupant] is FoodBuddy:
					current_building.current_occupants.remove_at(occupant)
			
			current_building.playerExiting = false
			current_building.label_e_to_interact.text = "Press 'E' to\nEnter"
			
			for occupant in current_building.usual_occupants:
				occupant.visible = false
				occupant.process_mode = Node.PROCESS_MODE_DISABLED
				occupant.paused = true
			
			current_building.process_mode = Node.PROCESS_MODE_INHERIT
			current_building = null
			
			for asset in get_all_assets_in_game():
				if asset is GameCharacter:
					if !asset.in_building:
						asset.visible = true
				else:
					asset.visible = true
			
			if food_buddies_active[0].field_state_current == FoodBuddy.FieldState.PLAYER:
				if food_buddies_active[0].name == "Dan":
					food_buddies_active[0].visible = true
				else:
					food_buddies_active[0].visible = false
			else:
				food_buddies_active[0].visible = true
			
			if food_buddies_active[1].field_state_current == FoodBuddy.FieldState.PLAYER:
				if food_buddies_active[1].name == "Dan":
					food_buddies_active[1].visible = true
				else:
					food_buddies_active[1].visible = false
			else:
				food_buddies_active[1].visible = true


func _on_player_throw_juicebox(destination: Vector2) -> void:
	
	var juicebox: Juicebox
	var horizontal_direction: int
	
	juicebox = load("res://scenes/blueprints/juicebox.tscn").instantiate()
	juicebox.global_position = Vector2(PLAYER.global_position.x, PLAYER.global_position.y - 10)
	juicebox.explode.connect(_on_juicebox_explode)
	
	add_child(juicebox)
	
	if destination.x <= juicebox.global_position.x:
		horizontal_direction = juicebox.Direction.LEFT
	else:
		horizontal_direction = juicebox.Direction.RIGHT
	
	juicebox.throw_start(destination, horizontal_direction)


func _on_juicebox_explode(juicebox):
	
	var hitboxes = juicebox.hitbox_heal.get_overlapping_areas()
	
	if PLAYER.hitbox_interaction in hitboxes and PLAYER.alive:
		PLAYER.health_current += juicebox.health
		PLAYER.healing_health = true
		
		if PLAYER.health_current > PLAYER.health_max:
			PLAYER.health_current = PLAYER.health_max
	
	for food_buddy in food_buddies_active:
		if food_buddy.hitbox_interaction in hitboxes and food_buddy.alive:
			food_buddy.health_current += juicebox.health
			food_buddy.healing_health = true
			
			if food_buddy.health_current > food_buddy.health_max:
				food_buddy.health_current = food_buddy.health_max
	
	update_character_status_UI()



func _on_brittany_fire_energy_ball(destination: Vector2) -> void:
	
	var energy_ball: EnergyBall
	
	energy_ball = load("res://scenes/blueprints/energy-ball.tscn").instantiate()
	energy_ball.damage = BRITTANY.ability_damage["Solo"]
	
	if BRITTANY.current_direction_name == "sideways" and !BRITTANY.sprite.flip_h:
		energy_ball.global_position = Vector2(BRITTANY.global_position.x - 25, BRITTANY.global_position.y - 15)
	elif BRITTANY.current_direction_name == "sideways" and BRITTANY.sprite.flip_h:
		energy_ball.global_position = Vector2(BRITTANY.global_position.x + 25, BRITTANY.global_position.y - 15)
	else:
		energy_ball.global_position = Vector2(BRITTANY.global_position.x, BRITTANY.global_position.y - 15)
	
	energy_ball.explode.connect(_on_energy_ball_explode)
	if not BRITTANY.target is Enemy:
		energy_ball.target = null
	else:
		energy_ball.target = BRITTANY.target
	
	add_child(energy_ball)
	
	energy_ball.throw_start(destination, int(BRITTANY.direction_current_horizontal))

func _on_energy_ball_explode(energy_ball):
	if energy_ball is EnergyBall:
		process_attack(BRITTANY.target, BRITTANY, energy_ball.damage, energy_ball.hitbox_damage)


func update_character_status_UI():
	InterfaceCharacterStatus.setValues(PLAYER, food_buddies_active)

func connect_character_to_game(character: Node2D):
	
	if character is Enemy:
		load_enemy(character)
	
	elif character is FoodCitizen:
		load_food_citizen(character)
		
	elif character is FoodBuddy:
		load_food_buddy(character)


func load_enemy(enemy: Enemy):
	enemy.process_tiles.connect(process_tiles)
	enemy.use_ability.connect(_on_enemy_use_ability)
	enemy.die.connect(_on_character_die)
	enemy.killed_target.connect(_on_enemy_killed_target)
	enemy.target_closest_food_buddy.connect(_on_character_target_closest_food_buddy)
	enemy.target_player.connect(_on_character_target_player)
	enemy.update_altitude.connect(_on_character_update_altitude)
	add_child(enemy)

func load_food_citizen(foodcitizen: FoodCitizen):
	foodcitizen.process_tiles.connect(process_tiles)
	foodcitizen.target_player.connect(_on_character_target_player)
	foodcitizen.target_closest_food_buddy.connect(_on_character_target_closest_food_buddy)
	add_child(foodcitizen)

func load_food_buddy(foodbuddy: FoodBuddy):
	foodbuddy.process_tiles.connect(process_tiles)
	foodbuddy.deposit_berries.connect(_on_food_buddy_deposit_berries)
	foodbuddy.find_nearest_bush.connect(_on_food_buddy_find_nearest_bush)
	foodbuddy.forage_bush.connect(_on_food_buddy_forage_bush)
	foodbuddy.target_brittany.connect(_on_food_buddy_target_brittany)
	foodbuddy.target_closest_enemy.connect(_on_food_buddy_target_closest_enemy)
	foodbuddy.use_ability_solo.connect(_on_food_buddy_use_ability_solo)
	foodbuddy.die.connect(_on_character_die)
	foodbuddy.killed_target.connect(_on_character_killed_target)
	foodbuddy.target_player.connect(_on_character_target_player)
	foodbuddy.update_altitude.connect(_on_character_update_altitude)
	add_child(foodbuddy)

func _on_character_changed_world(character: GameCharacter):
	
	transition_music(character.current_world)

func transition_music(character_world: String):
	
	timer_fade_music.start(music_fade_out_duration)
	
	if character_world == "center":
		next_song = WorldCenterSong
	elif character_world == "sweets":
		next_song = BatterBadlandsSong
	elif character_world == "garden":
		next_song = GardenSong
	else:
		next_song = empty_song
	
	transitioning_songs = true

func process_music_fade(delta: float):
	if !timer_fade_music.is_stopped() and next_song != null:
		MUSIC.volume_db = lerp(MUSIC.volume_db, float(-80), delta * (music_fade_out_duration - timer_fade_music.time_left) / music_fade_out_duration)
	else:
		
		if next_song != null:
			
			MUSIC.stop()
			
			if next_song == empty_song:
				transitioning_songs = false
				return
			
			MUSIC = next_song
			MUSIC.volume_db = -17
			timer_fade_music.start(music_fade_in_duration)
			MUSIC.play()
			next_song = null
			
		if !timer_fade_music.is_stopped():
			MUSIC.volume_db = lerp(MUSIC.volume_db, float(-8), delta * (music_fade_in_duration - timer_fade_music.time_left) / music_fade_in_duration)
		else:
			MUSIC.volume_db = -8
			transitioning_songs = false
		
	
func adjust_tilemap_modulate(modulate_value: float):
	# Iterate over each tilemap that could be on screen right now and disable it
	for world in world_tilemaps:
		for tilemap in world_tilemaps[world]:
			
			tilemap.modulate.a = modulate_value
	
	ocean_tilemap.modulate.a = modulate_value


func process_tiles(character: GameCharacter):
	GameTileManager.process_nearby_tiles(character)

func zoom_out_map():
	map_zooming = true
	
	for asset in get_all_assets_in_game():
		if not (asset is GameCharacter and asset.on_screen_notifier.is_on_screen()):
			asset.visible = false
		
		asset.process_mode = Node.PROCESS_MODE_DISABLED
		asset.paused = true
	
	PLAYER.visible = true
	
	for foodbuddy in food_buddies_active:
		
		foodbuddy.previous_animation = foodbuddy.sprite.animation
		foodbuddy.previous_animation_frame = foodbuddy.sprite.get_frame()
		foodbuddy.previous_animation_frame_progress = foodbuddy.sprite.get_frame_progress()
		
		if foodbuddy.field_state_current == foodbuddy.FieldState.PLAYER:
		
			if foodbuddy.name == "Dan":
				foodbuddy.visible = true
		else:
			foodbuddy.visible = true
			
	PLAYER.process_mode = Node.PROCESS_MODE_INHERIT
	PLAYER.velocity.x = 0
	PLAYER.velocity.y = 0
	PLAYER.animation_player.play("zoom_out")
	PLAYER.animation_player.queue("zoomed_out")
	InterfaceCharacterStatus.animator.play("exit_UI")
	PLAYER.paused = true
	PLAYER.update_animation()
	map_zoomed_in = false

func zoom_in_map():
	map_zooming = true
	
	PLAYER.animation_player.play("zoom_in")
	PLAYER.animation_player.queue("zoomed_in")
	
	map_zoomed_in = true


func _on_map_zoomed_in() -> void:
	map_zooming = false
	PLAYER.paused = false
	InterfaceCharacterStatus.animator.play("enter_UI")
	
	for asset in get_all_assets_in_game():
		if asset is GameCharacter and asset.on_screen_notifier.is_on_screen():
			asset.process_mode = Node.PROCESS_MODE_INHERIT
		
		asset.paused = false
		asset.visible = true
	
	for foodbuddy in food_buddies_active:
		foodbuddy.process_mode = Node.PROCESS_MODE_INHERIT
		
		foodbuddy.sprite.play(foodbuddy.previous_animation)
		foodbuddy.sprite.set_frame_and_progress(foodbuddy.previous_animation_frame, foodbuddy.previous_animation_frame)
		
		if foodbuddy.field_state_current == foodbuddy.FieldState.PLAYER:
		
			if foodbuddy.name == "Dan":
				foodbuddy.visible = true
			else:
				foodbuddy.visible = false


func _on_map_zoomed_out() -> void:
	map_zooming = false
	
	
func set_to_player_world(character: GameCharacter) -> void:
	character.current_world = PLAYER.current_world
	character.current_tilemaps = PLAYER.current_tilemaps
	
