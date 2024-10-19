class_name FoodCitizen

extends CharacterBody2D



# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Animations #
var sprite: AnimatedSprite2D
var animation_player: AnimationPlayer

# On-Screen Notifier #
var on_screen_notifier: VisibleOnScreenNotifier2D

# Hitboxes #
var hitbox_damage: Area2D
var hitbox_dialogue: Area2D

# Press 'E' To Interact Label #
var label_e_to_interact: Label

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
	
	# Store references to the Citizen's Nodes
	sprite = $AnimatedSprite2D
	animation_player = $AnimationPlayer
	on_screen_notifier = $VisibleOnScreenNotifier2D
	hitbox_damage = $"Damage Hitbox"
	hitbox_dialogue = $"Dialogue Hitbox"
	label_e_to_interact = $"Press 'E' to Interact"
	
	self.name = "Citizen"



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



# Called every frame. Updates the Enemy's physics
func _physics_process(delta: float) -> void:
	target_player.emit(self)
	move_towards_target.emit(self, target, 40)
	move_and_slide()

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------






# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# ABSTRACT FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
