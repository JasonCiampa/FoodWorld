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
var is_falling: bool = false
var jump_peaked: bool = false
var jump_start_height: float
var jump_peak_height: float
var current_altitude: int
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
	
	# Determine if the Character's processing is not paused
	if not paused:
		
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





# Processes the Player's jump
func jump_process(delta: float):
	
	# Determine if the PLayer is currently falling or has landed on a platform
	if is_falling or on_platform:
		
		# Adjust the Player's scale back down to 1 (it was incrementing as the Player jumped and should decrement as they fall/land)
		if scale.x > 1:
			scale.x -=  1 * delta
		else:
			scale.x = 1
		
		if scale.y > 1:
			scale.y -=  1 * delta
		else:
			scale.y = 1
	
	# Determine if the Player has landed on a platform
	if on_platform:
		
		# Determine if the Player's scale has returned to normal, then end the jump
		if scale.x == 1 and scale.y == 1:
			jump_end()
			return
	
	# Otherwise, determine if the Player has landed below where they initially jumped from, then set their current y-position to the y-position they initiated the jump from and end the jump
	elif bottom_point.y > jump_start_height:
		bottom_point.y = jump_start_height
		jump_end()
		return
	
	# Apply gravity to the Player so they fall
	velocity.y += gravity * delta
	
	# Determine if the Player's current altitude is higher than the highest altitude the Player has reached in the jump so far
	if bottom_point.y < jump_peak_height:
		
		# Set the Player's current altitude as the new highest altitude reached and then increase the Player's scale as they ascend
		jump_peak_height = bottom_point.y
		scale.x += 1 * delta
		scale.y += 1 * delta
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
