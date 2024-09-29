extends Node2D

# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

@onready var player: Player = $Player
@onready var enemy: Enemy = $Enemy
@onready var food_buddy: FoodBuddy = $"Food Buddy"

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
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



# Called every frame. Updates the Player's physics
func _physics_process(delta: float) -> void:
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
	
	# Determine if there are no targets in the provided list of targets
	if targets.size() == 0:
		return null
		
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



# Determines if an attack has landed and reduces the attacked Node's health if it has. Returns true if the attack landed on that enemy, false if not.
func process_attack(victim: Node2D, attacker: Node2D, damage: int) -> bool:
	
	# Store a list of all hitboxes that the hitbox of the attack has overlapped with
	var hitboxes = attacker.hitbox.get_overlapping_areas()
	
	# Determine if the attacked Node's hitbox is in the list of hitboxes that the attack's hitbox overlapped with, then reduce their health
	if victim.hitbox in hitboxes:
		victim.health_current -= damage
		
		# Determine if the attacked Node has run out of health, then emit their death signal
		if victim.health_current <= 0:
			victim.die.emit(victim)
			attacker.killed_victim.emit(attacker)
		
		return true
	
	return false



# Determines which world the Player is currently located in
func determine_player_location_world() -> World:
	
	# Implement checks to find out which world the Player is in based on the tile type that they're touching and their coordinates and return the correct world
	
	return World.COLISEUM


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# CALLBACK FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Callback function that executes whenever an Enemy dies: removes the Enemy from the SceneTree
func _on_enemy_die(enemy: Enemy) -> void:
	remove_child(enemy)
	print("Enemy has died!")



# Callback function that executes whenever the Player wants to use a solo ability: processes the solo attack against enemies
func _on_player_use_ability_solo(damage: int) -> void:
	
	# Iterate over every enemy currently on the screen to check if the Player's attack landed on them, then stop checking if the attack landed because the Player's solo ability can only damage one enemy at a time
	for enemy in get_enemies_on_screen():
		if process_attack(enemy, player, damage):
			return



# Callback function that executes whenever the Food Buddy wants to move towards the Player: moves the Food Buddy towards the Player
func _on_food_buddy_move_towards_player(food_buddy: FoodBuddy, desired_distance: float) -> void:
	move_towards_target(food_buddy, player, desired_distance)



# Callback function that executes whenever the Food Buddy wants to move towards an enemy: moves the Food Buddy towards the given enemy
func _on_food_buddy_move_towards_enemy(food_buddy: FoodBuddy, target_enemy: Enemy, desired_distance: float) -> void:
	food_buddy.target_enemy_distance = move_towards_target(food_buddy, target_enemy, desired_distance)



# Callback function that executes whenever the Food Buddy wants to select the closest enemy as it's target: sets the closest enemy as the Food Buddy's target
func _on_food_buddy_target_closest_enemy(food_buddy: FoodBuddy) -> void:
	
	var target_closest = select_closest_target(food_buddy, get_enemies_on_screen())
		
	if target_closest != null:
		food_buddy.target_enemy = target_closest
		food_buddy.target_enemy_distance = food_buddy.position.distance_to(target_closest.position)
	else:
		food_buddy.target_enemy = null
		food_buddy.target_enemy_distance = 0



# Callback function that executes whenever the Food Buddy wants to use a solo ability: processes the solo attack against enemies
func _on_food_buddy_use_ability_solo(food_buddy: FoodBuddy, damage: int) -> void:
	
	# Iterate over every enemy currently on the screen to check if the Food Buddy's attack landed on them
	for enemy in get_enemies_on_screen():
		process_attack(enemy, food_buddy, damage)



# Callback function that executes whenever the Food Buddy has killed an enemy: sets the Food Buddy's target enemy to null
func _on_food_buddy_killed_victim(food_buddy: FoodBuddy) -> void:
	food_buddy.target_enemy = null
	# Increase XP for killing an enemy
