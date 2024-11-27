class_name Player

extends Character

# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Timers #
@onready var dodge_timer: Timer = $"Timers/Dodge Timer"
@onready var dodge_cooldown_timer: Timer = $"Timers/Dodge Cooldown Timer"
@onready var stamina_regen_delay_timer: Timer = $"Timers/Stamina Regen Delay Timer"
@onready var timer: Timer = $Timers/Timer

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

signal toggle_buddy_equipped
signal toggle_buddy_fusion_equipped

signal toggle_field_state_interface
signal toggle_dialogue_interface

signal revert_buddy_field_state

signal use_ability_solo
signal use_ability_buddy
signal use_ability_buddy_fusion

signal interact
signal escape_menu

signal killed_target

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

enum Direction { IDLE = 0, UP = -1, DOWN = 1,  LEFT = -1, RIGHT = 1 }

enum FieldState 
{ 
SOLO,           # No Food Buddies equipped, can only use solo abilities (punch, kick, dropkick)
BUDDY1,         # Food Buddy 1 equipped, can use player-based abilities of the Food Buddy (differ dependent on the Food Buddy)
BUDDY2,         # Food Buddy 2 equipped, can use player-based abilities of the Food Buddy (differ dependent on the Food Buddy)
FUSION          # Food Buddy Fusion equipped, can use fusion-based abilities (differ dependent on the Food Buddy Fusion)
}


enum AttackKnockback { PUNCH = 25, KICK = 50}

enum Ability { PUNCH = 1, KICK = 2}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var is_interacting: bool = false

# Inventory #
var inventory: Array = []
var inventory_size: int = 12

# Level and XP #
var xp_current: int
var xp_max: int

# Stamina #
var stamina_previous: float = 0
var stamina_current: float = 100
var stamina_max: float = 100
var stamina_regen_rate: float = 25
var stamina_decreasing: bool = false
var stamina_increasing: bool = false
var stamina_regen_delay_active: bool = false
var stamina_just_ran_out: bool = false
var stamina_use: Dictionary = { "Sprint": 15, "Jump": 10, "Dodge": 30, "Punch": 5, "Kick": 10 }

# Speed #
var speed_sprinting: int = 125
var speed_dodging: int = 350

# Previous Frame Movement Direction #
var direction_previous_horizontal: float = 0
var direction_previous_vertical: float = 0

# Current Frame Movement Direction #
var direction_current_horizontal: float = 0
var direction_current_vertical: float = 0

# Sprinting #
var is_sprinting: bool

# Dodging #
var is_dodging: bool

# Field State #
var field_state_previous: FieldState = FieldState.SOLO
var field_state_current: FieldState = FieldState.SOLO
var attack_damage: Dictionary = { "Punch": 10, "Kick": 15 }

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	jump_timer = $"Timers/Jump Timer"
	shadow = $"Shadow"

	sprite.play("test")
	self.name = "Player"
	update_location_points()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
		
	if current_altitude < 0:
		on_platform = true
	else:
		on_platform = false
	
	toggle_food_buddy_field_state_interface()
	
	if not paused:
		process_ability_use()
		#update_movement_animation()
		update_movement_direction()
		update_stamina(delta)
		update_field_state()
		
		if Input.is_action_just_pressed("interact"):
			interact.emit()
	
	if Input.is_action_just_pressed("escape_menu"):
		escape_menu.emit()
	
	update_location_points()
	
	# DEBUG #
	if timer.time_left == 0:
		timer.start()
		#print(collision_value_current)
		#print("Center X: " + str(center_point.x))
		#print("Center Y: " + str(center_point.y))
		#print(" ")
		#print("Bottom X: " + str(position.x))
		#print("Bottom Y: " + str(position.y))
		#print(" ")
		#print("Tile X: " + str(current_tile_position.x))
		#print("Tile Y: " + str(current_tile_position.y))
		#print(" ")
		#print("Z-Index: " + str(z_index))
		#print("Velocity X: " + str(velocity.x))
		#print("Velocity Y: " + str(velocity.y))
		#print(" ")
		#print("Current Stamina: " + str(stamina_current))
		#print("Previous Stamina: " + str(stamina_previous))
		#print(" ")
		#print("Increasing: " + str(stamina_increasing))
		#print("Decreasing: " + str(stamina_decreasing))
		#print("Stamina Regen Delay: " + str(stamina_regen_delay_timer.time_left))
		#print(" ")
		#print("Current Health: " + str(health_current))
		#print(" ")
		#print("Jumping: " + str(is_jumping))
		#print("Jump Timer: " + str(jump_timer.time_left))
		#print("Jump Landing Height: " + str(jump_landing_height))
		#print("Falling: " + str(is_falling))
		#print("On Platform: " + str(on_platform))
		#print("Feet Disabled: " + str(feet_collider.disabled))
		#print("Body Disabled: " + str(body_collider.disabled))
		#print('Current Altitude: ', str(current_altitude))
		#print('Current Z-Index: ', str(z_index))
		#print("")

