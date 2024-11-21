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

signal jump_starting
signal jump_ending

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
var jump_peak_height: float
var jump_landing_height: float
var jump_start_height: float
var jump_start_tile: Tile
var jump_end_tile: Tile

var is_falling: bool = false

var current_altitude: float = 0

const jump_velocity: int = 200

# Speed #
var speed_normal: int = 50
var speed_current: int = speed_normal

# Tiles #
var current_tile_position: Vector2i
var previous_tile_position: Vector2i
var on_platform: bool

var collision_value_current: int

@onready var jump_timer: Timer = $"Jump Timer"
@onready var shadow: Polygon2D = $Shadow

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



# Enables the collision layer and mask of the Character for the given collision_value
func set_collision_value(new_collision_value: int):
	
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
func fall_process(delta: float):
	pass



# End the Character's falling
func fall_end():
	pass



# Starts the Character's jump
func jump_start():
	
	# Disable all collisions for this Character
	set_collision_value(6)
	
	# Enable jumping as the Character prepares to ascend and disable falling until they begin to descend
	is_jumping = true
	is_falling = false
	
	# Store the height that the jump is starting from as the Character's bottom point and also set that as the initial landing height
	jump_start_height = bottom_point.y
	jump_landing_height = jump_start_height
	
	# Store an initial starter value for the peak height of the jump
	jump_peak_height = jump_landing_height + 1
	
	# Apply upward velocity
	velocity.y -= jump_velocity
	
	# Set the Character's shadow's initial position to be 
	shadow.position.y = jump_landing_height - global_position.y - 10
	
	# Emit a signal to the game indicating that this Character is starting their jump
	jump_starting.emit(self)


# Process the ascending portion of the jump (the portion of the jump in which the Player hasn't reached a peak height of the jump)
func jump_ascend(delta: float):
	
	# Determine if the Character's feet are higher than the currently stored peak height of the jump, then update the peak height
	if bottom_point.y < jump_peak_height:
		jump_peak_height = bottom_point.y
	
	# Otherwise, the Character has reached the peak jump so they must be falling
	else:
		is_falling = true



# Process the descending portion of the jump (the portion of the jump that occurs immediately after the Player reaches the peak height of the jump and begin to start falling)
func jump_descend(delta: float):
	
	# Determine if the Character's feet are lower than the height they were supposed to land at, then adjust them so they're at the proper height and end the jump
	if bottom_point.y >= jump_landing_height:
		position.y -= bottom_point.y - jump_landing_height
		jump_end()


# Processes the Player's jump
func jump_process(delta: float):
	
	# Apply gravity to the Character
	velocity.y += gravity * delta
	
	# Update the Shadow's position
	shadow.position.y = jump_landing_height - global_position.y - 22
	shadow.z_index = 800
	
	# Determine if the Character is not falling, then process the jump's ascension
	if !is_falling:
		jump_ascend(delta)
	
	# Otherwise, process the jump's descension
	else:
		jump_descend(delta)



# Ends the Player's jump
func jump_end():
	
	# Set the Character to collide with layer 1 (on top of a tile)
	set_collision_value(3)
	
	
	is_jumping = false
	is_falling = false
	velocity.y = 0
	
	# Emit a signal to the game indicating that this Character is ending their jump
	jump_ending.emit(self)

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
