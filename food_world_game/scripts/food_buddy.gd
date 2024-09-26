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
signal use_ability1_player
signal use_ability1_buddy_fusion

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

enum AbilityType { ATTACK, TRAVERSAL, PUZZLE }

enum FieldState { FOLLOW, FIGHT }

enum FightStyle { SOLO, PLAYER, BUDDY_FUSION }

enum AttackDamage { SOLO = 10, ABILITY1, ABILITY2 }
enum AttackRange { SOLO = 5 }


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Fighting #
var fight_style_current
var target_enemy
var target_enemy_distance

var field_state_current

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lock_rotation = true
	freeze = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if field_state_current == FieldState.FOLLOW:
		pass # Have the Food Buddy follow loosely behind the Player
		
	elif field_state_current == FieldState.FIGHT:
		if target_enemy == null:
			var enemies: Array[Node] = get_tree().get_nodes_in_group("Enemy")
			var enemies_on_screen: Array[Enemy] = []
			
			# Iterate over all of the enemies currently in the game (PERHAPS change this to be enemies that are in the world you're currently in)
			for enemy in enemies:
				# Determine if the enemy is on-screen, then add them to a list of on-screen enemies
				if enemy.visible_on_screen_notifier_2d.is_on_screen():
					enemies_on_screen.append(enemy)
			
			target_enemy = enemies_on_screen[0]
			target_enemy_distance = global_position.distance_to(target_enemy.global_position)
			
			# Iterate over all of the enemies currently on-screen
			for enemy in enemies_on_screen:
				
				# Calculate and store the distance between the Food Buddy and the enemy
				var enemy_distance = global_position.distance_to(enemy.global_position)
				
				# Determine if the enemy's distance is less than the closest enemy's distance, then set that enemy as the new closest enemy
				if enemy_distance < target_enemy_distance:
					target_enemy = enemy
					target_enemy_distance = enemy_distance

		# Determine if the Food Buddy is in range of the enemy, then launch solo field attack (send signal to enemy) then trigger an attack cooldown
		if target_enemy_distance <= AttackRange.SOLO:
			use_ability_solo.emit(self)
		else:
			pass
			# Move closer to enemy
			
		# IF THE TARGET ENEMY RUNS OUT OF HEALTH AND IS PURGED, SET TARGET ENEMY TO NULL SO THAT THE FOOD BUDDY WILL BEGIN TARGETING A NEW ENEMY

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





func _on_player_use_ability_buddy(food_buddy: FoodBuddy, ability_number: int) -> void:
	if self == food_buddy:
		if ability_number == 1:
			pass
			# Use ability 1
			# if ability isn't an attack, don't emit any signal to enemies but launch ability logic (animation is handled in Player)
			# if ability is an attack emit a new signal to enemy from this food buddy that will handle damage (animation is handled in Player)
		else:
			pass
			# Use ability 2
			# if ability isn't an attack, don't emit any signal to enemies but launch ability logic (animation is handled in Player)
			# if ability is an attack emit a new signal to enemy from this food buddy that will handle damage (animation is handled in Player)



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
