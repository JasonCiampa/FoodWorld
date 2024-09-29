class_name Player

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

# Hitbox #
@onready var hitbox: Area2D = $Area2D

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

signal equip_buddy
signal equip_buddy_fusion

signal use_ability_solo
signal use_ability_buddy
signal use_ability_buddy_fusion


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

enum Direction { IDLE = 0, UP = -1, DOWN = 1,  LEFT = -1, RIGHT = 1 }

enum FightStyle { SOLO, BUDDY1, BUDDY2, BUDDY_FUSION }

enum StaminaUse { SPRINT = 15, JUMP = 10, DODGE = 30, PUNCH = 5, KICK = 10}

enum AttackKnockback { PUNCH = 25, KICK = 50}

enum Ability { PUNCH = 1, KICK = 2}

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

# Speed #
var speed_normal: int = 60
var speed_sprinting: int = 125
var speed_dodging: int = 350
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
var jump_start_height: float
const jump_velocity: int = 250

# Fighting #
var fight_style_previous: FightStyle = FightStyle.SOLO
var fight_style_current: FightStyle = FightStyle.SOLO
var attack_damage: Dictionary = { "Punch": 10, "Kick": 15 }

# Food Buddies #
var food_buddy1: FoodBuddy
var food_buddy2: FoodBuddy
var food_buddies: Array[FoodBuddy]

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("READY PLAYER")
	sprite.play("idle_front")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	process_ability_use()
	update_movement_direction()
	update_movement_animation()
	update_stamina(delta)
	update_fight_style()	
	
	# DEBUG #
	if timer.time_left == 0:
		timer.start()
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
		#print("Current Health: " + str(health_current))
		#print(" ")
		#print(" ")



# Called every frame. Updates the Player's physics
func _physics_process(delta: float) -> void:
	update_movement_velocity(delta)
	move_and_slide()
	check_collide_and_push()

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
	
	# Determine if an ability was used, then trigger the signal that will use the correct ability based on the Player's current fighting style
	if ability_number != 0:
		if fight_style_current == FightStyle.SOLO:
			if ability_number == 1:
				use_ability_solo.emit(hitbox, attack_damage["Punch"])
				use_stamina(StaminaUse.PUNCH)
			else:
				use_ability_solo.emit(hitbox, attack_damage["Kick"])
				use_stamina(StaminaUse.KICK)
			
		elif fight_style_current == FightStyle.BUDDY1:
			use_ability_buddy.emit(food_buddy1, ability_number)
		
		elif fight_style_current == FightStyle.BUDDY2:
			use_ability_buddy.emit(food_buddy2, ability_number)
		
		else:
			use_ability_buddy_fusion.emit(food_buddy1, food_buddy2)



