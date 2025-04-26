class_name Player

extends GameCharacter

# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Timers #
@onready var dodge_timer: Timer = $"Timers/Dodge Timer"
@onready var dodge_cooldown_timer: Timer = $"Timers/Dodge Cooldown Timer"
@onready var stamina_regen_delay_timer: Timer = $"Timers/Stamina Regen Delay Timer"
@onready var interaction_delay_timer: Timer = $"Timers/Interaction Delay Timer"
@onready var timer: Timer = $Timers/Timer
@onready var camera: Camera2D = $AnimatedSprite2D/Camera2D
@onready var fuse_sprite: AnimatedSprite2D = $"Fuse Sprite"


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

signal toggle_buddy_equipped
signal toggle_buddy_fusion_equipped
signal toggle_juicebox

signal toggle_field_state_interface
signal toggle_select_interface
signal toggle_berry_bot_interface

signal use_ability_solo
signal use_ability_buddy
signal use_ability_buddy_fusion

signal throw_juicebox

signal interact
signal escape_menu

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


enum FieldState 
{ 
	SOLO,           # No Food Buddies equipped, can only use solo abilities (punch, kick, dropkick)
	BUDDY1,         # Food Buddy 1 equipped, can use player-based abilities of the Food Buddy (differ dependent on the Food Buddy)
	BUDDY2,         # Food Buddy 2 equipped, can use player-based abilities of the Food Buddy (differ dependent on the Food Buddy)
	FUSION,         # Food Buddy Fusion equipped, can use fusion-based abilities (differ dependent on the Food Buddy Fusion)
	JUICE,          # Juicebox equipped and ready to throw (if player has juiceboxes)
}


enum AttackKnockback { 
	PUNCH = 25, 
	KICK = 50
}


enum Ability { 
	PUNCH = 1, 
	KICK = 2
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var tests_ran: bool = false

var level_up: bool = false

var equipping_buddy: bool = false

var clicked_this_frame: bool = false

# Timers #
var timers: Array[Timer]
var timers_paused: bool

# Behavior #
var is_interacting: bool = false

# Inventory #
var inventory: Array = []
var inventory_size: int = 12

# Level and XP #
var xp_current: int = 0
var xp_max: int = 50
var level_current: int = 1

var equipped_buddy: FoodBuddy

# Stamina #
var stamina_previous: float = 0
var stamina_current: float = 100
var stamina_max: float = 100
var stamina_regen_rate: float = 25
var stamina_decreasing: bool = false
var stamina_increasing: bool = false
var stamina_regen_delay_active: bool = false
var stamina_just_ran_out: bool = false
var stamina_use: Dictionary = { 
	"Sprint": 15, 
	"Jump": 10, 
	"Dodge": 30, 
	"Punch": 5, 
	"Kick": 10,
	"Juice Throw": 10,
	"Juice Throw Three": 30
}

# Speed #
var speed_sprinting: int = 75
var speed_normal_dan: int = 60
var speed_sprinting_dan: int = 85
var speed_dodging: int = 350

# Sprinting #
var is_sprinting: bool

# Dodging #
var is_dodging: bool

var using_ability: bool

var hand_punching: String = "left"

# Field State #
var field_state_previous: FieldState = FieldState.SOLO
var field_state_current: FieldState = FieldState.SOLO

# Juice #
var juiceboxes: int = 1
var juice: int = 5000
var juicebox_ready: bool = false

var juicebox_throw_coords
var throwing_juicebox

# Abilities #
var attack_damage: Dictionary = { 
	"Punch": 10, 
	"Kick": 15,
	"Juice Throw": -25,
}

var animation_directions: Dictionary = {}
var current_animation_name: String
var current_direction_name: String = "front"
var new_animation_name: String = "idle"
var new_direction_name

var previous_animation: String = "idle_front"
var previous_animation_frame: int = 0
var previous_animation_frame_progress: float = 0

var frame_counter: int = 0

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	
	toggle_juicebox.is_null()
	
