extends CharacterBody2D


class_name FoodBuddy


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Animations #
var sprite: AnimatedSprite2D
var animation_player: AnimationPlayer

# Hitbox #
var hitbox: Area2D

# Inventory #
var inventory: Array = []
var inventory_size: int = 12

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

signal use_ability_solo

signal target_closest_enemy
signal target_player

signal move_towards_target

signal killed_target
signal die

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

enum AbilityType { ATTACK, TRAVERSAL, PUZZLE, HYBRID }


enum FieldState 
{ 
FOLLOW, # Follow the Player
FORAGE, # Forage for Berries
SOLO,   # Use solo attack against enemies (not controlled by player) 
PLAYER,  # Use player-based abilities in the field (controlled by player)
FUSION  # Fusion with another Food Buddy
}


enum AttackDamage { SOLO = 10, ABILITY1 = 0, ABILITY2 = 0}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Health #
var health_current: int
var health_max: int
var alive: bool = true

# Speed #
var speed_normal: int = 50
var speed_current: int = speed_normal

# Field State #
var field_state_previous: FieldState
var field_state_current: FieldState
var target: Node2D = null
var target_distance: float


# Abilities #
var attack_damage: Dictionary = { "Solo": 10, "Ability1": 15, "Ability2": 20 }
var attack_range: Dictionary = { "Solo": 10, "Ability1": 15, "Ability2": 20 }

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
	field_state_current = FieldState.SOLO
	
	# Call the custom "ready()" function that Food Buddy subclasses will define individually
	ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
		
	# Call the custom "update()" function that Food Buddy subclasses will define individually
	process()


# Called every frame. Updates the Player's physics
func _physics_process(delta: float) -> void:
	
	# Determine if the Food Buddy is currently in the fighting field state, then execute their solo attack
	if field_state_current == FieldState.SOLO:
		use_solo_attack()
	
	# Adjust the Food Buddy's position based on its velocity
	move_and_slide()
	
	# Call the custom "physics_process()" function that Food Buddy subclasses will define individually
	physics_process(delta)


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# ABSTRACT FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# A custom ready function that each Food Buddy subclass should personally define. This is called in the default FoodBuddy class's '_ready()' function
func ready():
	pass



# A custom process function that each Food Buddy subclass should personally define. This is called in the default FoodBuddy class's '_process()' function
func process():
	pass



# A custom physics_process function that each Food Buddy subclass should personally define. This is called in the default FoodBuddy class's '_physics_process()' function
func physics_process(delta: float) -> void:
	pass


# Executes the logic for a Food Buddy's solo attack
func use_solo_attack():
	
	# Determine if the Food Buddy has a target Node2D currently, then move towards it. Otherwise, move the Food Buddy towards the Player and have them look for a new target.
	if target != null and target is Enemy and target.alive:
		move_towards_target.emit(self, target, 10)
	else:
		target_player.emit(self)
		move_towards_target.emit(self, target, 50)
		
		target_closest_enemy.emit(self)
		
		return
		
	# Determine if the Food Buddy is in range of an enemy, then make them stop moving and launch their solo attack
	if target_distance <= 30 and target is Enemy:
		velocity.x = 0
		velocity.y = 0
		use_ability_solo.emit(self, attack_damage["Solo"])



# A custom function to execute the Food Buddy's ability 1 that each Food Buddy subclass should personally define. This is called in the FoodBuddy class's "_on_player_use_ability_buddy()" callback function.
func use_ability1():
	# THIS CODE SHOULD BE MANUALLY WRITTEN FOR EACH FOOD BUDDY BECAUSE EVERY ABILITY WILL HAVE A DIFFERENT EXECUTION
	print("Food Buddy's Ability 1 has been triggered!")
	pass



# A custom function to execute the Food Buddy's ability 2 that each Food Buddy subclass should personally define. This is called in the FoodBuddy class's "_on_player_use_ability_buddy()" callback function.
func use_ability2():
	# THIS CODE SHOULD BE MANUALLY WRITTEN FOR EACH FOOD BUDDY BECAUSE EVERY ABILITY WILL HAVE A DIFFERENT EXECUTION
	print("Food Buddy's Ability 2 has been triggered!")
	pass



# A custom function to execute the Food Buddy's special attack that each Food Buddy subclass should personally define.
func use_special_attack():
	# THIS CODE SHOULD BE MANUALLY WRITTEN FOR EACH FOOD BUDDY BECAUSE EVERY ABILITY WILL HAVE A DIFFERENT EXECUTION
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# Updates the Food Buddy's current field state based on Player input
func update_field_state():
	

		if field_state_current == FieldState.FOLLOW:
			field_state_current = FieldState.SOLO
		
		elif field_state_current == FieldState.SOLO:
			field_state_current = FieldState.FOLLOW



# Callback function that executes whenever the Player equips a Food Buddy: updates the Food Buddy's fight style
func _on_player_equip_buddy(food_buddy: FoodBuddy) -> void:
	if self == food_buddy:
		if field_state_current != FieldState.PLAYER:
			field_state_current = FieldState.PLAYER
		else:
			field_state_current = FieldState.SOLO



# Callback function that executes whenever the Player equips a Food Buddy: updates the Food Buddy's fight style
func _on_player_equip_buddy_fusion() -> void:
	if field_state_current != FieldState.FUSION:
		field_state_current = FieldState.FUSION
	else:
		field_state_current = FieldState.SOLO


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
