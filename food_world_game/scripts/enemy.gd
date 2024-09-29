class_name Enemy

extends CharacterBody2D

# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Animations #
var sprite: AnimatedSprite2D
var animation_player: AnimationPlayer

# Hitbox #
var hitbox: Area2D

# On-Screen Notifier #
var on_screen_notifier: VisibleOnScreenNotifier2D

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

signal die

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Health #
var health_current: int
var health_max: int

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Store references to the Enemy's Nodes
	sprite = $AnimatedSprite2D
	animation_player = $AnimationPlayer
	hitbox = $Area2D
	on_screen_notifier = $VisibleOnScreenNotifier2D



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



# Called every frame. Updates the Player's physics
func _physics_process(delta: float) -> void:
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# A custom ready function that each Enemy subclass should personally define. This is called in the default Enemy class's '_ready()' function
func ready():
	pass



# A custom process function that each Enemy subclass should personally define. This is called in the default Enemy class's '_process()' function
func process():
	pass



# A custom physics_process function that each Enemy subclass should personally define. This is called in the default Enemy class's '_physics_process()' function
func physics_process(delta: float) -> void:
	pass




#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
