extends CharacterBody2D

# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var dodge_timer: Timer = $"Dodge Timer"
@onready var dodge_cooldown_timer: Timer = $"Dodge Cooldown Timer"

@onready var stamina_regen_delay_timer: Timer = $"Stamina Regen Delay Timer"

@onready var timer: Timer = $"Timer"

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Movement Directions #
enum Direction { IDLE = 0, UP = -1, DOWN = 1,  LEFT = -1, RIGHT = 1 }

# Fighting Styles #
enum FightStyle { SOLO, BUDDY1, BUDDY2, BUDDY_FUSION }

# Stamina Usages #
enum StaminaUse { SPRINT = 15, DODGE = 30 }

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Health #
var health_current : int
var health_max: int

# XP #
var xp_current : int
var xp_max : int

# Stamina #
var stamina_previous: float = 0
var stamina_current: float = 100
var stamina_max: float = 100
var stamina_regen_rate: float = 25
var stamina_decreasing: bool = false
var stamina_increasing: bool = false
var stamina_regen_delay_active: bool = false

# Speed #
var speed_normal: int = 75
var speed_sprinting: int = 300
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



# Called every frame. Updates the Player's physics
func _physics_process(_delta: float) -> void:
	# Movement Updates #
	update_movement_velocity()
	move_and_slide()

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Calculates the Player's current velocity based on their movement input.
func calculate_velocity(direction):
	return direction * speed_current



# Updates the Player Sprite's animation depending on which direction the Player was/is traveling.
func update_movement_animation():
	# Check if the Player is fully idle
	if (direction_current_horizontal == Direction.IDLE) and (direction_current_vertical == Direction.IDLE):
		# Determine the correct idle animation to play based on the direction that the Player was previously moving in
		if (direction_previous_horizontal == Direction.IDLE):
			if (direction_previous_vertical == Direction.DOWN):
				sprite.play("idle_front")
			elif (direction_previous_vertical == Direction.UP):
				sprite.play("idle_back")
		elif (direction_previous_horizontal == Direction.LEFT) or (direction_previous_horizontal == Direction.RIGHT):
			sprite.play("idle_sideways")
			
	# Determine the correct running animation to play
	elif (direction_current_vertical == Direction.UP):
		sprite.play("run_upward")
	elif (direction_current_vertical == Direction.DOWN):
		sprite.play("run_downward")
	else:
		sprite.play("run_sideways")
		
	# Flip the sprite horizontally depending on if the Player is moving left or right
	if direction_current_horizontal == Direction.RIGHT:
		sprite.flip_h = false
	elif direction_current_horizontal == Direction.LEFT:
		sprite.flip_h = true
	
	# Determine the correct animation speed based on whether or not the Player is sprinting currently
	if is_sprinting:
		sprite.speed_scale = 1.5
	else:
		sprite.speed_scale = 1
		
	if not dodge_timer.is_stopped():
		sprite.play("dodge")



# Updates the variables that keep track of previous and current movement direction
func update_movement_direction():
	# Store the current horizontal and vertical directions as the previous directions.
	direction_previous_horizontal = direction_current_horizontal
	direction_previous_vertical = direction_current_vertical
	
	# Update the current horizontal and vertical direction being inputted by the user
	direction_current_horizontal = Input.get_axis("move_left", "move_right")
	direction_current_vertical = Input.get_axis("move_up", "move_down")



