extends CharacterBody2D

# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Animations #
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Timers #
@onready var dodge_timer: Timer = $"Timers/Dodge Timer"
@onready var dodge_cooldown_timer: Timer = $"Timers/Dodge Cooldown Timer"
@onready var stamina_regen_delay_timer: Timer = $"Timers/Stamina Regen Delay Timer"
@onready var timer: Timer = $Timers/Timer


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Movement Directions #
enum Direction { IDLE = 0, UP = -1, DOWN = 1,  LEFT = -1, RIGHT = 1 }

# Fighting Styles #
enum FightStyle { SOLO, BUDDY1, BUDDY2, BUDDY_FUSION }

# Stamina Usages #
enum StaminaUse { SPRINT = 15, JUMP = 20, DODGE = 30 }

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Gravity #
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Inventory #
var inventory: Array = []
var inventory_size: int = 12

# Health #
var health_current: int
var health_max: int

# XP #
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

# Speed #
var speed_normal: int = 60
var speed_sprinting: int = 125
var speed_dodging: int = 200
var speed_current: int = speed_normal

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

# Jumping #
var is_jumping: bool
var jump_start_height: int
const jump_velocity: int = 250

# Fighting #
var fight_style_previous: FightStyle = FightStyle.SOLO
var fight_style_current: FightStyle = FightStyle.SOLO
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.play("idle_front")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_movement_direction()
	update_movement_animation()
	update_stamina(delta)
	#update_fight_style()
	
		# DEBUG #
	#if timer.time_left == 0:
		#timer.start()
		#print("Position X: " + str(position.x))
		#print("Position Y: " + str(position.y))
		#print(" ")
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
		#print(" ")



# Called every frame. Updates the Player's physics
func _physics_process(delta: float) -> void:
	# Movement Updates #
	update_movement_velocity(delta)
	move_and_slide()

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Calculates the Player's current velocity based on their movement input.
func calculate_velocity(direction):
	return direction * speed_current



# Updates the Player Sprite's animation depending on which direction the Player was/is traveling.
func update_movement_animation():
	
	# Determine if the Player is jumping, then trigger the jump animation
	if is_jumping:
		sprite.play("jump")
	
	# Determine if the Player is fully idle, then play the correct idle animation based on the direction that the Player was previously moving in
	elif (direction_current_horizontal == Direction.IDLE) and (direction_current_vertical == Direction.IDLE):
		if (direction_previous_horizontal == Direction.IDLE):
			if (direction_previous_vertical == Direction.DOWN):
				sprite.play("idle_front")
			elif (direction_previous_vertical == Direction.UP):
				sprite.play("idle_back")
		elif (direction_previous_horizontal == Direction.LEFT) or (direction_previous_horizontal == Direction.RIGHT):
			sprite.play("idle_sideways")
			
	# Determine which direction the Player is moving, then play the correct animated based on the direction they're pursuing
	elif (direction_current_vertical == Direction.UP):
		sprite.play("run_upward")
	elif (direction_current_vertical == Direction.DOWN):
		sprite.play("run_downward")
	else:
		sprite.play("run_sideways")
		
	# Determine which direction the Player is facing, then flip the sprite horizontally depending on if the Player is facing left or right
	if direction_current_horizontal == Direction.RIGHT:
		sprite.flip_h = false
	elif direction_current_horizontal == Direction.LEFT:
		sprite.flip_h = true
	
	# Determine if the Player has stamina, then determine if they're performing any actions, then set the correct animation and animation speed based on the Player's action
	if stamina_current > 0:
		if Input.is_action_just_pressed("sprint"):
			animation_player.play("start_sprinting")
			sprite.speed_scale = 1.5
		elif Input.is_action_just_released("sprint"):
			animation_player.play("stop_sprinting")
			sprite.speed_scale = 1
			
		if Input.is_action_just_pressed("dodge") and (not dodge_timer.is_stopped()):
			sprite.play("dodge")
			animation_player.play("dodge")
	else:
		if stamina_just_ran_out:
			animation_player.play("stop_sprinting")
			sprite.speed_scale = 1



# Updates the variables that keep track of previous and current movement direction
func update_movement_direction():
	
	# Store the current horizontal and vertical directions as the previous directions.
	direction_previous_horizontal = direction_current_horizontal
	direction_previous_vertical = direction_current_vertical
	
	# Update the current horizontal and vertical direction being inputted by the user
	direction_current_horizontal = Input.get_axis("move_left", "move_right")
	direction_current_vertical = Input.get_axis("move_up", "move_down")



