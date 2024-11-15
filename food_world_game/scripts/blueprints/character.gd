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

var feet: Node2D

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
const jump_velocity: int = 250

# Speed #
var speed_normal: int = 50
var speed_current: int = speed_normal

# Tiles #
var current_tile: Vector2i
var previous_tile: Vector2i

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Store references to the Character's Nodes
	sprite = $AnimatedSprite2D
	animation_player = $AnimationPlayer
	on_screen_notifier = $VisibleOnScreenNotifier2D
	hitbox_damage = $"Damage Hitbox"
	feet = $Feet

	
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
