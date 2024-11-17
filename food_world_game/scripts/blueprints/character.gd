class_name Character

extends CharacterBody2D


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Animations #
var sprite: AnimatedSprite2D

var animation_player: AnimationPlayer

# On-Screen Notifier #
var on_screen_notifier: VisibleOnScreenNotifier2D

# Hitboxes #
var hitbox_damage: Area2D

var body_collider: CollisionShape2D

var feet_collider: CollisionShape2D
var feet_detector: Area2D 

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

signal target_player
signal target_closest_food_buddy

signal move_towards_target

signal die

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Gravity #
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Behavior #
var paused: bool = false
var in_range: bool = false

# Position and Size #
var center_point: Vector2
var bottom_point: Vector2
var width: float
var height: float

# Health #
var health_current: int
var health_max: int
var alive: bool = true

# Target #
var target: Node2D = null
var target_distance: float

# Jumping #
var is_jumping: bool = false
var jump_start_height: float
var jump_peak_height: float
var jump_peaked: bool = false
var is_falling: bool = false
var current_altitude: int = 0

const jump_velocity: int = 240

# Speed #
var speed_normal: int = 50
var speed_current: int = speed_normal

# Tiles #
var current_tile_position: Vector2i
var previous_tile_position: Vector2i
var on_platform: bool

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Store references to the Character's Nodes
	sprite = $AnimatedSprite2D
	animation_player = $AnimationPlayer
	on_screen_notifier = $VisibleOnScreenNotifier2D
	hitbox_damage = $"Damage Hitbox"
	
	body_collider = $"Body Collider"
	
	feet_collider = $"Feet Collider"
	feet_detector = $"Feet Collider/Feet Detector"

	
	# Call the custom ready function that subclasses may have defined manually
	ready()
	
	# Update the (x,y) coordinates of the Character's location points
	update_location_points()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# DEBUG
	#print('Current Altitude: ', str(current_altitude))
	#print('Current Z-Index: ', str(z_index))
	#print("")
	
	# Determine if the Character's processing is not paused
	if not paused:
		
		#process_fall()
		
		# Call the custom process function that subclasses may have defined manually
		process(delta)



# Called every frame. Updates the Enemy's physics
func _physics_process(delta: float) -> void:
	
	# Determine if the Character's processing is not paused
	if not paused:
	
		# Call the custom physics process function that subclasses may have defined manually
		physics_process(delta)
	
	# Update the (x,y) coordinates of the Character's locaiton point
	update_location_points()

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Calculates the location point of the Character by taking its current position and adjusting it by the width and height of the current Sprite frame to get the location coordinates
func update_location_points():
	
	# Store a reference to the current Sprite frame of the Character's animation
	var frame_texture: Texture2D = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	
	# Store the current width and height of the Character's current Sprite frame
	width = frame_texture.get_width()
	height = frame_texture.get_height()
	
	# Store the current coordinates for the bottom of this Character
	bottom_point.x = position.x
	bottom_point.y = position.y + height / 2
	
	center_point.x = position.x
	center_point.y = position.y



# Returns the name of the Food Buddy's FieldState Enum value based on the number it is associated with
func get_enum_value_name(enum_target: Dictionary, enum_number: int) -> String:
	
	# Iterate over each enum name
	for name in enum_target:
		
		# Determine if the name's corresponding value matches the given value
		if enum_target[name] == enum_number:
			return name
	
	# Return an empty String because there are no enum names that correspond to the given number
	return ""


# Process the Character's falling
func process_fall():
	
	# DESCEND
	# Determine if the PLayer is currently falling or has landed on a platform
	if is_falling:
		
		# Calculate the altitude as the distance that the character fell since the last update
		current_altitude += jump_peak_height - bottom_point.y
		print(current_altitude)
		# Set the z-index to be the current altitude / -7 because each platform will be placed 7 high on a tile, meaning that each increase in altitude should be a multiple of 7 each time.
		# The z-index is divided by a negative because it is supposed to be 1 lower with each increase in altitude to make the character further in the background than characters below them
		z_index = int(current_altitude / 8)
		
		# Determine if the current altitude is less than or equal to zero, then end the jump because the Character is back on the ground
		if current_altitude <= 0:
			position.y -= current_altitude
			current_altitude = 0
			jump_end()


