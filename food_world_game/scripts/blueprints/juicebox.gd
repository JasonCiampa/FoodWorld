extends Node2D


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var animator: AnimationPlayer

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var position_start: Vector2
var position_end: Vector2
var position_middle: Vector2

var position_current: Vector2
var position_target: Vector2

var total_horizontal_distance: float

var deltaX: float
var deltaY: float

var throw_speed: float = 50

var in_air: bool = false
var throwing_upward: bool = true
var deltaY_adjusted: bool = false

var health: int = 25

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animator = $"Animator"
	throw_start(Vector2(620, 480), true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# If the juicebox is in midair, process its trajectory
	if in_air:
		throw_process(delta)
	
	# Otherwise, if the juicebox isn't in the air and isn't exploding, it must have already been thrown and exploded, so delete it
	elif animator.current_animation != "explosion":
		queue_free()



# Called every frame. Updates the Enemy's physics
func _physics_process(delta: float) -> void:
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

func throw_start(destination: Vector2, _throwing_upward: bool):
	
	# Indicate whether or not the throw is moving above or below the player
	throwing_upward = _throwing_upward
	
	# If the juicebox hasn't already been thrown
	if !in_air:
		
		# Calculate and store all points of interest in the juice box's path
		position_start = global_position
		position_end = destination
		position_middle = Vector2((abs(position_start.x - position_end.x) / 2), (abs(position_start.y - position_end.y) - 50))		# Subtract 50 from the difference in y positions so that the throw always peaks 50 px above its landing point
		
		# Set the current position of the juicebox at the start and its target to the middle
		position_current = position_start
		position_target = position_middle
		
		total_horizontal_distance = position_start.distance_to(position_end)
		
		# Calculate and store how much the x and y values should be adjusted each frame (based on distance of throw on each axis & throw speed- needs to be multiplied by delta time still)
		deltaX = throw_speed * (abs(position_end.x - position_start.x) / abs(position_end.y - position_start.y))
		deltaY = -1 * (throw_speed * ((abs(position_end.y - position_start.y) + 50) / abs(position_end.x - position_start.x)))		# Subtract 50 from the difference in y positions so that the throw always peaks 50 px above its landing point
		
		# Trigger the in-air state and animation
		in_air = true
		animator.play("in-air")


func throw_process(delta: float):
	
	# If the throw is moving above the player and only half the distance to the end point remains, begin descending the y
	if !deltaY_adjusted and throwing_upward and abs(position_current.x - position_end.x) < (total_horizontal_distance / 2):
		print("IN")
		print(position_current.distance_squared_to(position_end))
		deltaY = -deltaY
		deltaY_adjusted = true
	
	
	# If the throw is close enough to its end position (within 5 px) (25 is being used instead of 5 because the distance_squared_to func is used instead of distance_to)
	if position_current.distance_squared_to(position_end) > 25:
		translate(Vector2(deltaX * delta, deltaY * delta))
		position_current = global_position
	else:
		throw_end()



func throw_end():
	in_air = false
	animator.play("explode")

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