# Checks if the Player collided with a RigidBody2D, and if so, pushes the RigidBody2D with power determined by the Player's current speed
func check_collide_and_push():
	
	# Iterate for the number of collisions that occured after move_and_slide() was called
	for i in get_slide_collision_count():
		
		# Store references for the collision itself and the entity that was collided with
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# Determine if the entity who the collision occurred with was a RigidBody2D, then apply the push force
		if collider is RigidBody2D:
			collider.apply_central_impulse(-collision.get_normal() * 2)



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
	
	
	# Determine which direction the Player is moving, then play the correct 'running' animation based on the direction they're pursuing
	elif (direction_current_vertical == Direction.UP):
		sprite.play("run_upward")
	elif (direction_current_vertical == Direction.DOWN):
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
			sprite.speed_scale = 1.5
		elif Input.is_action_just_released("sprint"):
			animation_player.play("stop_sprinting")
			sprite.speed_scale = 1
		
		if Input.is_action_just_pressed("dodge") and (not dodge_timer.is_stopped()):
			sprite.play("dodge")
			
			# Determine if the Player is sprinting while they trigger the dodge, then play the sprinting-dodge animation
			if is_sprinting:
				animation_player.play("dodge_sprinting")
			else:
				animation_player.play("dodge")
	
	
	# Determine if the Player has run out of stamina this frame, then adjust the animations that are being played and their speed
	if stamina_just_ran_out:
		sprite.speed_scale = 1
		stamina_just_ran_out = false
		
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
			is_jumping = true
			jump_start_height = position.y
			velocity.y = 0
			velocity.y -= jump_velocity
			use_stamina(StaminaUse.JUMP)
		
		
		# Determine whether or not the Player is sprinting, then trigger the sprinting state
		if Input.is_action_pressed("sprint") and Input.is_action_pressed("move"):
			is_sprinting = true
			speed_current = speed_sprinting
			use_stamina_gradually(StaminaUse.SPRINT, delta)
		else:
			is_sprinting = false
			speed_current = speed_normal
		
		
		# Determine whether or not the Player is starting a dodge, then trigger the dodge and it's cooldown
		if Input.is_action_just_pressed("dodge") and stamina_current > 0 and dodge_cooldown_timer.is_stopped() and (not is_jumping):
			dodge_cooldown_timer.start()
			dodge_timer.start()
			is_dodging = true
		
		# Determine whether or not the Player is currently dodging, then adjust their speed
		if not dodge_timer.is_stopped():
			speed_current = speed_dodging
			use_stamina_gradually(StaminaUse.DODGE, delta)
			
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
				
				return
		else:
			is_dodging = false
	else:
		speed_current = speed_normal
		is_sprinting = false
		is_dodging = false
	
	
	# Determine if the Player is currently jumping, then adjust their y-position by gravity
	if is_jumping:
		velocity.y += gravity * delta
		
		# Determine if the application of gravity has pushed the Player too far below their intial jump-point, then end the jump and set their current y-position to the y-position they initiated the jump from
		if position.y > jump_start_height:
			is_jumping = false
			position.y = jump_start_height
			velocity.y = 0
	
	
	# Determine if the Player is moving horizontally, then adjust the x-velocity
	if direction_current_horizontal != Direction.IDLE:
		velocity.x = calculate_velocity(direction_current_horizontal)
	else:
		velocity.x = move_toward(velocity.x, 0, speed_current)
	
	# Determine if the Player isn't jumping, then determine if the Player is moving vertically, then adjust the y-velocity
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
		
		# Determine which fight style the Player has now selected, then set the selection as the current fight style, send a signal to any involved Food Buddy, and trigger the correct animation
		if Input.is_action_just_pressed("equip_buddy1"):
			fight_style_current = FightStyle.BUDDY1
			equip_buddy.emit(food_buddy1)
			sprite.play("fighting_buddy1")
		elif Input.is_action_just_pressed("equip_buddy2"):
			fight_style_current = FightStyle.BUDDY2
			equip_buddy.emit(food_buddy2)
			sprite.play("fighting_buddy2")
		elif Input.is_action_just_pressed("equip_buddy_fusion"):
			fight_style_current = FightStyle.BUDDY_FUSION
			equip_buddy_fusion.emit()
			sprite.play("fighting_buddy_fusion")
		
		# Determine if the Player is selecting the solo fight style, then set the selection as the current fight style
		if fight_style_previous == fight_style_current:
			fight_style_current = FightStyle.SOLO
			sprite.play("fighting_solo")



# Depletes the Player's current stamina instantly by the given stamina use amount.
func use_stamina(stamina_use: int):
	stamina_current -= stamina_use
	stamina_decreasing = true
	stamina_increasing = false
	stamina_regen_delay_timer.stop()



# Depletes the Player's current stamina gradually over time by the given stamina use amount.
func use_stamina_gradually(stamina_use: int, delta: float):
	stamina_current -= stamina_use * delta
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
	elif stamina_current < 0:
		stamina_current = 0
		stamina_just_ran_out = true
	
	# Determine if the Player doesn't have max stamina, if the regen timer is inactive, and if at least one of the following is true: Player ran out of stamina or Player not using stamina, then trigger stamina regeneration delay
	if (stamina_current < stamina_max) and (stamina_regen_delay_timer.time_left == 0) and (stamina_current <= 0 or (stamina_decreasing == false and stamina_increasing == false)):
		stamina_regen_delay_timer.start()
		stamina_previous = stamina_current



# Updates a stat chosen by the Player, increments level, resets current xp, refills hp, maybe increase max xp (harder to level up as you progress?)
func level_up():
	pass