# Starts the Player's jump
func jump_start():
	# Indicate that the jump is starting, the Character is not falling, and the Character is not on a platform
	is_jumping = true
	is_falling = false
	on_platform = false
	
	body_collider.disabled = true
	feet_collider.disabled = true
	feet_detector.monitoring = false
	
	# Store the starting y-coordinate of the jump from the Character's bottom
	jump_start_height = bottom_point.y
	
	# Intialize the jump's peak height to be 1 more than the jump's start height now that the jump has begun
	jump_peak_height = jump_start_height + 1
	
	# Reset velocity so the jump doesn't receive extra or reduced force, then adjust the Character's velocity upward by the jump force
	velocity.y = 0
	velocity.y -= jump_velocity



# Processes the Player's jump
func jump_process(delta: float):
	
	# DESCEND
	# Determine if the Cbaracter is currently falling and process it
	process_fall()
			
	
	# Determine if the Player has landed on a platform
	if on_platform:
		
		# Determine if the Player's scale has returned to normal, then end the jump
		if scale.x == 1 and scale.y == 1:
			jump_end()
			return
	
	# Otherwise, determine if the Player has landed below where they initially jumped from, then set their current y-position to the y-position they initiated the jump from and end the jump
	elif bottom_point.y > jump_start_height and current_altitude == 0:
		bottom_point.y = jump_start_height
		return
	
	
	# Adjust the Player's scale back down to 1 (it was incrementing as the Player jumped and should decrement as they fall/land)
	if scale.x > 1:
		scale.x -=  1 * delta
	else:
		scale.x = 1
	
	if scale.y > 1:
		scale.y -=  1 * delta
	else:
		scale.y = 1
	
	
	# Apply gravity to the Player so they gradually begin to fall
	velocity.y += gravity * delta
	
	# ASCEND
	# Determine if the Player's current altitude is higher than the highest altitude the Player has reached in the jump so far
	if !is_falling and bottom_point.y < jump_peak_height:
		
		# Calculate the altitude as the distance that the character rose since the last update (subtract peak - bottom_point because even though bottom point should be higher as the Player ascends, it moves lower because y-axos
		current_altitude += int(jump_peak_height - bottom_point.y)
		
		# Set the z-index to be the current altitude / -7 because each platform will be placed 7 high on a tile, meaning that each increase in altitude should be a multiple of 7 each time.
		# The z-index is divided by a negative because it is supposed to be 1 lower with each increase in altitude to make the character further in the background than characters below them
		z_index = int(current_altitude / -8)
		
		# Set the Player's current altitude as the new highest altitude reached
		jump_peak_height = bottom_point.y
		
		# Increase the Player's scale as they ascend
		scale.x += 1 * delta
		scale.y += 1 * delta
		
	# Otherwise, the Character must be falling because the jump has peaked
	else: 
		is_falling = true
		feet_collider.disabled = false
		feet_detector.monitoring = true


# Ends the Player's jump
func jump_end():
	is_jumping = false
	is_falling = false
	
	body_collider.disabled = false
	
	if on_platform:
		feet_detector.monitoring = true
		feet_collider.disabled = false
	else:
		feet_detector.monitoring = false
		feet_collider.disabled = true
	
	velocity.y = 0
	
	scale.x = 1
	scale.y = 1

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ABSTRACT FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# A custom ready function that each Enemy subclass should personally define. This is called in the default Enemy class's '_ready()' function
func ready():
	pass



# A custom process function that each Enemy subclass should personally define. This is called in the default Enemy class's '_process()' function
func process(delta: float):
	pass



# A custom physics_process function that each Enemy subclass should personally define. This is called in the default Enemy class's '_physics_process()' function
func physics_process(delta: float) -> void:
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
