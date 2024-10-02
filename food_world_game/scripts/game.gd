extends Node2D

# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

@onready var PLAYER: Player = $Player
@onready var ENEMY: Enemy = $Enemy
@onready var FOOD_BUDDY: FoodBuddy = $"Food Buddy"

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

enum World { SWEETS, GARDEN, COLISEUM, MEAT, SEAFOOD, JUNKFOOD, PERISHABLE, SPUD }

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Enemies #
@onready var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	PLAYER.food_buddy1 = FOOD_BUDDY
	PLAYER.food_buddy2 = FOOD_BUDDY



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



# Called every frame. Updates the Player's physics
func _physics_process(delta: float) -> void:
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Determines which Food Buddies are currently active with the Player and returns them in a list
func get_active_food_buddies() -> Array[Node2D]:
	
	var active_food_buddies: Array[Node2D] = []
	
	if PLAYER.food_buddy1 != null:
		active_food_buddies.append(PLAYER.food_buddy1)
	
	if PLAYER.food_buddy2 != null:
		active_food_buddies.append(PLAYER.food_buddy2)

	return active_food_buddies



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
func select_closest_target(subject: Node2D, targets: Array[Node2D]) -> Node2D:
	
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
			attacker.killed_target.emit(attacker)
		
		return true
	
	return false

func trigger_buddy_fusion_ability(food_buddy_fusion: FoodBuddyFusion):
	pass

# Determines which world the Player is currently located in
func determine_player_location_world() -> World:
	
	# Implement checks to find out which world the Player is in based on the tile type that they're touching and their coordinates and return the correct world
	
	return World.COLISEUM


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# CALLBACK FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# PLAYER CALLBACKS # ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Callback function that executes whenever the Player equips a Food Buddy: updates the Food Buddy's FightStyle
func _on_player_equip_buddy() -> void:
	pass # Replace with function body.


func _on_player_equip_buddy_fusion() -> void:
	pass # Replace with function body.


# Callback function that executes whenever the Player wants to use a solo ability: processes the solo attack against enemies
func _on_player_use_ability_solo(damage: int) -> void:
	
	# Iterate over every enemy currently on the screen to check if the Player's attack landed on them, then stop checking if the attack landed because the Player's solo ability can only damage one enemy at a time
	for enemy in get_enemies_on_screen():
		if process_attack(enemy, PLAYER, damage):
			return



# Callback function that executes whenever the Player has triggered the use of an ability while using a Food Buddy: executes the Food Buddy's ability
func _on_player_use_ability_buddy(food_buddy: FoodBuddy, ability_number: int) -> void:
	if ability_number == 1:
		food_buddy.use_ability1()
	elif ability_number == 2:
		food_buddy.use_ability2()
	else:
		food_buddy.use_special_attack()



# Callback function that executes whenever the Player has triggered the use of an ability while using a Food Buddy Fusion: executes the Food Buddy Fusion's ability
func _on_player_use_ability_buddy_fusion(food_buddy_fusion: FoodBuddyFusion, ability_number: int) -> void:
	if ability_number == 1:
		food_buddy_fusion.use_ability1()
	elif ability_number == 2:
		food_buddy_fusion.use_ability2()
	else:
		food_buddy_fusion.use_special_attack()



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
	
	var target_closest = select_closest_target(food_buddy, get_enemies_on_screen())
		
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
	
	if food_buddy == PLAYER.food_buddy1:
		PLAYER.food_buddy1 = null
	
	if food_buddy == PLAYER.food_buddy2:
		PLAYER.food_buddy2 = null
	
	remove_child(food_buddy)
	print("Food Buddy has died!")



# ENEMY CALLBACKS # -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Callback function that executes whenever the Enemy wants to use an ability: processes the ability against the Player and active Food Buddies
func _on_enemy_use_ability(enemy: Enemy, damage: int) -> void:
	process_attack(PLAYER, enemy, damage)
	process_attack(PLAYER.food_buddy1, enemy, damage)
	#process_attack(PLAYER.food_buddy2, enemy, damage)



# Callback function that executes whenever the Enemy wants to set the Player as it's target: sets the Player as the target of the Enemy
func _on_enemy_target_player(enemy: Enemy) -> void:
	enemy.target = PLAYER



# Callback function that executes whenever the Enemy wants to set the closest Food Buddy as it's target: sets the closest Food Buddy as the target of the Enemy
func _on_enemy_target_closest_food_buddy(enemy: Enemy) -> void:
	
	var target_closest = select_closest_target(enemy, get_active_food_buddies())
		
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