# Called every frame. Updates the Player's physics
func _physics_process(delta: float) -> void:
	
	if not paused:
		update_movement_velocity(delta)
		move_and_slide()
		#check_collide_and_push()

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# Starts the Player's sprint
func sprint_start(delta: float):
	is_sprinting = true
	speed_current = speed_sprinting
	use_stamina_gradually(stamina_use["Sprint"], delta)


# Ends the Player's sprint
func sprint_end():
	is_sprinting = false
	speed_current = speed_normal







# Starts the Player's dodge
func dodge_start():
	dodge_cooldown_timer.start()
	dodge_timer.start()
	is_dodging = true



# Process the Player's dodge (returns true if Player is dodging from an idle position, false if not)
func dodge_process(delta: float) -> bool:
	speed_current = speed_dodging
	use_stamina_gradually(stamina_use["Dodge"], delta)
	
	# Determine if the Player is not currently moving in any direction (idle)
	if (direction_current_horizontal == Direction.IDLE) and (direction_current_vertical == Direction.IDLE):
		
		# Determine if the Player is facing either the left or right, then have them dodge in that direction from an idle position
		if sprite.animation == "idle_sideways":
			if sprite.flip_h:
				velocity.x = calculate_velocity(Direction.LEFT)
			else:
				velocity.x = calculate_velocity(Direction.RIGHT)
		
		# Determine if the Player is facing forward or backward, then have them dodge in that direction from an idle position
		if sprite.animation == "idle_front":
			velocity.y = calculate_velocity(Direction.DOWN)
		elif sprite.animation == "idle_back":
			velocity.y = calculate_velocity(Direction.UP)
		
		# Return true to indicate that the Player was dodging from an idle position
		return true
	
	# Return false to indicate that the Player was dodging from an idle position
	return false

# Calculates the Player's current velocity based on their movement input.
func calculate_velocity(direction):
	return direction * speed_current



# Checks if a Player has used one of their abilities and processes their input to determine what signals to send and what values to update
func process_ability_use():
	var ability_number: int = 0
	
	# Determine if the Player left-clicked (ability 1) or right-clicked (ability 2) their mouse, then store the corresponding ability number in the variable
	if Input.is_action_just_pressed("ability1"):
		ability_number = 1
	elif Input.is_action_just_pressed("ability2"):
		ability_number = 2
	
	# Determine if an ability was used, then trigger the signal that will use the correct ability based on the Player's current FieldState
	if ability_number != 0:
		if field_state_current == FieldState.SOLO:
			if ability_number == 1:
				use_ability_solo.emit(attack_damage["Punch"])
				use_stamina(stamina_use["Punch"])
				print("The Player used their punch attack!")
			else:
				use_ability_solo.emit(attack_damage["Kick"])
				use_stamina(stamina_use["Kick"])
				print("The Player used their kick attack!")
			
		elif field_state_current == FieldState.BUDDY1:
			use_ability_buddy.emit(1, ability_number)
		
		elif field_state_current == FieldState.BUDDY2:
			use_ability_buddy.emit(2, ability_number)
		
		else:
			use_ability_buddy_fusion.emit(ability_number)



# CHECK OUT THIS LINK WHEN IT COMES TIME TO DO MOVEMENT WORK https://forum.godotengine.org/t/what-is-causing-my-collision2d-to-stick-to-each-others/1404
# Checks if the Player collided with a CharacterBody2D, and if so, pushes the CharacterBody2D with power determined by the Player's current speed
func check_collide_and_push():
	
	# Iterate for the number of collisions that occured after move_and_slide() was called
	for i in get_slide_collision_count():
		
		# Store references for the collision itself and the entity that was collided with
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# Determine if the entity who the collision occurred with was a RigidBody2D, then apply the push force
		if collider is CharacterBody2D:
			pass
			#collider.velocity.x = 50	<-- This works for CharacterBody2Ds
			#collider.apply_central_impulse(-collision.get_normal() * 2) <-- This works for RigidBody2Ds



