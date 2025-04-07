class_name Juicebox

extends Node2D


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var animator: AnimationPlayer
var sprite: AnimatedSprite2D
var hitbox_heal: Area2D

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

signal explode

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

enum Direction { 
	IDLE = 0, 
	UP = -1, 
	DOWN = 1,  
	LEFT = -1, 
	RIGHT = 1 
}#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var position_start: Vector2
var position_end: Vector2
var position_middle: Vector2

var position_current: Vector2
var position_target: Vector2

var deltaX: float
var deltaY: float

var throw_speed: float = 50
var throw_direction_vertical: Direction
var throw_direction_horizontal: Direction

var in_air: bool = false
var peaked: bool = false
var throwing_upward: bool = true
var deltaY_adjusted: bool = false

var delta_adjustment_counter: int      # How many times the delta value has been updated

var health: int = 25

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animator = $"Animator"
	sprite = $"AnimatedSprite2D"
	hitbox_heal = $"Healing Hitbox"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# If the juicebox is in midair, process its trajectory
	if in_air:
		throw_process(delta)


# Called every frame. Updates the Enemy's physics
func _physics_process(_delta: float) -> void:
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Used chatgpt to make this- but I was the one who decided to use parabolas so I feel smarts still
func get_parabola_point(start: Vector2, end: Vector2, height: float, t: float) -> Vector2:
	var normal_mid = (start + end) * 0.5
	var forward_mid = start.lerp(end, 4)  # shifted forward midpoint
	forward_mid.y -= height
	
	# Quadratic Bezier formula
	var a = start.lerp(forward_mid, t)
	var b = normal_mid.lerp(end, t)
	return a.lerp(b, t)


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

func throw_start(destination: Vector2, direction_horizontal: Direction):
	
	# If the juicebox hasn't already been thrown
	if !in_air:
		
		# Calculate and store all points of interest in the juice box's path
		position_start = global_position
		position_end = destination
		position_middle = Vector2(position_start.x + (direction_horizontal * (abs(position_start.x - position_end.x) / 2)), position_end.y - 50)		# Subtract 50 from the difference in y positions so that the throw always peaks 50 px above its landing point
		
		# Set the current position of the juicebox at the start and its target to the middle
		position_current = position_start
		position_target = position_middle
		
		# Trigger the in-air state and animation
		in_air = true
		animator.play("in-air")


func throw_process(delta: float):
	
	global_position = get_parabola_point(position_current, position_target, 0, (delta * position_current.x / position_end.x))

	position_current = global_position
	
	if abs(position_current.x - position_target.x) < 10 and abs(position_current.y - position_target.y) < 10:
		if position_target == position_middle:
			position_target = position_end
		elif position_target == position_end:
			throw_end()



func throw_end():
	in_air = false
	sprite.play("explosion")
	animator.play("explode")

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


func _on_sprite_animation_finished() -> void:
	if "explosion" == sprite.animation:
		explode.emit(self)
		queue_free()
