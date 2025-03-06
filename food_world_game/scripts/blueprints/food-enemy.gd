class_name Enemy

extends GameCharacter



# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var navigation_agent: NavigationAgent2D
var path_generation_rate: float = 0.1

var timer_navigation: Timer
var timer_ability_cooldown: Timer

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

signal use_ability

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

enum AbilityType { ATTACK, TRAVERSAL, PUZZLE, HYBRID }


enum FieldState 
{ 
	PASSIVE,
	AGGRESSIVE,
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var health_texture_path: String

# Field State #
var field_state_previous: int
var field_state_current: int

# A dictionary of callback functions that should repeatedly execute while the Enemy is in a given FieldState (none for PLAYER or FUSION because those are user-controlled)
var field_state_callbacks: Dictionary = {
	FieldState.PASSIVE: passive_field_state_callback,
	FieldState.AGGRESSIVE: aggressive_field_state_callback
}

# Abilities #
var ability_damage: Dictionary = { 
	"Ability1": 10, 
}

var ability_range: Dictionary = { 
	"Ability1": 15, 
}

# Inventory #
var inventory: Array = []
var inventory_size: int = 12

# XP #
var xp_drop: int = 50

var RNG: RandomNumberGenerator

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	
	navigation_agent = $"NavigationAgent2D"
	
	timer_navigation = $"Navigation Timer"
	timer_ability_cooldown = $"Ability Cooldown Timer"
	
	RNG = RandomNumberGenerator.new()
	
	# Generate a random number btwn 0 and 100 exclusive and if its even target the player by default, otherwise target the food buddies
	target_closest_food_buddy.emit(self)
	
	field_state_current = FieldState.PASSIVE
	
	radius_range = 15
	
	self.name = "Enemy"
	
	# Call the custom ready function that subclasses may have defined manually
	ready()
	
	update_dimensions()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if !is_jumping and current_altitude > 0:
		on_platform = true
	else:
		on_platform = false
	
	if target == null:
		
		# Generate a random number btwn 0 and 100 exclusive and if its even target the player by default, otherwise target the food buddies
		target_closest_food_buddy.emit(self)
	
	if global_position.distance_to(target.global_position) < 75:
		field_state_current = FieldState.AGGRESSIVE
	
	if not paused:
		# Call the custom "update()" function that Enemy subclasses will define individually
		process(delta)



# Called every frame. Updates the Enemy's physics
func _physics_process(delta: float) -> void:
	
	if not paused:
		# Determine if the Player is jumping, then process their jump and ignore movement input for the y-axis
		if is_jumping:
			jump_process(delta)
		
		# Determine if the Enemy is currently in a FieldState that isn't user-controlled, then execute the FieldState's corresponding callback function
		if field_state_current in field_state_callbacks.keys():
			field_state_callbacks[field_state_current].call()
		
		# Adjust the Enemy's position based on its velocity
		move_and_slide()
		
		# Call the custom "physics_process()" function that Enemy subclasses will define individually
		physics_process(delta)
	
	update_dimensions()

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ABSTRACT FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# A custom ready function that each Enemy subclass should personally define. This is called in the default FoodBuddy class's '_ready()' function
func ready():
	pass



# A custom process function that each Enemy subclass should personally define. This is called in the default FoodBuddy class's '_process()' function
func process(_delta: float):
	pass



# A custom physics_process function that each Enemy subclass should personally define. This is called in the default FoodBuddy class's '_physics_process()' function
func physics_process(_delta: float) -> void:
	pass


func generate_path():
	if timer_navigation.is_stopped() and target != null:
	
		# Set the Player as the Enemy's target, then move towards them
		
		if global_position.distance_to(target.global_position) > RNG.randi_range(radius_range - 10, radius_range - 5):
		
			navigation_agent.target_position = target.global_position
			
			var current_agent_position = global_position
			var next_path_position = navigation_agent.get_next_path_position()
			velocity = current_agent_position.direction_to(next_path_position) * speed_current
			
			target_distance = global_position.distance_to(target.global_position)
		
		else:
			velocity.x = 0
			velocity.y = 0
		
		timer_navigation.start(path_generation_rate)


# FieldState Callbacks #

# A callback function that should execute repeatedly while the Enemy is in the FOLLOW FieldState
func passive_field_state_callback() -> void:
	pass



# A callback function that should execute repeatedly while the Enemy is in the FORAGE FieldState
func aggressive_field_state_callback() -> void:
	
	# Determine if the Enemy is in range of an Enemy, then make them stop moving and launch their solo attack
	if target_distance <= target.radius_range:
		velocity.x = 0
		velocity.y = 0
		
		if timer_ability_cooldown.is_stopped():
			use_ability.emit(self, ability_damage["Ability1"])
			timer_ability_cooldown.start(0.5)
			target_distance = global_position.distance_to(target.global_position)
		
	else:
		generate_path()






# Ability Functions #

# A custom function to execute the Enemy's ability 1 that each Enemy subclass should personally define. This is called in the game.gd's "_on_player_use_ability_buddy()" callback function.
func use_ability1():
	# THIS CODE SHOULD BE MANUALLY WRITTEN FOR EACH FOOD BUDDY BECAUSE EVERY ABILITY WILL HAVE A DIFFERENT EXECUTION
	print(name + "'s Ability 1 has been triggered!")
	pass




#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