# Updates the Player Sprite's animation depending on which direction the Player was/is traveling.
func update_movement_animation():
	
	# Determine if the Player is jumping, then trigger the jump animation
	if is_jumping:
		sprite.play("jump")
	
	
	# Determine if the Player is fully idle, then play the correct idle animation based on the direction that the Player was previously moving in
	elif direction_current_horizontal == Direction.IDLE and direction_current_vertical == Direction.IDLE:
		if direction_previous_horizontal == Direction.IDLE:
			if direction_previous_vertical == Direction.DOWN:
				sprite.play("idle_front")
			elif direction_previous_vertical == Direction.UP:
				sprite.play("idle_back")
		elif direction_previous_horizontal == Direction.LEFT or direction_previous_horizontal == Direction.RIGHT:
			sprite.play("idle_sideways")
	
	
	# Determine which direction the Player is moving, then play the correct 'running' animation based on the direction they're pursuing
	elif direction_current_vertical == Direction.UP:
		sprite.play("run_upward")
	elif direction_current_vertical == Direction.DOWN:
		sprite.play("run_downward")
	else:
		sprite.play("run_sideways")
		
		# Determine whether the Player is facing left or right, then flip the sprite horizontally based on the direction the Player is facing
		if direction_current_horizontal == Direction.RIGHT:
			sprite.flip_h = false
		elif direction_current_horizontal == Direction.LEFT:
			sprite.flip_h = true
	
	
	# Determine if the Player has stamina, then determine if they're performing any actions, then set the correct animation and animation speed based on the Player's action
	if stamina_current > 0:
		
		if Input.is_action_just_pressed("sprint"):
			animation_player.play("start_sprinting")
		elif Input.is_action_just_released("sprint"):
			animation_player.play("stop_sprinting")
		
		if is_sprinting:
			sprite.speed_scale = 1.5
		else:
			sprite.speed_scale = 1
		
		if Input.is_action_just_pressed("dodge") and (not dodge_timer.is_stopped()):
			sprite.play("dodge")
			
			# Determine if the Player is sprinting while they trigger the dodge, then play the sprinting-dodge animation
			if is_sprinting:
				animation_player.play("dodge_sprinting")
			else:
				animation_player.play("dodge")
	else:
		# Determine if the Player has run out of stamina this frame, then adjust the animations that are being played and their speed
		if stamina_just_ran_out:
			stamina_just_ran_out = false
			sprite.speed_scale = 1
			if Input.is_action_pressed("sprint"):
				animation_player.play("stop_sprinting")



# Updates the variables that keep track of previous and current movement direction
func update_movement_direction():
	
	# Store the current horizontal and vertical directions as the previous directions.
	direction_previous_horizontal = direction_current_horizontal
	direction_previous_vertical = direction_current_vertical
	
	# Update the current horizontal and vertical direction being inputted by the user
	direction_current_horizontal = Input.get_axis("move_left", "move_right")
	direction_current_vertical = Input.get_axis("move_up", "move_down")



# Updates the Player's velocity based on their actions, speed, and the direction they're currently moving in
func update_movement_velocity(delta):
	
	# Determine if the Player currently has stamina
	if stamina_current > 0:
		
		# Determine whether or not the Player is starting a jump, then trigger the jump
		if Input.is_action_just_pressed("jump") and (not is_jumping) and (not is_dodging):
			jump_start()
			use_stamina(stamina_use["Jump"])
		
		
		# Determine whether or not the Player is sprinting, then trigger the sprinting state
		if Input.is_action_pressed("sprint") and Input.is_action_pressed("move"):
			sprint_start(delta)
		else:
			sprint_end()
		
		
		# Determine whether or not the Player is starting a dodge, then trigger the dodge and it's cooldown
		if Input.is_action_just_pressed("dodge") and stamina_current > 0 and dodge_cooldown_timer.is_stopped() and (not is_jumping):
			dodge_start()
		
		# Determine whether or not the Player is currently dodging, then adjust their speed
		if not dodge_timer.is_stopped():
			
			# Process the dodge and determine if the Player dodged from an idle position, then return so that velocity isn't set back to 0 further below in this function
			if dodge_process(delta):
				return
			
		else:
			is_dodging = false
	
	# Otherwise, the Player doesn't have any stamina, so prevent them from dodging and sprinting (don't prevent jumping because the Player could be in the middle of one)
	else:
		speed_current = speed_normal
		is_sprinting = false
		is_dodging = false
	
	
	# Determine if the Player is moving horizontally, then adjust the x-velocity
	if direction_current_horizontal != Direction.IDLE:
		velocity.x = calculate_velocity(direction_current_horizontal)
	else:
		velocity.x = move_toward(velocity.x, 0, speed_current)
	
	# Determine if the Player is jumping, then process their jump and ignore movement input for the y-axis
	if is_jumping:
		jump_process(delta)
		
		if direction_current_vertical != Direction.IDLE:
			var position_shift = calculate_velocity(direction_current_vertical) * delta
			if direction_current_vertical == Direction.UP:
				position.y += position_shift
			else:
				position.y -= position_shift
			jump_landing_height += position_shift
	
	# Otherwise determine if the Player isn't falling, then see if they're moving vertically, then adjust the y-velocity
	elif !is_falling:
		
		if direction_current_vertical != Direction.IDLE:
			velocity.y = calculate_velocity(direction_current_vertical)
		else:
			velocity.y = move_toward(velocity.y, 0, speed_current)


