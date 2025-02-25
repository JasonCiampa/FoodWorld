class_name FoodBuddy

extends InteractableCharacter



# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var navigation_agent: NavigationAgent2D
var timer: Timer

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

signal use_ability_solo

signal target_closest_enemy

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

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var health_texture_path: String

# Field State #
var field_state_previous: int
var field_state_current: int

# A dictionary of callback functions that should repeatedly execute while the Food Buddy is in a given FieldState (none for PLAYER or FUSION because those are user-controlled)
var field_state_callbacks: Dictionary = {
	FieldState.FOLLOW: follow_field_state_callback,
	FieldState.FORAGE: forage_field_state_callback,
	FieldState.SOLO: solo_field_state_callback,
}

# Abilities #
var ability_damage: Dictionary = { 
	"Solo": 10, 
	"Ability1": 15, 
	"Ability2": 20 
}

var ability_range: Dictionary = { 
	"Solo": 10, 
	"Ability1": 15, 
	"Ability2": 20 
}

var ability_stamina_cost: Dictionary = { 
	"Ability 1": [5, "Gradual"], 
	"Ability 2": [10, "Gradual"] 
}


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
	super()
	
	navigation_agent = $"NavigationAgent2D"
	timer = $"Timer"
	
	# Set the Food Buddy's current field state to be forage (so that they don't move because it isn't coded yet, as of 1/22/25)
	field_state_current = FieldState.FORAGE
	
	self.name = "FoodBuddy"
	
	# Call the custom ready function that subclasses may have defined manually
	ready()
	
	update_dimensions()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if not paused:
		# Call the custom "update()" function that Food Buddy subclasses will define individually
		process(delta)



# Called every frame. Updates the Food Buddy's physics
func _physics_process(delta: float) -> void:
	
	if not paused:
		
		# Determine if the Food Buddy is currently in a FieldState that isn't user-controlled, then execute the FieldState's corresponding callback function
		if field_state_current in field_state_callbacks.keys():
			field_state_callbacks[field_state_current].call()
		
		# Adjust the Food Buddy's position based on its velocity
		move_and_slide()
		
		# Call the custom "physics_process()" function that Food Buddy subclasses will define individually
		physics_process(delta)
	
	update_dimensions()

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# A custom function to execute the Food Buddy's logic for when the Player interacts with them: Starts a conversation between this Food Buddy, the Player, and the other Food Buddy (if the other Food Buddy is in range).
func interact_with_player(player: Player, characters_in_range: Array[Node2D], _delta: float) -> Array[Node2D]:
	
	# Create a list to store all of the Characters involved in an interaction with the Player
	var characters_to_involve: Array[Node2D] = [player]
	
	# Check some sort of Game-Story-Tracking Variable to determine if any characters should be added to or removed from the list so that a specific Dialogue file can be be played at specific moments of the game
	# If location == SweetsWorldCandyCastle and "Link" in characters_in_range:
		# characters_to_involve.append(characters_in_range["Link"])
	
	#return characters_to_involve
	
	# Iterate over each Character that is in-range, and if they're a Food Buddy then add them as a Character to involve in the conversation
	for character in characters_in_range:
		if character is FoodBuddy:
			characters_to_involve.append(character)
	
	# Return the list of Characters that should be involved in the conversation
	return characters_to_involve

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ABSTRACT FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# A custom ready function that each Food Buddy subclass should personally define. This is called in the default FoodBuddy class's '_ready()' function
func ready():
	pass



# A custom process function that each Food Buddy subclass should personally define. This is called in the default FoodBuddy class's '_process()' function
func process(_delta: float):
	pass



# A custom physics_process function that each Food Buddy subclass should personally define. This is called in the default FoodBuddy class's '_physics_process()' function
func physics_process(_delta: float) -> void:
	pass



# FieldState Callbacks #

# A callback function that should execute repeatedly while the Food Buddy is in the FOLLOW FieldState
func follow_field_state_callback() -> void:
	
	if timer.is_stopped():
		
		# Set the Player as the Food Buddy's target, then move towards them
		target_player.emit(self)
		
		if global_position.distance_to(target.global_position) > 32:
		
			navigation_agent.target_position = target.global_position
			
			var current_agent_position = global_position
			var next_path_position = navigation_agent.get_next_path_position()
			velocity = current_agent_position.direction_to(next_path_position) * speed_current
			
			move_towards_target.emit(self, target)
		
		else:
			velocity.x = 0
			velocity.y = 0
		
		timer.start(0.1)




# A callback function that should execute repeatedly while the Food Buddy is in the FORAGE FieldState
func forage_field_state_callback() -> void:
	pass



# A callback function that should execute repeatedly while the Food Buddy is in the SOLO FieldState
func solo_field_state_callback() -> void:
	
	# Determine if the Food Buddy has an alive target Enemy currently, then move towards it.
	if target != null and target is Enemy and target.alive:
		move_towards_target.emit(self, target)
	
	# Otherwise, move the Food Buddy towards the Player while they look for a new target.
	else:
		target_player.emit(self)
		move_towards_target.emit(self, target)
		
		target_closest_enemy.emit(self)
		
		return
	
	# Determine if the Food Buddy is in range of an Enemy, then make them stop moving and launch their solo attack
	if target_distance <= 30 and target is Enemy:
		velocity.x = 0
		velocity.y = 0
		use_ability_solo.emit(self, ability_damage["Solo"])



# Ability Functions #

# A custom function to execute the Food Buddy's ability 1 that each Food Buddy subclass should personally define. This is called in the game.gd's "_on_player_use_ability_buddy()" callback function.
func use_ability1():
	# THIS CODE SHOULD BE MANUALLY WRITTEN FOR EACH FOOD BUDDY BECAUSE EVERY ABILITY WILL HAVE A DIFFERENT EXECUTION
	print(name + "'s Ability 1 has been triggered!")
	pass



# A custom function to execute the Food Buddy's ability 2 that each Food Buddy subclass should personally define. This is called in the game.gd's "_on_player_use_ability_buddy()" callback function.
func use_ability2():
	# THIS CODE SHOULD BE MANUALLY WRITTEN FOR EACH FOOD BUDDY BECAUSE EVERY ABILITY WILL HAVE A DIFFERENT EXECUTION
	print(name + "'s Ability 2 has been triggered!")
	pass



# A custom function to execute the Food Buddy's special attack that each Food Buddy subclass should personally define.
func use_special_attack():
	# THIS CODE SHOULD BE MANUALLY WRITTEN FOR EACH FOOD BUDDY BECAUSE EVERY ABILITY WILL HAVE A DIFFERENT EXECUTION
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
