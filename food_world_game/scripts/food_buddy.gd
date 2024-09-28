class_name FoodBuddy

extends RigidBody2D

# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Animations #
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Hitbox #
@onready var hitbox: Area2D = $Area2D

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

# Fighting #
var fight_style_current: FightStyle
var target_enemy: Enemy
var target_enemy_distance: float

# Field State #
var field_state_current: FieldState

# Abilities #
var ability_solo_damage: int

var ability1_type: AbilityType
var ability1_damage: int

var ability2_type: AbilityType
var ability2_damage: int

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#func _init(solo_damage: int, solo_range: int, 
		   #ability_type_1: FoodBuddy.AbilityType, ability_damage_1: int, ability_range_1: int,
		   #ability_type_2: FoodBuddy.AbilityType, ability_damage_2: int, ability_range_2: int, 
		   #base_health: int) -> void:
	#
	#ability1_type = ability_type_1
	#ability1_damage = ability_damage_1
	#
	#ability2_type = ability_type_2
	#ability2_damage = ability_damage_2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lock_rotation = true
	freeze = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if field_state_current == FieldState.FOLLOW:
		pass # Have the Food Buddy follow loosely behind the Player
	
	elif field_state_current == FieldState.FIGHT:
		pass


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

func use_solo_attack():
	
	# Determine if the Food Buddy doesn't have an enemy to target currently
	if target_enemy == null:
		
		# Store a list of references to all of the enemies currently loaded into the game, and create an empty list that will hold any enemies on the screen
		var enemies: Array[Node] = get_tree().get_nodes_in_group("Enemy") # <----- (PERHAPS change this to be enemies that are in the world you're currently in)
		var enemies_on_screen: Array[Enemy] = []
		
		# Iterate over all of the enemies currently loaded in the game
		for enemy in enemies:
			
			# Determine if the enemy is on-screen, then add them to a list of on-screen enemies
			if enemy.visible_on_screen_notifier_2d.is_on_screen():
				enemies_on_screen.append(enemy)
		
		# Temporarily store the first enemy in the list of on-screen enemies as the target enemy and it's distance from the Food Buddy
		target_enemy = enemies_on_screen[0]
		target_enemy_distance = global_position.distance_to(target_enemy.global_position)
		
		# Iterate over all of the enemies currently on-screen
		for enemy in enemies_on_screen:
			
			# Calculate and store the distance between the Food Buddy and the enemy
			var enemy_distance = global_position.distance_to(enemy.global_position)
			
			# Determine if the enemy's distance is closer than the target enemy's distance, then set that enemy as the new closest enemy
			if enemy_distance < target_enemy_distance:
				target_enemy = enemy
				target_enemy_distance = enemy_distance

	# Determine if the Food Buddy is in range of the enemy, then launch solo field attack (send signal to enemy) then trigger an attack cooldown
	if target_enemy_distance <= 0:
		use_ability_solo.emit(hitbox, ability_solo_damage)
	else:
		pass
		apply_central_impulse(-target_enemy.linear_velocity)

		# Move closer to enemy
		
	# IF THE TARGET ENEMY RUNS OUT OF HEALTH AND IS PURGED, SET TARGET ENEMY TO NULL SO THAT THE FOOD BUDDY WILL BEGIN TARGETING A NEW ENEMY


# Executes the logic for ability 1
func use_ability1():
	# THIS CODE SHOULD BE MANUALLY WRITTEN FOR EACH FOOD BUDDY BECAUSE EVERY ABILITY WILL HAVE A DIFFERENT EXECUTION
	pass



# Executes the logic for ability 2
func use_ability2():
	# THIS CODE SHOULD BE MANUALLY WRITTEN FOR EACH FOOD BUDDY BECAUSE EVERY ABILITY WILL HAVE A DIFFERENT EXECUTION
	pass



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



func _on_player_equip_buddy(food_buddy: FoodBuddy) -> void:
	
	if self == food_buddy:
		if fight_style_current != FightStyle.PLAYER:
			fight_style_current = FightStyle.PLAYER
		else:
			fight_style_current = FightStyle.SOLO



func _on_player_equip_buddy_fusion() -> void:
	if fight_style_current != FightStyle.BUDDY_FUSION:
		fight_style_current = FightStyle.BUDDY_FUSION
	else:
		fight_style_current = FightStyle.SOLO


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
