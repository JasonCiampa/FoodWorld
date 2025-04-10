class_name FoodBuddy

extends InteractableCharacter



# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var navigation_agent: NavigationAgent2D
var path_generation_rate: float = 0.1

var timer_navigation: Timer
var timer_ability_cooldown: Timer
var timer_forage_cooldown: Timer
var timer_general: Timer

var closest_bush: Vector2i = Vector2i(-1, -1)
var recently_foraged_bushes: Dictionary

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

signal use_ability_solo

signal target_closest_enemy

signal find_nearest_bush
signal forage_bush
signal target_brittany
signal deposit_berries

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

enum AbilityType { ATTACK, TRAVERSAL, PUZZLE, HYBRID }


enum FieldState 
{ 
	FOLLOW, # Follow the Player
	FORAGE, # Forage for Berries
	FIGHT,   # Use solo attack against enemies (not controlled by player) 
	PLAYER, # Use player-based abilities in the field (controlled by player)
	FUSION  # Fusion with another Food Buddy
}

enum AnimationState
{
	IDLE,
	MOVING,
	ABILITY,
	DIE
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var health_texture_path: String
var select_circle_texture_path: String


var revive_time_total: int = 1000
var revive_time_remaining: int = revive_time_total

# Field State #
var field_state_previous: int
var field_state_current: int

var active: bool = true

# A dictionary of callback functions that should repeatedly execute while the Food Buddy is in a given FieldState (none for PLAYER or FUSION because those are user-controlled)
var field_state_callbacks: Dictionary = {
	FieldState.FOLLOW: follow_field_state_callback,
	FieldState.FORAGE: forage_field_state_callback,
	FieldState.FIGHT: fight_field_state_callback,
}

var current_animation_name: String
var current_direction_name: String
var new_animation_name: String
var new_direction_name
var animation_directions: Dictionary = {}


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

var using_ability: bool = false

var RNG: RandomNumberGenerator

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# Updates the variables that keep track of previous and current movement direction
func update_movement_direction():
	
	# Store the current horizontal and vertical directions as the previous directions.
	direction_previous_horizontal = direction_current_horizontal
	direction_previous_vertical = direction_current_vertical
	
	direction_current_horizontal = sign(velocity.x)
	direction_current_vertical = sign(velocity.y)
	
	# Determine whether the Food Buddy is facing left or right, then flip the sprite horizontally based on the direction the Food Buddy is facing
	if direction_current_horizontal == Direction.RIGHT:
		sprite.flip_h = true
	elif direction_current_horizontal == Direction.LEFT:
		sprite.flip_h = false



func update_animation():
	
	new_direction_name = animation_directions.get(Vector2(direction_current_horizontal, direction_current_vertical))
	
	if health_current <= 0:
		new_animation_name = "die"
	elif using_ability:
		new_animation_name = "ability"
	elif velocity.x == 0 and velocity.y == 0:
		new_animation_name = "idle"
	else:
		new_animation_name = "moving"
	
	if new_animation_name == "" or new_animation_name == null:
		new_animation_name = current_animation_name
	
	if new_direction_name == "" or new_direction_name == null:
		if current_direction_name != "":
			new_direction_name = current_direction_name
		else:
			new_direction_name = "front"
	
	# If the animation has changed, play the new animation
	if sprite.animation != (new_animation_name + "_" + new_direction_name):
		sprite.play(new_animation_name + "_" + new_direction_name) # --> idle_front
		current_animation_name = new_animation_name
		current_direction_name = new_direction_name

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	
	navigation_agent = $"NavigationAgent2D"
	
	timer_navigation = $"Navigation Timer"
	timer_ability_cooldown = $"Ability Cooldown Timer"
	timer_general = $"General Timer"
	timer_forage_cooldown = $"Forage Cooldown Timer"
	
	RNG = RandomNumberGenerator.new()
	# Set the Food Buddy's current field state to be forage (so that they don't move because it isn't coded yet, as of 1/22/25)
	field_state_current = FieldState.FORAGE
	
	self.name = "FoodBuddy"
	
	update_movement_direction()
	animation_directions.get_or_add(Vector2(Direction.IDLE, Direction.IDLE), "")
	animation_directions.get_or_add(Vector2(Direction.IDLE, Direction.UP), "back")
	animation_directions.get_or_add(Vector2(Direction.IDLE, Direction.DOWN), "front")
	animation_directions.get_or_add(Vector2(Direction.LEFT, Direction.IDLE), "sideways")
	animation_directions.get_or_add(Vector2(Direction.LEFT, Direction.UP), "sideways" if (abs(velocity.x) + 0.5 > abs(velocity.y)) else "back")
	animation_directions.get_or_add(Vector2(Direction.LEFT, Direction.DOWN), "sideways" if (abs(velocity.x) + 0.5 > abs(velocity.y)) else "front")
	animation_directions.get_or_add(Vector2(Direction.RIGHT, Direction.IDLE), "sideways")
	animation_directions.get_or_add(Vector2(Direction.RIGHT, Direction.UP), "sideways" if (abs(velocity.x) + 0.5 > abs(velocity.y)) else "back")
	animation_directions.get_or_add(Vector2(Direction.RIGHT, Direction.DOWN), "sideways" if (abs(velocity.x) + 0.5 > abs(velocity.y)) else "front")
	
