class_name EnergyBall

extends Node2D


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var animator: AnimationPlayer
var sprite: AnimatedSprite2D
var hitbox_damage: Area2D

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

var paused: bool

var position_start: Vector2
var position_end: Vector2
var position_middle: Vector2

var position_current: Vector2
var position_target: Vector2

var deltaX: float
var deltaY: float

var throw_speed: float = 2
var throw_direction_vertical: Direction
var throw_direction_horizontal: Direction

var in_air: bool = false
var peaked: bool = false
var throwing_upward: bool = true
var deltaY_adjusted: bool = false

var delta_adjustment_counter: int      # How many times the delta value has been updated

var damage: int = 25

var target: GameCharacter

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animator = $"Animator"
	sprite = $"AnimatedSprite2D"
	hitbox_damage = $"Damage Hitbox"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if paused:
		sprite.pause()
		animator.pause()
		return
	else:
		sprite.play()
		animator.play()
	
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
		
		# Set the current position of the juicebox at the start and its target to the middle
		position_current = position_start
		position_target = position_end
		
		# Trigger the in-air state and animation
		in_air = true
		animator.play("in-air")


func throw_process(delta: float):
	
	global_position = global_position.lerp(position_end, (delta * throw_speed))

	position_current = global_position
	
	# Determine if the target's hitbox is in the list of hitboxes that the attack's hitbox overlapped with, then reduce their health
	if target != null and target.hitbox_damage in hitbox_damage.get_overlapping_areas() and global_position.distance_to(Vector2(target.global_position.x, target.global_position.y - target.height / 2)) < 12.5:
		throw_end()
	
	elif abs(position_current.x - position_target.x) < 10 and abs(position_current.y - position_target.y) < 10:
		if position_target == position_end:
			throw_end()



func throw_end():
	z_index = 1
	in_air = false
	sprite.play("explosion")
	explode.emit(self)
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
		queue_free()
