class_name Juicebox

extends Node2D


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var animator: AnimationPlayer

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
	#throw_start(Vector2(620, 480), Direction.RIGHT, Direction.UP)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# If the juicebox is in midair, process its trajectory
	if in_air:
		throw_process(delta)
	
	# Otherwise, if the juicebox isn't in the air and isn't exploding, it must have already been thrown and exploded, so delete it
	elif animator.current_animation != "explosion":
		print("juicebox removed")
		queue_free()



# Called every frame. Updates the Enemy's physics
func _physics_process(delta: float) -> void:
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

func throw_start(destination: Vector2, direction_horizontal: Direction, direction_vertical: Direction):
	
	# If the juicebox hasn't already been thrown
	if !in_air:
		
		# Calculate and store all points of interest in the juice box's path
		position_start = global_position
		position_end = destination
		position_middle = Vector2(position_start.x + (direction_horizontal * abs(position_start.x - position_end.x)), position_end.y - 50)		# Subtract 50 from the difference in y positions so that the throw always peaks 50 px above its landing point
		
		# Set the current position of the juicebox at the start and its target to the middle
		position_current = position_start
		position_target = position_end
		
		throw_direction_horizontal = direction_horizontal
		throw_direction_vertical = direction_vertical
		
		# Trigger the in-air state and animation
		in_air = true
		animator.play("in-air")
	
	print("Start: ", position_start)
	print("Middle: ", position_middle)
	print("End: ", position_end)


func throw_process(delta: float):
	
	# If the throw is close enough to its end position (within 5 px) (25 is being used instead of 5 because the distance_squared_to func is used instead of distance_to)
	if abs(position_current.x - position_target.x) >= 4:
		translate(Vector2(throw_speed * delta * throw_direction_horizontal, 0))
	
	if abs(position_current.y - position_target.y) >= 4:
		translate(Vector2(0, throw_speed * delta * throw_direction_vertical))
	
	elif abs(position_current.x - position_target.x) < 4:
		throw_end()
	
	position_current = global_position



func throw_end():
	in_air = false
	animator.play("explode")
	print("throw ended")

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
