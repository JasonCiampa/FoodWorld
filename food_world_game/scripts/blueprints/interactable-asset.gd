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

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Store references to the InteractableAsset's Nodes
	on_screen_notifier = $"VisibleOnScreenNotifier2D"
	hitbox_interaction = $"Interaction Hitbox"
	label_e_to_interact = $"Press 'E' to Interact"
	
	
	print("Tile Object successfully loaded in at: " + str(global_position))




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



# Called every frame. Updates the Enemy's physics
func _physics_process(delta: float) -> void:
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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



# A custom function to execute the InteractableAsset's logic for when the Player interacts with them
func interact_with_player(player: Player, characters_in_range: Array[Node2D]):
	pass



# A custom function to execute the InteractableAsset's logic for when a Character interacts with them
func interact_with_character(character: GameCharacter, characters_in_range: Array[Node2D]):
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
