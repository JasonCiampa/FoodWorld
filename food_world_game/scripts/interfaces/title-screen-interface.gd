extends Control


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var background: AspectRatioContainer
var background_copy: AspectRatioContainer
var text_title: AspectRatioContainer
var button_play: TextureButton
var button_quit: TextureButton
var timer_fade: Timer

var brittany1: AnimatedSprite2D
var brittany2: AnimatedSprite2D

var dan1: AnimatedSprite2D
var dan2: AnimatedSprite2D

var link1: AnimatedSprite2D
var link2: AnimatedSprite2D

var MUSIC: AudioStreamPlayer


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var move_speed_background: int = 50
var screen_fading: bool = false
var fade_out_duration: float = 4

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	background = $"Background Container"
	background_copy = $"Background Container 2"
	
	text_title = $"Title Text Container"
	
	button_play = $"Play Button Container/Play Button"
	button_quit = $"Quit Button Container/Quit Button"
	
	timer_fade = $"Fade Timer"
	
	brittany1 = $"Background Container/Brittany"
	brittany2 = $"Background Container 2/Brittany"

	dan1 = $"Background Container/Dan"
	dan2 = $"Background Container 2/Dan"

	link1 = $"Background Container/Link"
	link2 = $"Background Container 2/Link"
	
	brittany1.play("idle_front")
	brittany2.play("idle_front")

	dan1.play("idle_front")
	dan2.play("idle_front")

	link1.play("idle_front")
	link2.play("idle_front")
	
	
	MUSIC = $"FoodWorldTheme"
	
	MUSIC.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if background.global_position.x <= -3840:
		background.global_position.x = abs(background.global_position.x + 3840)
		background_copy.global_position.x = background.global_position.x + 3840
	
	if screen_fading:
		fade_screen(0, delta)

func _physics_process(delta: float) -> void:
	background.global_position.x -= move_speed_background * delta
	background_copy.global_position.x -= move_speed_background * delta
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

func _on_play_button_button_down() -> void:
	screen_fading = true
	timer_fade.start(3)



func _on_quit_button_button_down() -> void:
	get_tree().quit()


# Fades the screen to black for the given "fade out" parameter, then back to the game for the given "fade in" parameter
func fade_screen(final_opacity: float, delta: float):
	
	# Determine if the timer_fade is stopped and that the opacity isn't all the way down yet, then decrement the opacity further
	if !timer_fade.is_stopped() and modulate.a > final_opacity:
		modulate.a = modulate.a - 0.7 * delta
		MUSIC.volume_db = lerp(MUSIC.volume_db, float(-80), delta * (fade_out_duration - timer_fade.time_left) / fade_out_duration)
	
	else:
		screen_fading = false
		timer_fade.stop()
		MUSIC.stop()
		
		get_tree().change_scene_to_file("res://scenes/game.tscn")

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