# Updates the Player's velocity based on their speed and the direction they're currently moving in
func update_movement_velocity():
	# Determine whether or not the Player is sprinting
	if Input.is_action_pressed("sprint") and stamina_current > 0:
		is_sprinting = true
		speed_current = speed_sprinting
	else:
		is_sprinting = false
		speed_current = speed_normal
		
	# Determine whether or not the Player is triggering a dodge
	if Input.is_action_just_pressed("dodge") and stamina_current > 0 and dodge_cooldown_timer.is_stopped():
		dodge_cooldown_timer.start()
		dodge_timer.start()
		is_dodging = true
		
	# Determine whether or not the Player is currently dodging
	if not dodge_timer.is_stopped():
		speed_current = speed_dodging
		
		# Check if the Player is not currently moving in any direction
		if (direction_current_horizontal == Direction.IDLE) and (direction_current_vertical == Direction.IDLE):
			if sprite.animation == "idle_sideways":
				velocity.x = calculate_velocity(direction_previous_horizontal)
			else:
				velocity.y = calculate_velocity(direction_previous_vertical)	
	else:
		is_dodging = false	
	
	# Determine if the Player is moving both vertically and horizontally
	if (direction_current_horizontal != Direction.IDLE) and (direction_current_vertical != Direction.IDLE):
		# Reduce the velocity by half on each axis so the Player doesn't move at double speed
		velocity.x = 0.01 * calculate_velocity(direction_current_horizontal)
		velocity.y = 0.01 * calculate_velocity(direction_current_vertical)

	# Update the player's horizontal velocity based on the user's input
	if direction_current_horizontal != Direction.IDLE:
		velocity.x = calculate_velocity(direction_current_horizontal)
	else:
		velocity.x = move_toward(velocity.x, 0, speed_current)
		
	# Update the player's vertical velocity based on the user's input
	if direction_current_vertical != Direction.IDLE:
		velocity.y = calculate_velocity(direction_current_vertical)	
	else:
		velocity.y = move_toward(velocity.y, 0, speed_current)



# Updates the Player's current fight style based on their key presses
func update_fight_style():

	# Check if the Player updated their fight style
	if Input.is_action_just_pressed("update_fight_style"):
		# Store the current fight style as the previous one since the fight style has been updated
		fight_style_previous = fight_style_current
		
		# Determine which fight style the Player has now selected
		if Input.is_action_just_pressed("equip_buddy1"):
			fight_style_current = FightStyle.BUDDY1
			sprite.play("fighting_buddy1")
		elif Input.is_action_just_pressed("equip_buddy2"):
			fight_style_current = FightStyle.BUDDY2
			sprite.play("fighting_buddy2")
		elif Input.is_action_just_pressed("equip_buddy_fusion"):
			fight_style_current = FightStyle.BUDDY_FUSION
			sprite.play("fighting_buddy_fusion")
	
		# Check if the Player is selecting the solo fight style
		if fight_style_previous == fight_style_current:
			fight_style_current = FightStyle.SOLO
			sprite.play("fighting_solo")



# Updates the Player's stamina based on their input
func update_stamina(delta):
	# Intialize Stamina to NOT be decreasing
	stamina_decreasing = false
	
	
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
			
			
	# Trigger Stamina Increase if the Regeneration Delay Timer has finished and if the Player didn't use any stamina during the delay
	if (stamina_regen_delay_timer.time_left == 0) and (stamina_previous == stamina_current):
		stamina_increasing = true
		stamina_previous = 0
		
		
	# Replenish Stamina if the Player isn't using any
	if stamina_increasing and (not stamina_decreasing):
		stamina_current += stamina_regen_rate * delta
	else:
		stamina_increasing = false
		
		
	# Reset Stamina to be in-bounds if it exceeds the lower or upper limit
	if stamina_current > stamina_max:
		stamina_current = stamina_max
		stamina_increasing = false
	elif stamina_current < 0:
		stamina_current = 0
	

	# Trigger Stamina Regeneration Delay if the Player doesn't have max stamina, if the regen timer is inactive, and if at least one of the following is true: Player ran out of stamina, Player not using stamina
	if (stamina_current < stamina_max) and (stamina_regen_delay_timer.time_left == 0) and (stamina_current <= 0 or (stamina_decreasing == false and stamina_increasing == false)):
		stamina_regen_delay_timer.start()
		stamina_previous = stamina_current
	
	## DEBUG #
	if timer.time_left == 0:
		timer.start()
		print("Current: " + str(stamina_current))
		#print("Increasing: " + str(stamina_increasing))
		#print("Decreasing: " + str(stamina_decreasing))
		#print("Previous: " + str(stamina_previous))
		#print("Time Left: " + str(stamina_regen_delay_timer.time_left))
		#print(" ")
		#print(" ")



# Updates a stat chosen by the Player, increments level, resets current xp, refills hp, maybe increase max xp (harder to level up as you progress?)
func level_up():
	pass



# Triggers one of the Player's attacks based on their input (left-click = attack/ability 1, right-click = attack/ability 2, ? = special attack)
func attack():
	pass