	# Call the custom ready function that subclasses may have defined manually
	ready()
	
	timer_general.start(1)
	update_dimensions()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !active:
		return
	
	if timer_general.is_stopped():
		update_movement_direction()
		#update_animation()
		
		if !is_jumping and current_altitude > 0:
			on_platform = true
		else:
			on_platform = false
		
		if not paused:
			# Call the custom "update()" function that Food Buddy subclasses will define individually
			process(delta)



# Called every frame. Updates the Food Buddy's physics
func _physics_process(delta: float) -> void:
	if !active:
		return
	
	if timer_general.is_stopped():
		if not paused:
			# Determine if the Player is jumping, then process their jump and ignore movement input for the y-axis
			if is_jumping:
				jump_process(delta)
			
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


func generate_path(target_point: Vector2 = Vector2(-1, -1)):
	
	if timer_navigation.is_stopped():
		
		if target_point == Vector2(-1, -1):
			if target != null:
				target_point = target.global_position
			else:
				return
		
		# Set the Player as the Food Buddy's target, then move towards the
		navigation_agent.target_position = target_point
		
		var current_agent_position = global_position
		var next_path_position = navigation_agent.get_next_path_position()
		
		velocity = current_agent_position.direction_to(next_path_position) * speed_current
		target_distance = global_position.distance_to(target_point)
		
		
		timer_navigation.start(path_generation_rate)

# FieldState Callbacks #

# A callback function that should execute repeatedly while the Food Buddy is in the FOLLOW FieldState
func follow_field_state_callback() -> void:
	
	target_player.emit(self)
	
	if target.current_altitude == 0:
	
		generate_path()
		
		if target_distance <= float((radius_range + target.radius_range) / 2):
			velocity.x = 0
			velocity.y = 0
	else:
		velocity.x = 0
		velocity.y = 0


# A callback function that should execute repeatedly while the Food Buddy is in the FORAGE FieldState
func forage_field_state_callback() -> void:
	
	
	if berries == berries_max:
		target_brittany.emit(self)
		generate_path()
		
		if global_position.distance_squared_to(target.global_position) <= 144:
			velocity.x = 0
			velocity.y = 0
			deposit_berries.emit(self)
			
			if berries < berries_max:
				find_nearest_bush.emit(self)
	
	
	
	elif closest_bush == Vector2i(-1, -1):
		find_nearest_bush.emit(self)
		return
	
	generate_path(closest_bush)
	
	if global_position.distance_squared_to(closest_bush) <= 144:
		velocity.x = 0
		velocity.y = 0
		
		if berries < berries_max and timer_forage_cooldown.is_stopped():
			# Trigger forage animation LATER ON
			# Start timer for foraging
			recently_foraged_bushes.get_or_add(closest_bush, true)
			timer_forage_cooldown.start(1)
		
		elif timer_forage_cooldown.time_left < 0.1:
			timer_forage_cooldown.stop()
			forage_bush.emit(self)
			find_nearest_bush.emit(self)
			
			print(name, "'s berry count: ", berries, "/", berries_max)




# A callback function that should execute repeatedly while the Food Buddy is in the FIGHT FieldState
func fight_field_state_callback() -> void:
	
	# Determine if the Food Buddy has an alive target Enemy currently, then move towards it.
	if target != null and target is Enemy and target.alive:
		generate_path()
	
	# Otherwise, move the Food Buddy towards the Player while they look for a new target.
	else:
		
		target_closest_enemy.emit(self)
		
		if target == null or !target.alive:
			
			target_player.emit(self)
			
			if target.current_altitude != 0 or global_position.distance_to(target.global_position) <= target.radius_range:
				velocity.x = 0
				velocity.y = 0
				return

		
		generate_path()
	
	
	
	# Determine if the Food Buddy is in range of an Enemy, then make them stop moving and launch their solo attack
	if target is Enemy:
		
		if target_distance <= float((radius_range + target.radius_range) / 2):
			velocity.x = 0
			velocity.y = 0
			
			if timer_ability_cooldown.is_stopped() and !using_ability:
				using_ability = true
				current_animation_name = "ability"
				sprite.play("ability_" + current_direction_name)
				target_distance = global_position.distance_to(target.global_position)
				
		



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

func _on_sprite_animation_looped() -> void:
	
	update_animation()

func _on_sprite_animation_finished() -> void:
	
	if "ability" in sprite.animation:
		
		use_ability_solo.emit(self, ability_damage["Solo"])
		timer_ability_cooldown.start(0.5)
		using_ability = false
		sprite.play("idle_" + current_direction_name)
		current_animation_name = "idle"
	
	update_animation()