	dialogue_texture = load("res://images/ui/png/dialogue-player.png")
	
	speed_normal = 50
	
	sprite.play("idle_front")
	
	collision_values["GROUND"] = 1
	collision_values["MIDAIR"] = 2
	collision_values["PLATFORM"] = 3
	
	radius_range = 35
	
	self.name = "Player"
	body_collider.disabled = true
	feet_collider.disabled = false
	update_dimensions()
	set_collision_value(collision_values["GROUND"])
	
	timers.append(dodge_timer)
	timers.append(dodge_cooldown_timer)
	timers.append(stamina_regen_delay_timer)
	timers.append(timer)
	timers.append(interaction_delay_timer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if animation_directions.size() == 0:
		animation_directions.get_or_add(Vector2(Direction.IDLE, Direction.IDLE), func(): return "")
		animation_directions.get_or_add(Vector2(Direction.IDLE, Direction.UP), func(): return "back")
		animation_directions.get_or_add(Vector2(Direction.IDLE, Direction.DOWN), func(): return "front")
		animation_directions.get_or_add(Vector2(Direction.LEFT, Direction.IDLE), func(): return "sideways")
		animation_directions.get_or_add(Vector2(Direction.LEFT, Direction.UP), func(): return "back")
		animation_directions.get_or_add(Vector2(Direction.LEFT, Direction.DOWN), func(): return "front")	# if (abs(target.global_position.y - global_position.y) > abs(target.global_position.x - global_position.x)) else "sideways")
		animation_directions.get_or_add(Vector2(Direction.RIGHT, Direction.IDLE), func(): return ("sideways"))
		animation_directions.get_or_add(Vector2(Direction.RIGHT, Direction.UP), func(): return "back")#if (abs(target.global_position.y - global_position.y) > abs(target.global_position.x - global_position.x)) else "sideways")
		animation_directions.get_or_add(Vector2(Direction.RIGHT, Direction.DOWN), func(): return "front") #if (abs(target.global_position.y - global_position.y) > abs(target.global_position.x - global_position.x)) else "sideways")
	
	## ENABLE/DISABLE THIS IF STATEMENT TO TOGGLE THE PLAYER'S TEST FUNCTION
	#if !tests_ran:
		#test(delta)
		#return
	
	# DEATH TRIGGER
	#if Input.is_key_pressed(KEY_0):
		#die.emit(self)
	
	if Input.is_action_just_pressed("scroll_down"):
		camera.zoom.x -= 10 * delta
		camera.zoom.y -= 10 * delta
		
		if camera.zoom.x < 2.5:
			camera.zoom.x = 2.5
			camera.zoom.y = 2.5
		
	elif Input.is_action_just_pressed("scroll_up"):
		camera.zoom.x += 10 * delta
		camera.zoom.y += 10 * delta
		
		if camera.zoom.x > 7:
			camera.zoom.x = 7
			camera.zoom.y = 7
		
	
	if !is_jumping and current_altitude > 0:
		on_platform = true
	else:
		on_platform = false
	
	toggle_food_buddy_field_state_interface()
	toggle_food_buddy_selection_interface()
	toggle_brittany_berry_bot_interface()
	
	if not paused:
		
		if !equipping_buddy and (field_state_current == FieldState.BUDDY1 or field_state_current == FieldState.BUDDY2):
			equipped_buddy.global_position = global_position
		
		if taking_damage:
			take_damage(delta)
			
			if equipped_buddy != null and (field_state_current == FieldState.BUDDY1 or field_state_current == FieldState.BUDDY2):
				equipped_buddy.self_modulate = self_modulate
		
		elif healing_health:
			heal_health(delta)
			
			if equipped_buddy != null and (field_state_current == FieldState.BUDDY1 or field_state_current == FieldState.BUDDY2):
				equipped_buddy.self_modulate = self_modulate
		
		else:
			self_modulate = Color(1, 1, 1, 1)
		
		
		
		if timers_paused:
			timers_paused = false
			for game_timer in timers:
				game_timer.paused = false
		
		
		process_ability_use(delta)
		update_movement_direction()
		update_animation()
		update_stamina(delta)
		update_field_state()
		
		if !is_interacting and Input.is_action_pressed("interact"):
			interact.emit(delta)
	else:
		if !timers_paused:
			timers_paused = true
			for game_timer in timers:
				game_timer.paused = true
	
	if Input.is_action_just_pressed("escape_menu"):
		escape_menu.emit()
	
	clicked_this_frame = false
	
	update_dimensions()

	# DEBUG #
	if timer.time_left == 0:
		timer.start()
		#print(using_ability)
		#print(name)
		#print("Berries Current: ", berries)
		#print(collision_value_current)
		#print("Bottom X: " + str(global_position.x))
		#print("Bottom Y: " + str(global_position.y))
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
		#print('Current Collision Value: ', str(collision_value_current))
		#print("")
		#print("Camera Zoom X: ", camera.zoom.x)
		#print("Camera Zoom Y: ", camera.zoom.y)


# Called every frame. Updates the Player's physics
func _physics_process(delta: float) -> void:
	
	if not paused:
		update_movement_velocity(delta)
		move_and_slide()
		#check_collide_and_push()

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

func update_animation(animation_name: String = ""):
	
	if animation_name != "":
		sprite.play(animation_name)
		return
	
	new_direction_name = animation_directions.get(Vector2(direction_current_horizontal, direction_current_vertical))
	
	if new_direction_name != null:
		new_direction_name = new_direction_name.call()
	
	if using_ability:
		new_animation_name = "ability"
	elif health_current <= 0:
		new_animation_name = "die"
	elif direction_current_horizontal == 0 and direction_current_vertical == 0:
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
	
	var fusion_name: String = ""
	
	if paused or level_up:
		new_animation_name = "idle"
		new_direction_name = "front"
	
	if is_sprinting:
		sprite.speed_scale = 1.5
	else:
		sprite.speed_scale = 1
	
	if (field_state_current == FieldState.BUDDY1 or field_state_current == FieldState.BUDDY2):
		if equipped_buddy != null and equipped_buddy.name == "Dan":
			
			equipped_buddy.global_position = global_position
			equipped_buddy.sprite.flip_h = sprite.flip_h
			equipped_buddy.sprite.speed_scale = sprite.speed_scale
			
			if is_sprinting:
				equipped_buddy.using_ability = true
				equipped_buddy.update_animation("ability_" + new_direction_name)
			else:
				equipped_buddy.using_ability = false
				equipped_buddy.update_animation(new_animation_name + "_" + new_direction_name)
			
			
			if juicebox_ready:
				new_animation_name = "juice_" + new_animation_name
				
				if throwing_juicebox:
					new_animation_name = new_animation_name + "_throw"
			
			
			if equipped_buddy.sprite.animation in equipped_buddy.animation_callbacks.keys():
				equipped_buddy.animation_callbacks.get(equipped_buddy.sprite.animation).call()
		
		elif (animation_player.current_animation_position > 0.3 or animation_player.current_animation != "fuse"):
			fusion_name = "player_" + equipped_buddy.name.to_lower() + "_"
	
	elif field_state_current == FieldState.JUICE:
		
		if throwing_juicebox:
			new_animation_name = "juice_" + new_animation_name + "_throw"
		else:
			new_animation_name = "juice_" + new_animation_name
	
	# If the animation has changed, play the new animation
	if sprite.animation != (fusion_name + new_animation_name + "_" + new_direction_name) or paused or level_up:
		previous_animation_frame = sprite.get_frame()
		previous_animation_frame_progress = sprite.get_frame_progress()
		
		if paused or level_up:
			sprite.play(fusion_name + new_animation_name + "_" + new_direction_name)
			return
		
		# Only play if the ability is not already launched in a different direction
		if using_ability:
			sprite.play(fusion_name + new_animation_name + "_" + new_direction_name + "_" + hand_punching)
			sprite.set_frame_and_progress(previous_animation_frame, previous_animation_frame_progress)
		
		elif throwing_juicebox:
			sprite.play(fusion_name + new_animation_name + "_" + new_direction_name)
			sprite.set_frame_and_progress(previous_animation_frame, previous_animation_frame_progress)
		
		else:
			sprite.play(fusion_name + new_animation_name + "_" + new_direction_name) # --> formats like: idle_front
		
		
		current_animation_name = new_animation_name
		current_direction_name = new_direction_name
		
		new_animation_name = ""
		new_direction_name = ""

# Starts the Player's sprint
func sprint_start():
	is_sprinting = true
	
	if equipped_buddy != null and equipped_buddy.name == "Dan":
		speed_current = speed_sprinting_dan
	else:
		speed_current = speed_sprinting


# Ends the Player's sprint
func sprint_end():
	is_sprinting = false
	
	if equipped_buddy != null and equipped_buddy.name == "Dan":
		speed_current = speed_normal_dan
	else:
		speed_current = speed_normal



# Starts the Player's dodge
func dodge_start():
	if !is_jumping:
		dodge_cooldown_timer.start()
		dodge_timer.start()
		is_dodging = true



# Process the Player's dodge (returns true if Player is dodging from an idle position, false if not)
func dodge_process(delta: float) -> bool:
	
	if use_stamina_gradually(stamina_use["Dodge"], delta):
		speed_current = speed_dodging
	# Determine if the Player is not currently moving in any direction (idle)
	if (direction_current_horizontal == Direction.IDLE) and (direction_current_vertical == Direction.IDLE):
		
		# Determine if the Player is facing either the left or right, then have them dodge in that direction from an idle position
		if sprite.animation == "idle_sideways":
			if sprite.flip_h:
				velocity.x = calculate_velocity(Direction.LEFT)
			else:
				velocity.x = calculate_velocity(Direction.RIGHT)
		else:
			velocity.x = calculate_velocity(Direction.RIGHT)
		
		# Determine if the Player is facing forward or backward, then have them dodge in that direction from an idle position
		if sprite.animation == "idle_front":
			velocity.y = calculate_velocity(Direction.DOWN)
		elif sprite.animation == "idle_back":
			velocity.y = calculate_velocity(Direction.UP)
		
		else:
			velocity.y = calculate_velocity(Direction.UP)
		
		# Return true to indicate that the Player was dodging from an idle position
		return true
	
	# Return false to indicate that the Player was dodging from an idle position
	return false


func jump_start():
	if !is_dodging:
		super()
		
		# Set the Player to be in midair
		set_collision_value(collision_values["MIDAIR"])


func jump_end():
	super()
	
	sprite.play("idle_" + current_direction_name)
	
	if current_altitude == 0:
		set_collision_value(collision_values["GROUND"])
		on_platform = false
	else:
		set_collision_value(collision_values["PLATFORM"])
		on_platform = true


# Calculates the Player's current velocity based on their movement input.
func calculate_velocity(direction):
	return direction * speed_current



# Checks if a Player has used one of their abilities and processes their input to determine what signals to send and what values to update
func process_ability_use(delta: float) -> int:
	var ability_number: int = 0
	
	if clicked_this_frame:
		return -1
	
	# Determine if the Player left-clicked (ability 1) or right-clicked (ability 2) their mouse, then store the corresponding ability number in the variable
	if Input.is_action_just_pressed("ability1") or Input.is_action_just_pressed("throw_juicebox"):
		ability_number = 1
	elif Input.is_action_just_pressed("ability2") or Input.is_action_just_pressed("throw_three_juiceboxes"):
		ability_number = 2
	
	# Determine if an ability was used, then trigger the signal that will use the correct ability based on the Player's current FieldState
	if ability_number != 0:
		
		# Determine if the Player is using a solo attack, then launch the correct attack
		if field_state_current == FieldState.SOLO:
			if !using_ability:
				if use_stamina(stamina_use["Punch"]):
					
					using_ability = true 
					
					if ability_number == 1:
						hand_punching = "left"
					else:
						hand_punching = "right"
					
				
					update_animation()
					print("The Player threw a " + hand_punching + " punch!")
		
		
		elif field_state_current == FieldState.JUICE or juicebox_ready:
			if !throwing_juicebox:
				if ability_number >= 1 and juiceboxes > 0:
					if use_stamina(stamina_use["Juice Throw"]):
						print("The Player threw a juicebox!")
						throwing_juicebox = true
						juicebox_throw_coords = get_global_mouse_position()
		
		
		# Otherwise, determine if the Player is using their first Food Buddy's ability, then launch the correct ability
		elif field_state_current == FieldState.BUDDY1:
			use_ability_buddy.emit(1, ability_number, delta)
		
		# Otherwise, determine if the Player is using their second Food Buddy's ability, then launch the correct ability
		elif field_state_current == FieldState.BUDDY2:
			use_ability_buddy.emit(2, ability_number, delta)
		
		# Otherwise, the Player is using their Food Buddy's Fusion ability, so launch the correct ability
		else:
			use_ability_buddy_fusion.emit(ability_number)
	
	return ability_number




# Updates the variables that keep track of previous and current movement direction
func update_movement_direction():
	
	# Store the current horizontal and vertical directions as the previous directions.
	direction_previous_horizontal = direction_current_horizontal
	direction_previous_vertical = direction_current_vertical
	
	# Update the current horizontal and vertical direction being inputted by the user
	direction_current_horizontal = Input.get_axis("move_left", "move_right")
	direction_current_vertical = Input.get_axis("move_up", "move_down")
	
	# Determine whether the Player is facing left or right, then flip the sprite horizontally based on the direction the Player is facing
	if direction_current_horizontal == Direction.RIGHT:
		sprite.flip_h = true
	elif direction_current_horizontal == Direction.LEFT:
		sprite.flip_h = false



# Updates the Player's velocity based on their actions, speed, and the direction they're currently moving in
func update_movement_velocity(delta):
	
	
	if equipping_buddy or (using_ability and equipped_buddy != null and equipped_buddy.name != "Dan"):
		velocity.x = 0
		velocity.y = 0
		return
	
	# Determine if the Player currently has stamina
	if stamina_current > 0:
		
		## Determine whether or not the Player is starting a jump, then trigger the jump
		#if !throwing_juicebox and !using_ability and jump_enabled and Input.is_action_just_pressed("jump") and (not is_jumping) and (not is_dodging):
			#
			#if use_stamina(stamina_use["Jump"]):
				#jump_start()
		
		# Determine whether or not the Player is sprinting, then trigger the sprinting state
		if Input.is_action_pressed("sprint") and Input.is_action_pressed("move"):
			if use_stamina_gradually(stamina_use["Sprint"], delta):
				sprint_start()
		else:
			sprint_end()
		
		
		## Determine whether or not the Player is starting a dodge, then trigger the dodge and it's cooldown
		#if Input.is_action_just_pressed("dodge") and stamina_current > 0 and dodge_cooldown_timer.is_stopped() and (not is_jumping):
			#dodge_start()
		#
		## Determine whether or not the Player is currently dodging, then adjust their speed
		#if not dodge_timer.is_stopped():
			#
			## Process the dodge and determine if the Player dodged from an idle position, then return so that velocity isn't set back to 0 further below in this function
			#if dodge_process(delta):
				#return
			#
		#else:
			#is_dodging = false
	
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
			
			# Calculate the amount that the Player's position shifted vertically
			var position_shift = calculate_velocity(direction_current_vertical) * delta
			
			if direction_current_vertical == Direction.UP:
				global_position.y += position_shift
				shadow.global_position.y -= position_shift
			else:
				global_position.y -= position_shift
				shadow.global_position.y += position_shift
			
			jump_landing_height += position_shift
	
	# Otherwise determine if the Player isn't falling, then see if they're moving vertically, then adjust the y-velocity
	elif !is_falling:
		
		if direction_current_vertical != Direction.IDLE:
			velocity.y = calculate_velocity(direction_current_vertical)
		else:
			velocity.y = move_toward(velocity.y, 0, speed_current)
	
	# Determine if the Player isn't jumping and if the shadow hasn't already been reset to the correct global position
	if !is_jumping and shadow.global_position.y != global_position.y:
		shadow.global_position.y = global_position.y	# (I tried to put this line of code at the end of the 'jump_end' function in GameCharacter.gd, but it wouldn't always reset the shadow to the appropriate location when the code was there. It works fine here for whatever reason as of (1/25/25)


# Updates the Player's current FieldState based on their key presses
func update_field_state():
	
	# Determine if the Player updated their FieldState
	if Input.is_action_just_pressed("update_field_state"):
		
		# Store the current FieldState as the previous one since the FieldState has been updated
		field_state_previous = field_state_current
		
		# Determine which FieldState the Player has now selected, then set the selection as the current FieldState, send a signal to the Game to update the corresponding Food Buddy, and trigger the correct animation
		if !equipping_buddy and Input.is_action_just_pressed("toggle_buddy1_equipped"):
			equipping_buddy = true
			is_interacting = true
			toggle_buddy_equipped.emit(1)
		
		elif !equipping_buddy and Input.is_action_just_pressed("toggle_buddy2_equipped"):
			equipping_buddy = true
			is_interacting = true
			toggle_buddy_equipped.emit(2)
		
		elif Input.is_action_just_pressed("toggle_buddy_fusion_equipped"):
			field_state_current = FieldState.FUSION
			toggle_buddy_fusion_equipped.emit()
			sprite.play("field_state_buddy_fusion")
			print("Player's FieldState has been updated to FUSION")
		
		
		elif Input.is_action_just_pressed("toggle_juicebox") and field_state_current == FieldState.SOLO or (field_state_current == FieldState.JUICE or (equipped_buddy != null and equipped_buddy.name == "Dan")):
			
			if juicebox_ready:
				juicebox_ready = false
				return
			
			if !using_ability and !throwing_juicebox and juiceboxes > 0:
				
				if field_state_current == FieldState.BUDDY1 or field_state_current == FieldState.BUDDY2:
					juicebox_ready = true
					return
				
				field_state_current = FieldState.JUICE
				
				print("Player's FieldState has been updated to JUICE")
		
				# Determine if the Player is selecting the SOLO FieldState, then set the selection as the current FieldState
				if field_state_previous == field_state_current:
					field_state_current = FieldState.SOLO
					print("Player's FieldState has been updated to SOLO")



# Toggles the Food Buddy FieldState Interface on/off
func toggle_food_buddy_field_state_interface():
	
	# Determine if the Player is trying to adjust the Food Buddy's FieldState
	if Input.is_action_just_pressed("toggle_buddy_field_state"):
		
		toggle_field_state_interface.emit()



# Toggles the Food Buddy Selection Interface on/off
func toggle_food_buddy_selection_interface():
	
	# If 'TAB' is pressed, end the selecting of Food Buddies
	if Input.is_action_just_pressed("toggle_buddy_selection"):
		toggle_select_interface.emit()



# Toggles the Food Buddy Selection Interface on/off
func toggle_brittany_berry_bot_interface():
	
	# If 'TAB' is pressed, end the selecting of Food Buddies
	if Input.is_action_just_pressed("toggle_berry_bot"):
		toggle_berry_bot_interface.emit()



# Depletes the Player's current stamina instantly by the given stamina use amount.
func use_stamina(stamina_cost: int) -> bool:
	
	if stamina_current >= stamina_cost:
		stamina_current -= stamina_cost
		stamina_decreasing = true
		stamina_increasing = false
		stamina_regen_delay_timer.stop()
		
		return true
	
	return false



# Depletes the Player's current stamina gradually over time by the given stamina use amount.
func use_stamina_gradually(stamina_cost: int, delta: float) -> bool:
	if stamina_current > 0:
		stamina_current -= stamina_cost * delta
		stamina_decreasing = true
		stamina_increasing = false
		stamina_regen_delay_timer.stop()
		
		return true
	
	return false



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




# Tests all of the functionality of the Player
func test(delta: float):
	
	print("{ PLAYER MOVEMENT TESTS }\n")
	
	# SPRINT TESTS # -------------------------------------------------------------------------------------------------------------------------------------------------- #
	
	# Triggers a simulated sprint to allow for start/during sprint testing #
	Input.action_press("sprint")
	Input.action_press("move")
	
	sprint_start()
	update_animation()
	update_movement_velocity(delta)
	
	print("[Sprinting Test] Sprinting Speed is Current Speed:  ", speed_sprinting == speed_current)
	print("[Sprinting Test] Camera Zoom Out on Sprint Start:   ", animation_player.assigned_animation == "start_sprinting")
	print("[Sprinting Test] Sprite Speeds Up on Sprint Start:  ", sprite.speed_scale > 1)
	print("[Sprinting Test] Stamina Depleting on Sprint Start: ", stamina_decreasing)
	
	
	# Triggers the end of the simulated sprint to allow for stopping/stopped sprint testing #
	Input.action_release("sprint")
	Input.action_release("move")
	
	sprint_end()
	update_animation()
	update_stamina(delta)

	print("[Sprinting Test] Normal Speed is Current Speed:     ", speed_normal == speed_current)
	print("[Sprinting Test] Camera Zoom In on Sprint End:      ", animation_player.assigned_animation == "stop_sprinting")
	print("[Sprinting Test] Sprite Speeds Down on Sprint End:  ", sprite.speed_scale == 1)
	print("[Sprinting Test] Stamina Stops Depleting on Sprint: ", !stamina_decreasing)
	
	
	print("")
	# ----------------------------------------------------------------------------------------------------------------------------------------------------------------- #
	
	
	# DODGE TESTS # --------------------------------------------------------------------------------------------------------------------------------------------------- #
	
	# Triggers a simulated sprint to allow for start/during sprint testing #
	Input.action_press("dodge")
	Input.action_press("move")
	
	jump_start()
	dodge_start()
	print("[Dodging Test] Dodge Prevented If Already Jumping:  ", !is_dodging)
	jump_end()
	
	dodge_start()
	dodge_process(delta)
	print("[Dodging Test] Dodging Triggers Velocity Update:    ", velocity.x != 0 or velocity.y != 0)
	
	jump_start()
	update_animation()
	update_movement_velocity(delta)
	
	print("[Dodging Test] Camera Zoom In/Out Effect on Dodge:  ", animation_player.assigned_animation == "dodge")
	print("[Dodging Test] Stamina Depleting Throughout Dodge:  ", stamina_decreasing)
	
	velocity = Vector2(0, 0)
	
	print("")
	# ----------------------------------------------------------------------------------------------------------------------------------------------------------------- #
	
	
	# JUMP TESTS # ----------------------------------------------------------------------------------------------------------------------------------------------------  #

	Input.action_press("dodge")
	Input.action_press("jump")
	update_movement_velocity(delta)
	
	print("[Jumping Test] Jump Prevented If Already Dodging:   ", !is_jumping)
	
	Input.action_press("jump")
	update_movement_velocity(delta)
	
	print("[Jumping Test] Jump Propels Character Into Air:     ", velocity.y < 0)
	print("[Jumping Test] Stamina Reduces Instantly on Jump:   ", stamina_current + stamina_use["Jump"] <= 100)
	
	velocity = Vector2(0, 0)
	
	print("")
	
	# ----------------------------------------------------------------------------------------------------------------------------------------------------------------- #
	
	# STAMINA TESTS # ------------------------------------------------------------------------------------------------------------------------------------------------- #
	
	stamina_current = 100
	use_stamina(10)
	print("[Stamina Test] Stamina Can Be Used Immediately:     ", stamina_current + 10 <= 100)
	
	stamina_current = 100
	use_stamina_gradually(10, delta)
	print("[Stamina Test] Stamina Can Be Used Gradually:       ", stamina_current + 10 > 100)
	print("[Stamina Test] Stamina Delays Before Regenerating:  ", stamina_regen_delay_timer.is_stopped())
	
	stamina_current = 0
	use_stamina(10)
	use_stamina_gradually(10, delta)
	print("[Stamina Test] Stamina Use Blocked When Not Enough: ", stamina_current == 0)
	
	
	# ----------------------------------------------------------------------------------------------------------------------------------------------------------------- #
	
	print("\n\n\n{ PLAYER ABILITY TESTS }\n")
	
	# PLAYER SOLO ABILITY TESTS # ------------------------------------------------------------------------------------------------------------------------------------- #
	
	stamina_current = 100
	field_state_current = FieldState.SOLO
	Input.action_press("ability2")
	print("[Ability Test] Player Ability 2 On Right-Click:     ", process_ability_use(delta) == 2)
	print("[Ability Test] Player Ability 2 Depletes Stamina:   ", stamina_current < 100)
	Input.action_release("ability2")
	
	stamina_current = 100
	field_state_current = FieldState.BUDDY1
	Input.action_press("ability2")
	print("[Ability Test] Buddy Ability 2 On Right-Click:      ", process_ability_use(delta) == 2)
	print("[Ability Test] Buddy Ability 2 Depletes Stamina:    ", stamina_current < 100)
	Input.action_release("ability2")
	
	stamina_current = 100
	field_state_current = FieldState.SOLO
	Input.action_press("ability1")
	print("[Ability Test] Player Ability 1 On Left-Click:      ", process_ability_use(delta) == 1)
	print("[Ability Test] Player Ability 1 Depletes Stamina:   ", stamina_current < 100)
	Input.action_release("ability1")
	
	stamina_current = 100
	field_state_current = FieldState.BUDDY1
	Input.action_press("ability1")
	print("[Ability Test] Buddy Ability 1 On Left-Click:       ", process_ability_use(delta) == 1)
	print("[Ability Test] Buddy Ability 1 Depletes Stamina:    ", stamina_current < 100)
	Input.action_release("ability1")
	
	# ----------------------------------------------------------------------------------------------------------------------------------------------------------------- #
	
	tests_ran = true


func _on_sprite_animation_finished() -> void:
	
	
	if "juice" in sprite.animation and "throw" in sprite.animation:
		throwing_juicebox = false
		throw_juicebox.emit(get_global_mouse_position())
		juiceboxes -= 1
		
		if juiceboxes == 0:
			if juicebox_ready:
				juicebox_ready = false
				print("Player has unequipped their juicebox")
			else:
				field_state_current = FieldState.SOLO
			print("Player's FieldState has been updated to SOLO")
		
		update_animation()
	
	if "ability" in sprite.animation:
		using_ability = false
		print("ABILITY ENDED")
		if field_state_current == FieldState.BUDDY1 or field_state_current == FieldState.BUDDY2:
			update_animation()
		else:
			sprite.play("idle_" + current_direction_name)


func _on_sprite_frame_changed() -> void:
	if "ability" in sprite.animation:
		if sprite.get_frame() == 3:
			use_ability_solo.emit(attack_damage["Punch"])


func _on_sprite_animation_changed() -> void:
	pass # Replace with function body.


#func _on_sprite_animation_looped() -> void:
	#if field_state_current == FieldState.BUDDY1 or field_state_current == FieldState.BUDDY2:
		#update_animation()


func _on_animation_player_animation_changed(old_name: StringName, new_name: StringName) -> void:
	
	if old_name == "fuse" and new_name == "RESET":
		equipping_buddy = false
		is_interacting = false
