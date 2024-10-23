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
var width: float
var height: float

# Health #
var health_current: int
var health_max: int
var alive: bool = true

# Target #
var target: Node2D = null
var target_distance: float

# Speed #
var speed_normal: int = 50
var speed_current: int = speed_normal

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Store references to the Character's Nodes
	sprite = $AnimatedSprite2D
	animation_player = $AnimationPlayer
	on_screen_notifier = $VisibleOnScreenNotifier2D
	hitbox_damage = $"Damage Hitbox"
	
	# Call the custom ready function that subclasses may have defined manually
	ready()
	
	update_center_point()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if not paused:
		
		# Call the custom process function that subclasses may have defined manually
		process(delta)




# Called every frame. Updates the Enemy's physics
func _physics_process(delta: float) -> void:
	
	if not paused:
	
		# Call the custom physics process function that subclasses may have defined manually
		physics_process(delta)
	
	update_center_point()
	
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------






# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Calculates the center point of the Character by taking its current position (bottom left of sprite) and adjusting it by the width and height of the current Sprite frame to get the center coordinates
func update_center_point():
	var frame_texture: Texture2D = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	
	width = frame_texture.get_width()
	height = frame_texture.get_height()
	
	center_point.x = position.x + width / 2
	center_point.y = position.y - height / 2



# Returns the name of the Food Buddy's FieldState Enum value based on the number it is associated with
func get_enum_value_name(enum_target: Dictionary, enum_number: int) -> String:
	
	for name in enum_target:
		if enum_target[name] == enum_number:
			return name
	
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
