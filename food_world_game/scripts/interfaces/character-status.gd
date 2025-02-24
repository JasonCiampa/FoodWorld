class_name StatusPanel

extends Control


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var health_bar: TextureProgressBar
var stamina_bar: TextureProgressBar
var xp_bar: TextureProgressBar

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
	health_bar = $"Health Bar Container/Health Bar"
	stamina_bar = $"Stamina Bar Container/Stamina Bar"
	xp_bar = $"XP Bar Container/XP Bar"
	
	health_bar.min_value = 0
	stamina_bar.min_value = 0
	xp_bar.min_value = 0
	
	health_bar.max_value = 200
	stamina_bar.max_value = 100
	xp_bar.max_value = 50
	
	health_bar.value = 200
	stamina_bar.value = 100
	xp_bar.value = 50
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("jump"):
		health_bar.value -= 20
		stamina_bar.value -= 10
		xp_bar.value -= 5



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
