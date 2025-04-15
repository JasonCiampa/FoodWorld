class_name GameOverInterface

extends Control


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var button_respawn: TextureButton
var button_title: TextureButton
var button_quit: TextureButton

var text_purged: Label
var text_respawn: Label
var text_title: Label
var text_quit: Label

var animator: AnimationPlayer

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var player: Player
var active_food_buddies: Array[FoodBuddy]

var InterfaceCharacterStatus: CharacterStatusInterface
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_respawn = $"Respawn Button/Respawn Button Container/Respawn Button"
	button_title = $"Title Button/Title Button Container/Title Button"
	button_quit = $"Quit Button/Quit Button Container/Quit Button"
	text_purged = $"Purged Text Container/Purged Text"
	text_respawn = $"Respawn Button/Respawn Text Container/Respawn Text"
	text_title = $"Title Button/Title Text Container/Title Text"
	text_quit  = $"Quit Button/Quit Text Container/Quit Text"
	animator = $"Animator"



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _physics_process(_delta: float) -> void:
	pass


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Sets the given values as the ones to use for the UI components
func setValues(_player: Player, _food_buddies_active: Array[FoodBuddy], _InterfaceCharacterStatus: CharacterStatusInterface):
	
	player = _player
	active_food_buddies = _food_buddies_active
	
	InterfaceCharacterStatus = _InterfaceCharacterStatus


func game_over(freeze_subjects: Array[Node2D]):
	
	# Pause all of the characters' processing while the interface is active
	for subject in freeze_subjects:
		subject.paused = true
	
	# Set the UI to be visible and processing
	self.visible = true
	self.process_mode = Node.PROCESS_MODE_INHERIT
	
	# INSTEAD OF MOVING ACTUAL FOOD BUDDIES, HIDE THEM AND THEIR PROCESSING- BUT SPAWN ANIMATEDSPRITE2DS OF THOSE FOOD BUDDIES NEXT TO THE PLAYER AND MAKE EM DANCE!!
	active_food_buddies[0].global_position = player.global_position
	active_food_buddies[0].global_position.x -= 48
	
	active_food_buddies[1].global_position = player.global_position
	active_food_buddies[1].global_position.x += 48
	
	# Animate the UI onto the screen, then have it stay in place
	animator.play("enter_UI")
	animator.queue("stay_UI")
	
	active_food_buddies[0].sprite.play("die_front")
	active_food_buddies[1].sprite.play("die_front")
	
	for buddy in active_food_buddies:
		buddy.sprite.play("die_front")
		buddy.animation_player.play("RESET")
		
		if buddy.name == "Dan":
			buddy.sprinkle_sprite.play("nothing")
	
	InterfaceCharacterStatus.visible = false
	
	# Iterate over each tilemap that could be on screen right now and disable it
	for tilemap in player.current_tilemaps:
		tilemap.modulate.a = 0
	
	# Determine if the food buddies have different tilemaps than the player
	if player.current_tilemaps[0] != active_food_buddies[0].current_tilemaps[0] or player.current_tilemaps[0] != active_food_buddies[1].current_tilemaps[0]:
		
		# Iterate over each tilemap that could be on screen right now and disable it
		for tilemap in active_food_buddies[0].current_tilemaps:
			tilemap.modulate.a = 0
		
		for tilemap in active_food_buddies[1].current_tilemaps:
			tilemap.modulate.a = 0

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


func _on_respawn_button_button_down() -> void:
	get_tree().reload_current_scene()


func _on_title_button_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/interfaces/title-screen-interface.tscn")


func _on_quit_button_button_down() -> void:
	get_tree().quit()
