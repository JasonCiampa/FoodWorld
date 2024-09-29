class_name FoodBuddy

extends CharacterBody2D

# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Animations #
var sprite: AnimatedSprite2D
var animation_player: AnimationPlayer

# Hitbox #
var hitbox: Area2D

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

signal use_ability_solo
signal use_ability_player
signal use_ability_buddy_fusion

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

enum AbilityType { ATTACK, TRAVERSAL, PUZZLE, HYBRID }

enum FieldState { FOLLOW, FIGHT }

enum FightStyle { SOLO, PLAYER, BUDDY_FUSION }

enum AttackDamage { SOLO = 10, ABILITY1 = 0, ABILITY2 = 0}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Health #
var health_current: int
var health_max: int

# Speed #
var speed_normal: int = 50
var speed_current: int = speed_normal

# Fighting #
var fight_style_current: FightStyle
var target_enemy: Enemy = null
var target_enemy_distance: float
var target_enemy_just_died: bool = false

# Field State #
var field_state_current: FieldState

# Abilities #
var ability_solo_damage: int = 10

var ability1_type: AbilityType
var ability1_damage: int
var ability1_range: int

var ability2_type: AbilityType
var ability2_damage: int
var ability2_range: int

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Store references to the Food Buddy's Nodes
	sprite = $AnimatedSprite2D
	animation_player  = $AnimationPlayer
	hitbox = $Area2D
	
	# Set the Food Buddy's current field state to be fighting
	field_state_current = FieldState.FIGHT
	
	# Call the custom "ready()" function that Food Buddy subclasses will define individually
	ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# Determine the Food Buddy's current field state, then alter their movement/attack behavior based on that field state
	if field_state_current == FieldState.FOLLOW:
		pass # Have the Food Buddy follow loosely behind the Player
	

	
	# Call the custom "update()" function that Food Buddy subclasses will define individually
	process()


# Called every frame. Updates the Player's physics
func _physics_process(delta: float) -> void:
	
	# Determine if the Food Buddy is currently in the fighting field state, then execute their solo attack
	if field_state_current == FieldState.FIGHT:
		use_solo_attack()
	
	# Adjust the Food Buddy's position based on its velocity
	move_and_slide()
	
	# Call the custom "physics_process()" function that Food Buddy subclasses will define individually
	physics_process(delta)


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# A custom ready function that each Food Buddy subclass should personally define. This is called in the default FoodBuddy class's '_ready()' function
func ready():
	pass



# A custom process function that each Food Buddy subclass should personally define. This is called in the default FoodBuddy class's '_process()' function
func process():
	pass



# A custom physics_process function that each Food Buddy subclass should personally define. This is called in the default FoodBuddy class's '_physics_process()' function
func physics_process(delta: float) -> void:
	pass



# A custom function to execute the Food Buddy's ability 1 that each Food Buddy subclass should personally define. This is called in the FoodBuddy class's "_on_player_use_ability_buddy()" callback function.
func use_ability1():
	# THIS CODE SHOULD BE MANUALLY WRITTEN FOR EACH FOOD BUDDY BECAUSE EVERY ABILITY WILL HAVE A DIFFERENT EXECUTION
	pass



# A custom function to execute the Food Buddy's ability 2 that each Food Buddy subclass should personally define. This is called in the FoodBuddy class's "_on_player_use_ability_buddy()" callback function.
func use_ability2():
	# THIS CODE SHOULD BE MANUALLY WRITTEN FOR EACH FOOD BUDDY BECAUSE EVERY ABILITY WILL HAVE A DIFFERENT EXECUTION
	pass



# Determines which enemies are currently on-screen and returns them in a list
func get_enemies_on_screen() -> Array[Enemy]:
	
	# Store a list of references to all of the enemies currently loaded into the game, and create an empty list that will hold any enemies on the screen
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies") # <----- (PERHAPS change this to be enemies that are in the world you're currently in)
	var enemies_on_screen: Array[Enemy] = []
	
	# Iterate over all of the enemies currently loaded in the game
	for enemy in enemies:
		
		if not use_ability_solo.is_connected(enemy._on_food_buddy_use_ability_solo):
			use_ability_solo.connect(enemy._on_food_buddy_use_ability_solo)
		
		# Determine if the enemy is on-screen, then add them to a list of on-screen enemies
		if enemy.on_screen_notifier.is_on_screen():
			enemies_on_screen.append(enemy)
	
	return enemies_on_screen



