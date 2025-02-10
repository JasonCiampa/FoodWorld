class_name Enemy

extends GameCharacter

# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

signal use_ability

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Abilities #
var ability1_damage: int = 10

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	# Relies on the Godot Functions defined in the parent GameCharacter class

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ABSTRACT FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# A custom ready function that each Enemy subclass should personally define. This is called in the GameCharacter class's '_ready()' function
func ready():
	pass



# A custom process function that each Enemy subclass should personally define. This is called in the GameCharacter class's '_process()' function
func process(_delta: float):
	use_solo_attack()
	update_dimensions()
	pass



# A custom physics_process function that each Enemy subclass should personally define. This is called in the GameCharacter class's '_physics_process()' function
func physics_process(_delta: float) -> void:
	move_and_slide()
	pass



# A custom function to execute the Enemy's ability 1 that each Enemy subclass should personally define. This is called in the Game script's "_on_player_use_ability_buddy()" callback function.
func use_ability1():
	# THIS CODE SHOULD BE MANUALLY WRITTEN FOR EACH ENEMY BECAUSE EVERY ABILITY WILL HAVE A DIFFERENT EXECUTION
	pass



# A custom function to execute the Enemy's ability 2 that each Enemy subclass should personally define. This is called in the Game script's "_on_player_use_ability_buddy()" callback function.
func use_ability2():
	# THIS CODE SHOULD BE MANUALLY WRITTEN FOR EACH ENEMY BECAUSE EVERY ABILITY WILL HAVE A DIFFERENT EXECUTION
	pass


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# THIS IS A TEST FUNCTION THAT WILL BE REMOVED. ENEMIES WILL HAVE AN ABILITY 1 AND SOMETIMES ABILITY 2 DEFINED, AND THOSE WILL BE LAUNCHED AS ATTACKS
# Executes the logic for a Enemy's solo attack
func use_solo_attack():
	
	# Determine if the Enemy has a target currently, then move towards them. Otherwise, have the Enemy look for a new target.
	if target != null and target.alive:
		move_towards_target.emit(self, target)
	else:
		#target_player.emit(self)
		#target_closest_food_buddy.emit(self)
		return
		
	# Determine if the Enemy is in range of the target, then make them stop moving and launch their solo attack
	if target_distance <= 30:
		velocity.x = 0
		velocity.y = 0
		use_ability.emit(self, ability1_damage)

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
