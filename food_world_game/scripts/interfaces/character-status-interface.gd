class_name CharacterStatusInterface

extends Control


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var health_bar_player: TextureProgressBar
var stamina_bar_player: TextureProgressBar
var xp_bar_player: TextureProgressBar
var text_level_player: Label

var health_bar_foodbuddy1: TextureProgressBar
var text_name_foodbuddy1: Label

var health_bar_foodbuddy2: TextureProgressBar
var text_name_foodbuddy2: Label

var player: Player
var foodbuddy1: FoodBuddy
var foodbuddy2: FoodBuddy

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
	health_bar_player = $"Player Status/Player Health Container/Player Health"
	stamina_bar_player = $"Player Status/Player Stamina Container/Stamina Bar"
	xp_bar_player = $"Player Status/Player XP Container/XP Bar"
	text_level_player = $"Player Status/Level Text Container/Level Text"
	
	health_bar_foodbuddy1 = $"FoodBuddy1 Status/FoodBuddy1 Health Container/FoodBuddy1 Health"
	text_name_foodbuddy1 = $"FoodBuddy1 Status/Name Text Container/Name Text"
	
	health_bar_foodbuddy2 = $"FoodBuddy2 Status/FoodBuddy2 Health Container/FoodBuddy2 Health"
	text_name_foodbuddy2 = $"FoodBuddy2 Status/Name Text Container/Name Text"
	
	health_bar_player.min_value = 0
	stamina_bar_player.min_value = 0
	xp_bar_player.min_value = 0
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	health_bar_player.value = player.health_current
	stamina_bar_player.value = player.stamina_current
	xp_bar_player.value = player.xp_current
	
	health_bar_foodbuddy1.value = foodbuddy1.health_current
	health_bar_foodbuddy2.value = foodbuddy2.health_current



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Sets the given values as the ones to use for the UI components
func setValues(_player: Player, _foodbuddy1: FoodBuddy, _foodbuddy2: FoodBuddy):
	
	player = _player
	foodbuddy1 = _foodbuddy1
	foodbuddy2 = _foodbuddy2
	
	health_bar_player.max_value = player.health_max
	health_bar_player.value = player.health_current
	
	stamina_bar_player.max_value = player.stamina_max
	stamina_bar_player.value = player.stamina_current
	
	xp_bar_player.max_value = player.xp_max
	xp_bar_player.value = player.xp_current
	
	text_level_player.text = str("Lvl ", player.level_current)
	
	text_name_foodbuddy1.text = foodbuddy1.name
	health_bar_foodbuddy1.max_value = foodbuddy1.health_max
	health_bar_foodbuddy1.texture_progress = load(foodbuddy1.health_texture_path)
	
	text_name_foodbuddy2.text = foodbuddy2.name
	health_bar_foodbuddy2.max_value = foodbuddy2.health_max
	health_bar_foodbuddy2.texture_progress = load(foodbuddy2.health_texture_path)

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
