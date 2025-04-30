class_name Enemy

extends GameCharacter



# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var navigation_agent: NavigationAgent2D
var path_generation_rate: float = 0.1

var frolic_range: float = 50
var frolic_cooldown_rate: float = 2.5

var timer_navigation: Timer
var timer_ability_cooldown: Timer
var timer_frolic_cooldown: Timer

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

var using_ability: bool = false

var previous_animation: String = "idle_front"
var previous_animation_frame: int = 0
var previous_animation_frame_progress: float = 0

var current_animation_name: String
var current_direction_name: String
var new_animation_name: String
var new_direction_name
var animation_directions: Dictionary = {}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	
	navigation_agent = $"NavigationAgent2D"
	
	timer_navigation = $"Navigation Timer"
	timer_ability_cooldown = $"Ability Cooldown Timer"
	timer_frolic_cooldown = $"Frolic Cooldown Timer"
	
	RNG = RandomNumberGenerator.new()
	
	# Generate a random number btwn 0 and 100 exclusive and if its even target the player by default, otherwise target the food buddies
	target_player.emit(self)
	
	field_state_current = FieldState.PASSIVE
	timer_frolic_cooldown.start(2.5)
	
	speed_normal = 35
	radius_range = 20
	
	self.name = "Enemy"
	
	update_movement_direction()
	sprite.play("idle_front")
	
	# Call the custom ready function that subclasses may have defined manually
	ready()
	
	update_dimensions()
	
	collision_values["GROUND"] = 10
	collision_values["MIDAIR"] = 11
	collision_values["PLATFORM"] = 12



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if target != null and animation_directions.size() == 0:
		animation_directions.get_or_add(Vector2(Direction.IDLE, Direction.IDLE), func(): return "")
		animation_directions.get_or_add(Vector2(Direction.IDLE, Direction.UP), func(): return "back")
		animation_directions.get_or_add(Vector2(Direction.IDLE, Direction.DOWN), func(): return "front")
		animation_directions.get_or_add(Vector2(Direction.LEFT, Direction.IDLE), func(): return "sideways")
		animation_directions.get_or_add(Vector2(Direction.LEFT, Direction.UP), func(): return ("back" if velocity.y < velocity.x else "sideways"))
		animation_directions.get_or_add(Vector2(Direction.LEFT, Direction.DOWN), func(): return ("front" if abs(velocity.y) > abs(velocity.x) else "sideways"))# if (abs(target.global_position.y - global_position.y) > abs(target.global_position.x - global_position.x)) else "sideways")
		animation_directions.get_or_add(Vector2(Direction.RIGHT, Direction.IDLE), func(): return ("sideways"))
		animation_directions.get_or_add(Vector2(Direction.RIGHT, Direction.UP), func(): return ("back" if abs(velocity.y) > abs(velocity.x) else "sideways"))#if (abs(target.global_position.y - global_position.y) > abs(target.global_position.x - global_position.x)) else "sideways")
		animation_directions.get_or_add(Vector2(Direction.RIGHT, Direction.DOWN), func(): return ("front" if velocity.y > velocity.x else "sideways")) #if (abs(target.global_position.y - global_position.y) > abs(target.global_position.x - global_position.x)) else "sideways")
	
	if !is_jumping and current_altitude > 0:
		on_platform = true
	else:
		on_platform = false
	
	if target == null or !target.active:
		
		target_player.emit(self)
	
	target_distance = global_position.distance_to(target.global_position)
	
	if target_distance < 100 and field_state_current == FieldState.PASSIVE:
		field_state_current = FieldState.AGGRESSIVE
		
	elif target_distance > 200 and field_state_current == FieldState.AGGRESSIVE:
		if target.name != "Brittany":
			field_state_current = FieldState.PASSIVE
	
	if not paused:
		
		update_movement_direction()
		
		if taking_damage:
			take_damage(delta)
		
		if healing_health:
			heal_health(delta)
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


func update_animation(animation_name: String = ""):
	
	if paused:
		sprite.play("idle_front")
		return
	
	if animation_name != "":
		sprite.play(animation_name)
		return
	
	new_direction_name = animation_directions.get(Vector2(direction_current_horizontal, direction_current_vertical))
	
	if new_direction_name != null:
		new_direction_name = new_direction_name.call()
	
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


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ABSTRACT FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# A custom ready function that each Enemy subclass should personally define. This is called in the default FoodBuddy class's '_ready()' function
func ready():
	time_between_tile_updates = randf_range(0.75, 0.8)



# A custom process function that each Enemy subclass should personally define. This is called in the default FoodBuddy class's '_process()' function
func process(_delta: float):
	pass
	#print(name, " is processing!")



# A custom physics_process function that each Enemy subclass should personally define. This is called in the default FoodBuddy class's '_physics_process()' function
func physics_process(_delta: float) -> void:
	pass


func generate_path(target_point: Vector2 = Vector2(-1, -1)):
	
	if target_point == Vector2(-1, -1):
		target_point = target.global_position
	
	
	if timer_navigation.is_stopped() and target != null:
		
		# Set the Player as the Enemy's target, then move towards them
		navigation_agent.target_position = target_point
		
		var current_agent_position = global_position
		var next_path_position = navigation_agent.get_next_path_position()
		velocity = current_agent_position.direction_to(next_path_position) * speed_current
		
		target_distance = global_position.distance_to(target_point)
		timer_navigation.start(path_generation_rate)


# FieldState Callbacks #

# A callback function that should execute repeatedly while the Enemy is in the FOLLOW FieldState
func passive_field_state_callback() -> void:
	
	if timer_frolic_cooldown.is_stopped():
		
		if global_position.distance_to(navigation_agent.target_position) <= 5:
			velocity.x = 0
			velocity.y = 0
			timer_frolic_cooldown.start(2.5)
		else:
			generate_path(navigation_agent.target_position)
		
	
	else:
		
		if timer_frolic_cooldown.time_left <= 0.1:
			
			generate_path(Vector2(global_position.x + (frolic_range * RNG.randf_range(-1, 1)), global_position.y + (frolic_range * RNG.randf_range(-1, 1))))
			timer_frolic_cooldown.stop()
		else:
			velocity.x = 0
			velocity.y = 0



# A callback function that should execute repeatedly while the Enemy is in the FORAGE FieldState
func aggressive_field_state_callback() -> void:
	
	if target == null or !target.alive:
		field_state_current = FieldState.PASSIVE
		velocity.x = 0
		velocity.y = 0
		target = null
		return
	
	# Determine if the Enemy is in range of an Enemy, then make them stop moving and launch their solo attack
	if target.hitbox_health in current_damage_hitbox.get_overlapping_areas():
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



func _on_tile_process_timer_timeout() -> void:
	process_tiles.emit(self)
	timer_process_tiles.start(time_between_tile_updates)

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


func _on_enemy_screen_entered() -> void:
	if !paused:
		process_mode = PROCESS_MODE_INHERIT


func _on_enemy_screen_exited() -> void:
	process_mode = PROCESS_MODE_DISABLED


func _on_sprite_animation_looped() -> void:
	if !paused:
		update_animation()

func _on_sprite_animation_finished() -> void:
	
	if !paused:
		if "ability" in sprite.animation:
			
			use_ability.emit(self, ability_damage["Ability1"])
			timer_ability_cooldown.start(0.5)
			using_ability = false
			
			if current_direction_name != null:
				sprite.play("idle_" + current_direction_name)
			else:
				sprite.play("idle_front")
			
			current_animation_name = "idle"
			
		update_animation()
