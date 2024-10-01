class_name FoodBuddy

extends CharacterBody2D


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

enum FieldState { FOLLOW, FIGHT, FORAGE }

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
var target: Node2D = null
var target_distance: float

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
	
	update_field_state()
	
	# Determine the Food Buddy's current field state, then alter their movement/attack behavior based on that field state
	if field_state_current == FieldState.FOLLOW:
		target_player.emit(self)
		move_towards_target.emit(self, target, 30)
	
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
	if target != null and target is Enemy:
		move_towards_target.emit(self, target, 10)
	else:
		target_player.emit(self)
		move_towards_target.emit(self, target, 30)
		target_closest_enemy.emit(self)
		return
		
	# Determine if the Food Buddy is in range of an enemy, then make them stop moving and launch their solo attack
	if target_distance <= 10 and target is Enemy:
		velocity.x = 0
		velocity.y = 0
		use_ability_solo.emit(self, ability_solo_damage)



# A custom function to execute the Food Buddy's ability 1 that each Food Buddy subclass should personally define. This is called in the FoodBuddy class's "_on_player_use_ability_buddy()" callback function.
func use_ability1():
	# THIS CODE SHOULD BE MANUALLY WRITTEN FOR EACH FOOD BUDDY BECAUSE EVERY ABILITY WILL HAVE A DIFFERENT EXECUTION
	pass



# A custom function to execute the Food Buddy's ability 2 that each Food Buddy subclass should personally define. This is called in the FoodBuddy class's "_on_player_use_ability_buddy()" callback function.
func use_ability2():
	# THIS CODE SHOULD BE MANUALLY WRITTEN FOR EACH FOOD BUDDY BECAUSE EVERY ABILITY WILL HAVE A DIFFERENT EXECUTION
	pass



# A custom function to execute the Food Buddy's special attack that each Food Buddy subclass should personally define.
func use_special_attack():
	# THIS CODE SHOULD BE MANUALLY WRITTEN FOR EACH FOOD BUDDY BECAUSE EVERY ABILITY WILL HAVE A DIFFERENT EXECUTION
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# Updates the Food Buddy's current field state based on Player input
func update_field_state():
	
	# Determine if the Food Buddy's field state was adjusted by the Player, then set the correct field state
	if Input.is_action_just_pressed("toggle_buddy_field_state"):
		if field_state_current == FieldState.FOLLOW:
			field_state_current = FieldState.FIGHT
		
		elif field_state_current == FieldState.FIGHT:
			field_state_current = FieldState.FOLLOW



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


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