# Updates the Player's velocity based on their speed and the direction they're currently moving in
func update_movement_velocity(delta):
	
	# Determine whether or not the Player is starting a jump, then begin the jump by applying upward velocity
	if Input.is_action_just_pressed("jump") and is_jumping == false and stamina_current > 0:
		is_jumping = true
		velocity.y = 0
		jump_start_height = position.y
		velocity.y -= jump_velocity
	
	# Determine if the Player is currently jumping, then adjust their y-position by gravity
	if is_jumping:
		velocity.y += gravity * delta
		
		# Determine if the application of gravity has pushed the Player too far below their intial jump-point, then adjust their y-position
		if position.y > jump_start_height:
			position.y = jump_start_height
			is_jumping = false
	
	# Determine whether or not the Player is sprinting, then adjust their speed
	if Input.is_action_pressed("sprint") and stamina_current > 0:
		is_sprinting = true
		speed_current = speed_sprinting
	else:
		is_sprinting = false
		speed_current = speed_normal
		
	# Determine whether or not the Player is jumping
	if is_jumping == false:
		
		# Determine whether or not the Player is starting a dodge, then begin the dodge and it's cooldown by starting their timers
		if Input.is_action_just_pressed("dodge") and stamina_current > 0 and dodge_cooldown_timer.is_stopped():
			dodge_cooldown_timer.start()
			dodge_timer.start()
			is_dodging = true
			
		# Determine whether or not the Player is currently dodging, then adjust their speed
		if not dodge_timer.is_stopped():
			speed_current = speed_dodging
			
			# Determine if the Player is not currently moving in any direction (idle)
			if (direction_current_horizontal == Direction.IDLE) and (direction_current_vertical == Direction.IDLE):
				
				# Determine if the Player is facing either the left or right, then have them dodge in that direction from an idle position
				if sprite.animation == "idle_sideways":
					print("Sideways")
					if sprite.flip_h:
						velocity.x = calculate_velocity(Direction.LEFT)
					else:
						velocity.x = calculate_velocity(Direction.RIGHT)
						
				# Determine if the Player is facing forward or backward, then have them dodge in that direction from an idle position
				if sprite.animation == "idle_front":
					velocity.y = calculate_velocity(Direction.DOWN)
				elif sprite.animation == "idle_back":
					velocity.y = calculate_velocity(Direction.UP)
					
				return
		else:
			is_dodging = false
			
	# Determine if the Player is moving both vertically and horizontally
	if (direction_current_horizontal != Direction.IDLE) and (direction_current_vertical != Direction.IDLE):
		# Reduce the velocity by half on each axis so the Player doesn't move at double speed
		velocity.x = calculate_velocity(direction_current_horizontal)
		
		# Determine if the Player is NOT jumping, then adjust the y-velocity
		if not is_jumping:
			velocity.y = calculate_velocity(direction_current_vertical)
			
		return
		
	# Determine if the Player is moving horizontally, then adjust the x-velocity
	if direction_current_horizontal != Direction.IDLE:
		velocity.x = calculate_velocity(direction_current_horizontal)
	else:
		velocity.x = move_toward(velocity.x, 0, speed_current)
		
	# Determine if the Player is moving vertically, then adjust the y-velocity
	if is_jumping == false:
		if direction_current_vertical != Direction.IDLE:
			velocity.y = calculate_velocity(direction_current_vertical)	
		else:
			velocity.y = move_toward(velocity.y, 0, speed_current)



# Updates the Player's current fight style based on their key presses
func update_fight_style():

	# Determine if the Player updated their fight style
	if Input.is_action_just_pressed("update_fight_style"):
		# Store the current fight style as the previous one since the fight style has been updated
		fight_style_previous = fight_style_current
		
		# Determine which fight style the Player has now selected, then set the selection as the current fight style
		if Input.is_action_just_pressed("equip_buddy1"):
			fight_style_current = FightStyle.BUDDY1
			sprite.play("fighting_buddy1")
		elif Input.is_action_just_pressed("equip_buddy2"):
			fight_style_current = FightStyle.BUDDY2
			sprite.play("fighting_buddy2")
		elif Input.is_action_just_pressed("equip_buddy_fusion"):
			fight_style_current = FightStyle.BUDDY_FUSION
			sprite.play("fighting_buddy_fusion")
	
		# Determine if the Player is selecting the solo fight style, then set the selection as the current fight style
		if fight_style_previous == fight_style_current:
			fight_style_current = FightStyle.SOLO
			sprite.play("fighting_solo")



# Updates the Player's stamina based on their input
func update_stamina(delta):
	# Intialize Stamina to NOT be decreasing
	stamina_decreasing = false
	stamina_just_ran_out = false
	
	# Trigger Stamina Decrease and Reset Regeneration Delay Timer if the Player isn't out of stamina and is either sprinting, dodging, or both
	if stamina_current > 0:
		if is_sprinting and Input.is_action_pressed("move"):
			stamina_decreasing = true
			stamina_current -= StaminaUse.SPRINT * delta
			stamina_regen_delay_timer.stop()
		if is_dodging:
			stamina_decreasing = true
			stamina_current -= StaminaUse.DODGE * delta
			stamina_regen_delay_timer.stop()
		if is_jumping:
			stamina_decreasing = true
			stamina_current -= StaminaUse.JUMP * delta
			stamina_regen_delay_timer.stop()
			
			
	# Determine if the Player didn't use any stamina during the delay and if the regeneration delay timer has finished, then set the Player's stamina to be increasing
	if (stamina_regen_delay_timer.time_left == 0) and (stamina_previous == stamina_current):
		stamina_increasing = true
		stamina_previous = 0
		
		
	# Determine if the Player isn't using any stamina, then replenish Stamina
	if stamina_increasing and (not stamina_decreasing):
		stamina_current += stamina_regen_rate * delta
	else:
		stamina_increasing = false
		
		
	# Determine if stamina exceeds the lower or upper limit, then reset Stamina to be in-bounds
	if stamina_current > stamina_max:
		stamina_current = stamina_max
		stamina_increasing = false
	elif stamina_current < 0:
		stamina_current = 0
		stamina_just_ran_out = true
	

	# Determine if the Player doesn't have max stamina, if the regen timer is inactive, and if at least one of the following is true: Player ran out of stamina, Player not using stamina, then trigger stamina regeneration delay
	if (stamina_current < stamina_max) and (stamina_regen_delay_timer.time_left == 0) and (stamina_current <= 0 or (stamina_decreasing == false and stamina_increasing == false)):
		stamina_regen_delay_timer.start()
		stamina_previous = stamina_current




# Updates a stat chosen by the Player, increments level, resets current xp, refills hp, maybe increase max xp (harder to level up as you progress?)
func level_up():
	pass



# Triggers one of the Player's attacks based on their input (left-click = attack/ability 1, right-click = attack/ability 2, ? = special attack)
func attack():
	pass