# Updates the Player's current FieldState based on their key presses
func update_field_state():
	
	# Determine if the Player updated their FieldState
	if Input.is_action_just_pressed("update_field_state"):
		
		# Store the current FieldState as the previous one since the FieldState has been updated
		field_state_previous = field_state_current
		
		# Determine which FieldState the Player has now selected, then set the selection as the current FieldState, send a signal to the Game to update the corresponding Food Buddy, and trigger the correct animation
		if Input.is_action_just_pressed("toggle_buddy1_equipped"):
			field_state_current = FieldState.BUDDY1
			toggle_buddy_equipped.emit(1)
			sprite.play("field_state_buddy1")
			print("Player's FieldState has been updated to BUDDY1")
		
		elif Input.is_action_just_pressed("toggle_buddy2_equipped"):
			field_state_current = FieldState.BUDDY2
			toggle_buddy_equipped.emit(2)
			sprite.play("field_state_buddy2")
			print("Player's FieldState has been updated to BUDDY2")
		
		elif Input.is_action_just_pressed("toggle_buddy_fusion_equipped"):
			field_state_current = FieldState.FUSION
			toggle_buddy_fusion_equipped.emit()
			sprite.play("field_state_buddy_fusion")
			print("Player's FieldState has been updated to FUSION")
		
		# Determine if the Player is selecting the SOLO FieldState, then set the selection as the current FieldState
		if field_state_previous == field_state_current:
			field_state_current = FieldState.SOLO
			sprite.play("field_state_solo")
			print("Player's FieldState has been updated to SOLO")



# Toggles the Food Buddy FieldState Interface on/off
func toggle_food_buddy_field_state_interface():
	# Determine if the Player is trying to adjust the Food Buddy's FieldState and if they're NOT in the FUSION FieldState, then emit the signal to the Game to trigger the FieldState Interface (can't let Food Buddy Fusion FieldStates to become out of sync, so this menu is disabled until the Player is out of the FUSION FieldState)
	if Input.is_action_just_pressed("toggle_buddy_field_state"):
		toggle_field_state_interface.emit()

# Depletes the Player's current stamina instantly by the given stamina use amount.
func use_stamina(stamina_cost: int):
	if stamina_current >= stamina_cost:
		stamina_current -= stamina_cost
		stamina_decreasing = true
		stamina_increasing = false
		stamina_regen_delay_timer.stop()



# Depletes the Player's current stamina gradually over time by the given stamina use amount.
func use_stamina_gradually(stamina_cost: int, delta: float):
	if stamina_current > 0:
		stamina_current -= stamina_cost * delta
		stamina_decreasing = true
		stamina_increasing = false
		stamina_regen_delay_timer.stop()



# Updates the Player's stamina based on their input
func update_stamina(delta):
	
	# Intialize Stamina to NOT be decreasing
	stamina_decreasing = false
	
	# Determine if the Player didn't use any stamina during the delay and if the regeneration delay timer has finished, then set the Player's stamina to be increasing
	if (stamina_regen_delay_timer.time_left == 0) and (stamina_previous == stamina_current):
		stamina_increasing = true
		stamina_previous = 0
	
	# Determine if the Player is not using any stamina as it regenerates, then replenish stamina
	if stamina_increasing and (not stamina_decreasing):
		stamina_current += stamina_regen_rate * delta
	else:
		stamina_increasing = false
	
	# Determine if stamina exceeds the lower or upper limit, then reset stamina to be in-bounds
	if stamina_current > stamina_max:
		stamina_current = stamina_max
		stamina_increasing = false
	elif stamina_current <= 0 and stamina_regen_delay_timer.time_left == 0:
		stamina_current = 0
		stamina_just_ran_out = true
	
	# Determine if the Player doesn't have max stamina, if the regen timer is inactive, and if at least one of the following is true: Player ran out of stamina or Player not using stamina, then trigger stamina regeneration delay
	if (stamina_current < stamina_max) and (stamina_regen_delay_timer.time_left == 0) and (stamina_current <= 0 or (stamina_decreasing == false and stamina_increasing == false)):
		stamina_regen_delay_timer.start()
		stamina_previous = stamina_current



# Updates a stat chosen by the Player, increments level, resets current xp, refills hp, maybe increase max xp (harder to level up as you progress?)
func level_up():
	pass
