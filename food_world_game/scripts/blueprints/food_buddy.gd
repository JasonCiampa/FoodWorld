class_name FoodBuddy

extends Character



# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Hitboxes #
var hitbox_dialogue: Area2D

# Press 'E' To Interact Label #
var label_e_to_interact: Label

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

signal use_ability_solo

signal target_closest_enemy
signal killed_target

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

enum AbilityType { ATTACK, TRAVERSAL, PUZZLE, HYBRID }


enum FieldState 
{ 
FOLLOW, # Follow the Player
FORAGE, # Forage for Berries
SOLO,   # Use solo attack against enemies (not controlled by player) 
PLAYER, # Use player-based abilities in the field (controlled by player)
FUSION  # Fusion with another Food Buddy
}


enum AttackDamage { SOLO = 10, ABILITY1 = 0, ABILITY2 = 0}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# Field State #
var field_state_previous: FieldState
var field_state_current: FieldState


# Abilities #
var attack_damage: Dictionary = { "Solo": 10, "Ability1": 15, "Ability2": 20 }
var attack_range: Dictionary = { "Solo": 10, "Ability1": 15, "Ability2": 20 }


# Inventory #
var inventory: Array = []
var inventory_size: int = 12


# Level and XP #
var xp_current: int
var xp_max: int

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Store references to the Character's Nodes
	sprite = $AnimatedSprite2D
	animation_player = $AnimationPlayer
	on_screen_notifier = $VisibleOnScreenNotifier2D
	hitbox_damage = $"Damage Hitbox"
	hitbox_dialogue = $"Dialogue Hitbox"
	
	# Set the Food Buddy's current field state to be fighting
	field_state_current = FieldState.SOLO
	
	# Call the custom ready function that subclasses may have defined manually
	ready()
	
	update_center_point()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if not paused:
		# Call the custom "update()" function that Food Buddy subclasses will define individually
		process(delta)


# Called every frame. Updates the Player's physics
func _physics_process(delta: float) -> void:
	
	if not paused:
		
		# Determine if the Food Buddy is currently in the fighting field state, then execute their solo attack
		if field_state_current == FieldState.SOLO:
			use_solo_attack()
		
		# Adjust the Food Buddy's position based on its velocity
		move_and_slide()
		
		# Call the custom "physics_process()" function that Food Buddy subclasses will define individually
		physics_process(delta)
	
	update_center_point()


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# ABSTRACT FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# A custom ready function that each Food Buddy subclass should personally define. This is called in the default FoodBuddy class's '_ready()' function
func ready():
	pass



# A custom process function that each Food Buddy subclass should personally define. This is called in the default FoodBuddy class's '_process()' function
func process(delta: float):
	pass



# A custom physics_process function that each Food Buddy subclass should personally define. This is called in the default FoodBuddy class's '_physics_process()' function
func physics_process(delta: float) -> void:
	pass


# Executes the logic for a Food Buddy's solo attack
func use_solo_attack():
	
	# Determine if the Food Buddy has an alive target Enemy currently, then move towards it. Otherwise, move the Food Buddy towards the Player while they look for a new target.
	if target != null and target is Enemy and target.alive:
		move_towards_target.emit(self, target, 10)
	else:
		target_player.emit(self)
		move_towards_target.emit(self, target, 50)
		
		target_closest_enemy.emit(self)
		
		return
	
	# Determine if the Food Buddy is in range of an Enemy, then make them stop moving and launch their solo attack
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
