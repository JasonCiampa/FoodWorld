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

signal feet_collide_start

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
var jump_start_altitude: float
var jump_peaked: bool = false
var jump_peak_height: float

var fall_start_altitude: float
var fall_start_height: float
var is_falling: bool = false

var current_altitude: float = 0

const jump_velocity: int = 250

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



# Start the Character's falling
func fall_start():
	is_falling = true
	on_platform = false
	
	fall_start_height = bottom_point.y
	fall_start_altitude = current_altitude



# Process the Character's falling
func fall_process(delta: float):
	
	# Determine if the Character isn't jumping, then apply gravity so they fall (don't apply it if they are jumping because that is already done in the jump functions)
	if !is_jumping:
		velocity.y += gravity * delta
	
	
	# Reduce the altitude by 1 px for every 1 tile that the Character falls by
	current_altitude = fall_start_altitude - ((bottom_point.y - fall_start_height) / 2)
	
	# Set the Character's z-Index is to be the same z-altitude as the tile that the Character is standing on
	z_index = (int(current_altitude) % 8) / -8
	
	# Determine if the current altitude has reached or gone below 0, then set is_falling to false because the Character has reached the ground
	if current_altitude <= 0:
		fall_end()
		on_platform = false
		
		# Increment the Character's bottom point so that they are standing exactly at 0 altitude
		position.y -= (current_altitude * -2)
		current_altitude = 0
		velocity.y = 0



# End the Character's falling
func fall_end():
	is_falling = false





# Starts the Player's jump
func jump_start():
	set_collision_layer_value(4, false)
	set_collision_mask_value(4, false)
	set_collision_layer_value(5, true)
	set_collision_mask_value(5, true)
	
	feet_detector.set_collision_layer_value(4, true)
	feet_detector.set_collision_mask_value(4, true)

	
	# Indicate that the jump is starting, the Character is not falling, and the Character is not on a platform
	is_jumping = true
	jump_peaked = false
	is_falling = false
	on_platform = false
	
	
	# Store the starting y-coordinate of the jump from the Character's bottom
	jump_start_height = bottom_point.y
	jump_start_altitude = current_altitude
	
	# Intialize the jump's peak height to be 1 more than the jump's start height now that the jump has begun
	jump_peak_height = jump_start_height + 1
	
	# Reset velocity so the jump doesn't receive extra or reduced force, then adjust the Character's velocity upward by the jump force
	velocity.y = 0
	velocity.y -= jump_velocity


# Process the ascending portion of the jump (the portion of the jump in which the Player hasn't reached a peak height of the jump)
func jump_ascend(delta: float):
	
	# Determine if the Player's current altitude is higher than the highest altitude the Player has reached in the jump so far
	if bottom_point.y < jump_peak_height:
		
		# Set the Character's peak jump height to be equal to their bottom point now that they have surpassed the previous peak jump height
		jump_peak_height = bottom_point.y
		
		# Increase the altitude by 1 px for every 1 tile that the Character jumps on
		current_altitude = jump_start_altitude + ((jump_start_height - bottom_point.y) / 2)
		
		# Set the Character's z-Index is to be the same z-altitude as the tile that the Character is standing on
		z_index = (int(current_altitude) % 8) / -8
		
		# Increase the Player's scale as they ascend
		scale.x += 1 * delta
		scale.y += 1 * delta
		
	# Otherwise, the Character must be falling because the jump has peaked
	else: 
		fall_start()
		jump_peaked = true
		body_collider.disabled = false


# Process the descending portion of the jump (the portion of the jump that occurs immediately after the Player reaches the peak height of the jump and begin to start falling)
func jump_descend(delta: float):
	
	# Process the Character's fall
	fall_process(delta)
	
	# Adjust the Player's scale back down to 1 (it was incrementing as the Player jumped and should decrement as they fall/land)
	if scale.x > 1 or scale.y > 1:
		scale.x -=  1 * delta
		scale.y -=  1 * delta
	else:
		scale.x = 1
		scale.y = 1


# Processes the Player's jump
func jump_process(delta: float):
	
	# Apply gravity to the Player so they gradually begin to fall
	velocity.y += gravity * delta
	
	# Determine if the Character is falling, then process their descent
	if is_falling:
		jump_descend(delta)
		
	# Otherwise, determine if the Character is rising (if they aren't falling, aren't on a platform), then process their ascent
	elif !jump_peaked:
		jump_ascend(delta)
	
	# Otherwise, the Character must have landed on a platform 
	else:
		
		# Determine if the Player's scale has returned to normal, then end the jump
		if scale.x == 1 and scale.y == 1:
			jump_end()
		else:
			# Adjust the Player's scale back down to 1 (it was incrementing as the Player jumped and should decrement as they fall/land)
			if scale.x > 1 or scale.y > 1:
				scale.x -=  1 * delta
				scale.y -=  1 * delta
			else:
				scale.x = 1
				scale.y = 1


# Ends the Player's jump
func jump_end():
	set_collision_layer_value(4, true)
	set_collision_mask_value(4, true)
	set_collision_layer_value(5, false)
	set_collision_mask_value(5, false)
	
	feet_detector.set_collision_layer_value(4, true)
	feet_detector.set_collision_mask_value(4, true)
	feet_detector.set_collision_layer_value(5, false)
	feet_detector.set_collision_mask_value(5, false)
	
	CharacterBody2D
	
	is_jumping = false
	is_falling = false
	
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


func _on_feet_detector_body_entered(body: Node2D) -> void:
	feet_collide_start.emit(body, self)
