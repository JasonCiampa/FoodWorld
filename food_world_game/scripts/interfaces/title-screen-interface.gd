extends Control


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var background: AspectRatioContainer
var background_copy: AspectRatioContainer
var text_title: AspectRatioContainer
var button_play: TextureButton
var button_quit: TextureButton

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var move_speed_background: int = 50

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	background = $"Background Container"
	background_copy = $"Background Container 2"
	
	text_title = $"Title Text Container"
	
	button_play = $"Play Button Container/Play Button"
	button_quit = $"Quit Button Container/Quit Button"



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	#background.global_position.x -= move_speed_background * delta
	#background_copy.global_position.x -= move_speed_background * delta
	
	#if background.global_position.x <= -3840:
		#background.global_position.x = abs(background.global_position.x + 3840)
		#background_copy.global_position.x = background.global_position.x + 3840

func _physics_process(delta: float) -> void:
	background.global_position.x -= move_speed_background * delta
	background_copy.global_position.x -= move_speed_background * delta
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

func _on_play_button_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")



func _on_quit_button_button_down() -> void:
	get_tree().quit()


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
