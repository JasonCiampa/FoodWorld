class_name InteractableAsset

extends Node2D


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# VisibleOnScreenNotifier #
var on_screen_notifier: VisibleOnScreenNotifier2D

# Hitbox #
var hitbox_interaction: Area2D

# Press 'E' To Interact Label #
var label_e_to_interact: Label


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var in_range: bool = false

var center_point: Vector2

var paused: bool = false

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Store references to the InteractableAsset's Nodes
	on_screen_notifier = $"VisibleOnScreenNotifier2D"
	hitbox_interaction = $"Interaction Hitbox"
	label_e_to_interact = $"Press 'E' to Interact"



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	# Store the current coordinates for the center of this Interactable Asset (this isn't the actual center point, the height of the bush divided by 2 needs to be subtracted from the y position)
	center_point.x = global_position.x
	center_point.y = global_position.y



# Called every frame. Updates the Enemy's physics
func _physics_process(_delta: float) -> void:
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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



# A custom function to execute the InteractableAsset's logic for when the Player interacts with them
func interact_with_player(_player: Player):
	pass



# A custom function to execute the InteractableAsset's logic for when a Character interacts with them
func interact_with_character(_character: GameCharacter):
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