# Determines which enemy in a given list of enemies is closest to the Food Buddy and sets that enemy as the Food Buddy's target
func target_closest_enemy():
	
	# Get a reference to a list of all enemies that are currently on-screen
	var enemies_on_screen: Array[Enemy] = get_enemies_on_screen()
	
	if enemies_on_screen.size() == 0:
		# Follow the Player
		return
	
	# Temporarily store the first enemy in the list of enemies as the target enemy and also store it's distance from the Food Buddy
	target_enemy = enemies_on_screen[0]
	target_enemy_distance = position.distance_to(target_enemy.position)
	
	# Iterate over all of the enemies in the given list
	for enemy in enemies_on_screen:
		
		# Calculate and store the distance between the Food Buddy and the  enemy
		var enemy_distance: float = position.distance_to(enemy.position)
		
		# Determine if the enemy's distance is closer than the target enemy's distance, then set that enemy as the new closest enemy
		if enemy_distance < target_enemy_distance:
			target_enemy = enemy
			target_enemy_distance = enemy_distance



# Executes the logic for a Food Buddy's solo attack
func use_solo_attack():

	# Determine if the Food Buddy doesn't have an enemy to target currently, then target the closest enemy
	if target_enemy == null:
		target_closest_enemy()
		return

	# Determine if the Food Buddy is in range of the enemy, then make them stop moving and launch their solo attack
	if target_enemy_distance <= 10:
		velocity.x = 0
		velocity.y = 0
		use_ability_solo.emit(hitbox, ability_solo_damage)
	else:
		
		# Move the Food Buddy towards the enemy that is currently being targeted
		if position.x < target_enemy.position.x:
			velocity.x = speed_current
		elif position.x > target_enemy.position.x:
			velocity.x = -speed_current
			
		if position.y < target_enemy.position.y:
			velocity.y = speed_current
		elif position.y > target_enemy.position.y:
			velocity.y = -speed_current
		
		# Update the reference to the enemy's distance from the Food Buddy
		target_enemy_distance = position.distance_to(target_enemy.position)



# Callback function that executes whenever the Player equips a Food Buddy: updates the Food Buddy's fight style
func _on_player_equip_buddy(food_buddy: FoodBuddy) -> void:
	if self == food_buddy:
		if fight_style_current != FightStyle.PLAYER:
			fight_style_current = FightStyle.PLAYER
		else:
			fight_style_current = FightStyle.SOLO



# Callback function that executes whenever the Player equips a Food Buddy: updates the Food Buddy's fight style
func _on_player_equip_buddy_fusion() -> void:
	if fight_style_current != FightStyle.BUDDY_FUSION:
		fight_style_current = FightStyle.BUDDY_FUSION
	else:
		fight_style_current = FightStyle.SOLO



# Callback function that executes whenever the Player uses an ability while having a Food Buddy equipped: launches the Food Buddy's ability
func _on_player_use_ability_buddy(food_buddy: FoodBuddy, ability_number: int) -> void:
	if self == food_buddy:
		if ability_number == 1:
			pass
			# Use ability 1
			# if ability isn't an attack or hybrid, don't emit any signal to enemies but launch ability logic (animation is handled in Player)
			# if ability is an attack emit a new signal to enemy from this food buddy that will handle damage (animation is handled in Player)
			use_ability1()
			use_ability_player.emit()
		else:
			pass
			# Use ability 2
			# if ability isn't an attack or hybrid, don't emit any signal to enemies but launch ability logic (animation is handled in Player)
			# if ability is an attack emit a new signal to enemy from this food buddy that will handle damage (animation is handled in Player)
			use_ability2()
			use_ability_player.emit()



# Callback function that executes whenever the enemy that the Food Buddy is currently targeting dies
func _on_enemy_die(enemy: Enemy) -> void:
	if enemy == target_enemy:
		target_enemy = null
		velocity.x = 0
		velocity.y = 0
		print("FoodBuddy killed enemy!")
