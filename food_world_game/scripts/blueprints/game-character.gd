class_name GameCharacter

extends CharacterBody2D


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# On-Screen Notifier #
var on_screen_notifier: VisibleOnScreenNotifier2D

# Animations #
var sprite: AnimatedSprite2D
var animation_player: AnimationPlayer

# Hitboxes #
var hitbox_damage: Area2D

# Colliders #
var body_collider: CollisionShape2D
var feet_collider: CollisionShape2D

# Shadow #
var shadow: Polygon2D

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

signal target_player
signal target_closest_food_buddy
signal killed_target

signal move_towards_target

signal feet_collide_start

signal update_altitude

signal fall_starting
signal fall_ending

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
var width: float
var height: float


# Health #
var health_current: int
var health_max: int
var alive: bool = true


# Target #
var target: Node2D = null
var target_distance: float


# Jumping/Falling #
var is_jumping: bool = false
var is_falling: bool = false
var on_platform: bool = false

var jump_velocity: int = 200
var jump_peak_height: float
var jump_landing_height: float
var jump_start_height: float

var jump_start_tile: Tile
var jump_end_tile: Tile

var current_altitude: int


# Speed #
var speed_normal: int = 50
var speed_current: int = speed_normal


# Tiles #
var current_tile_position: Vector2i
var previous_tile_position: Vector2i


# Collisions #
var collision_value_current: int = 32

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
	
	shadow = $"Shadow"
	
	# Placing all names of signals here with a random function call so that the debugger stops yelling at me for "never explicitly using" the signal within its class.
	target_player.is_null()
	target_closest_food_buddy.is_null()
	killed_target.is_null()
	move_towards_target.is_null()
	feet_collide_start.is_null()
	update_altitude.is_null()
	fall_starting.is_null()
	fall_ending.is_null()
	die.is_null()
	
	# Determine if the Character is on the ground, then set their collision value to 1 for proper on-ground collisions
	if current_altitude == 0:
		set_collision_value(1)
	
	# Otherwise, the Character is on a platform, so set their collision value to 3 for proper on-platform collisions
	else:
		set_collision_value(3)
	
	# Update the Character's center point based on their global position and their width and height based on the current sprite frame
	update_location_points()
	
	# Call the custom ready function that subclasses may have defined manually
	ready()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if current_altitude > 0:
		on_platform = true
	else:
		on_platform = false
	
	
	# Determine if the Character's processing is not paused
	if not paused:
		
		# Call the custom process function that subclasses may have defined manually
		process(delta)
		
		# Update the (x,y) coordinates of the Character's locaiton point
		update_location_points()



# Called every frame. Updates the Enemy's physics
func _physics_process(delta: float) -> void:
	
	# Determine if the Character's processing is not paused
	if not paused:
	
		# Call the custom physics process function that subclasses may have defined manually
		physics_process(delta)

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Calculates the location point of the Character by taking its current position and adjusting it by the width and height of the current Sprite frame to get the location coordinates
func update_location_points():
	
	# Store a reference to the current Sprite frame of the Character's animation
	var frame_texture: Texture2D = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	
	# Determine if the current Sprite frame was found, then store the width and height of the frame
	if frame_texture != null:
		
		# Store the current width and height of the Character's current Sprite frame
		width = frame_texture.get_width()
		height = frame_texture.get_height()
	
	# Store the current coordinates for the center of this Character
	center_point.x = global_position.x
	center_point.y = global_position.y - (height / 2)



# Returns the name of a Character's Enum value based on the number it is associated with
func get_enum_value_name(enum_target: Dictionary, enum_number: int) -> String:
	
	# Iterate over each enum name
	for enum_name in enum_target:
		
		# Determine if the enum_name's corresponding value matches the given value
		if enum_target[enum_name] == enum_number:
			return enum_name
	
	# Return an empty String because there are no enum names that correspond to the given number
	return ""



# Enables the collision layer and mask of the Character for the given collision_value
func set_collision_value(new_collision_value: int):
	
	# Determine if the given collision value is NOT within the range of a valid value or is the same as the current value, then return
	if new_collision_value < 1 or new_collision_value > 32 or new_collision_value == collision_value_current:
		return
	
	# Disable collisions on the current layer and mask
	set_collision_layer_value(collision_value_current, false)
	set_collision_mask_value(collision_value_current, false)
	
	# Update the current collision value to be the given new collision value
	collision_value_current = new_collision_value
	
	# Otherwise, enable the given layer and mask value
	set_collision_layer_value(new_collision_value, true)
	set_collision_mask_value(new_collision_value, true)



# Start the Character's falling
func fall_start():
	pass



# Process the Character's falling
func fall_process(_delta: float):
	pass



# End the Character's falling
func fall_end():
	pass



# Starts the Character's jump
func jump_start():
	
	# Set the Character to collide on layer 2 (EnvironmentAssets)
	set_collision_value(2)
	
	# Enable jumping as the Character prepares to ascend and disable falling until they begin to descend
	is_jumping = true
	is_falling = false
	
	# Store the height that the jump is starting from as the Character's bottom point and also set that as the initial landing height
	jump_start_height = global_position.y
	jump_landing_height = jump_start_height
	
	# Store an initial starter value for the peak height of the jump
	jump_peak_height = jump_landing_height + 1
	
	# Apply upward velocity
	velocity.y -= jump_velocity
	
	# Set the Character's shadow's initial position to be 
	shadow.global_position.y = jump_landing_height



# Process the ascending portion of the jump (the portion of the jump in which the Character hasn't reached a peak height of the jump)
func jump_ascend(_delta: float):
	
	# Determine if the Character's feet are higher than the currently stored peak height of the jump, then update the peak height
	if global_position.y < jump_peak_height:
		jump_peak_height = global_position.y
	
	# Otherwise, the Character has reached the peak jump so they must be falling
	else:
		is_falling = true


# Process the descending portion of the jump (the portion of the jump that occurs immediately after the Character reaches the peak height of the jump and begin to start falling)
func jump_descend():
	
	# Determine if the Character's feet are lower than the height they were supposed to land at, then adjust them so they're at the proper height and end the jump
	if global_position.y >= jump_landing_height:
		global_position.y -= global_position.y - jump_landing_height
		jump_end()



# Processes the Character's jump
func jump_process(delta: float):
	
	# Apply gravity to the Character
	velocity.y += gravity * delta
	
	shadow.global_position.y = jump_landing_height
	
	# Determine if the Character is not falling, then process the jump's ascension
	if !is_falling:
		jump_ascend(delta)
	
	# Otherwise, process the jump's descension
	else:
		jump_descend()



# Ends the Character's jump
func jump_end():
	
	is_jumping = false
	is_falling = false
	velocity.y = 0
	
	update_altitude.emit(self)
	
	if current_altitude == 0:
		set_collision_value(1)
	else:
		set_collision_value(3)
	
	shadow.global_position.y = global_position.y

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ABSTRACT FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# A custom ready function that each Enemy subclass should personally define. This is called in the default Enemy class's '_ready()' function
func ready():
	pass



# A custom process function that each Enemy subclass should personally define. This is called in the default Enemy class's '_process()' function
func process(_delta: float):
	pass



# A custom physics_process function that each Enemy subclass should personally define. This is called in the default Enemy class's '_physics_process()' function
func physics_process(_delta: float) -> void:
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
