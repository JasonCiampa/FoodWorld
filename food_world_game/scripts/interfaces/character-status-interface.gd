class_name CharacterStatusInterface

extends Control


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var health_bar_player: TextureProgressBar
var text_health_current_player: Label
var stamina_bar_player: TextureProgressBar
var text_stamina_current_player: Label
var xp_bar_player: TextureProgressBar
var text_xp_current_player: Label
var text_level_player: Label
var text_berries_player: Label
var text_juice_player: Label
var text_juiceboxes_player: Label

var health_bar_foodbuddy1: TextureProgressBar
var text_health_current_foodbuddy1: Label
var text_name_foodbuddy1: Label
var text_fieldstate_foodbuddy1: Label

var health_bar_foodbuddy2: TextureProgressBar
var text_health_current_foodbuddy2: Label
var text_name_foodbuddy2: Label
var text_fieldstate_foodbuddy2: Label

var player: Player
var active_food_buddies: Array[FoodBuddy]
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
	text_health_current_player = $"Player Status/Health Count Text Container/Health Count Text"
	stamina_bar_player = $"Player Status/Player Stamina Container/Stamina Bar"
	text_stamina_current_player = $"Player Status/Stamina Count Text Container/Stamina Count Text"
	xp_bar_player = $"Player Status/Player XP Container/XP Bar"
	text_xp_current_player = $"Player Status/XP Count Text Container/XP Count Text"
	text_level_player = $"Player Status/Level Text Container/Level Text"
	text_berries_player = $"Player Status/Berries Text Container/Berries Text"
	text_juice_player = $"Player Status/Juice Text Container/Juice Text"
	text_juiceboxes_player = $"Player Status/Juicebox Text Container/Juicebox Text"
	
	health_bar_foodbuddy1 = $"FoodBuddy1 Status/FoodBuddy1 Health Container/FoodBuddy1 Health"
	text_health_current_foodbuddy1 = $"FoodBuddy1 Status/Health Count Text Container/Health Count Text"
	text_name_foodbuddy1 = $"FoodBuddy1 Status/Name Text Container/Name Text"
	text_fieldstate_foodbuddy1 = $"FoodBuddy1 Status/Field State Text Container/Field State Text"
	
	health_bar_foodbuddy2 = $"FoodBuddy2 Status/FoodBuddy2 Health Container/FoodBuddy2 Health"
	text_health_current_foodbuddy2 = $"FoodBuddy2 Status/Health Count Text Container/Health Count Text"
	text_name_foodbuddy2 = $"FoodBuddy2 Status/Name Text Container/Name Text"
	text_fieldstate_foodbuddy2 = $"FoodBuddy2 Status/Field State Text Container/Field State Text"

	health_bar_player.min_value = 0
	stamina_bar_player.min_value = 0
	xp_bar_player.min_value = 0
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	health_bar_player.value = player.health_current
	text_health_current_player.text = str(player.health_current) + "/" + str(player.health_max)
	stamina_bar_player.value = player.stamina_current
	text_stamina_current_player.text = str(int(player.stamina_current)) + "/" + str(player.stamina_max)
	xp_bar_player.value = player.xp_current
	text_xp_current_player.text = str(player.xp_current) + "/" + str(player.xp_max)
	text_berries_player.text = "Berries\n" + str(player.berries) + "/" + str(player.berries_max)
	text_juice_player.text = "Juice\n" + str(player.juice)
	text_juiceboxes_player.text = "Juice\nboxes\n" + str(player.juiceboxes)
	
	health_bar_foodbuddy1.value = foodbuddy1.health_current
	health_bar_foodbuddy2.value = foodbuddy2.health_current
	
	text_fieldstate_foodbuddy1.text = foodbuddy1.get_enum_value_name(FoodBuddy.FieldState, foodbuddy1.field_state_current)
	text_fieldstate_foodbuddy2.text = foodbuddy2.get_enum_value_name(FoodBuddy.FieldState, foodbuddy2.field_state_current)
	
	text_health_current_foodbuddy1.text = str(foodbuddy1.health_current) + "/" + str(foodbuddy1.health_max)
	text_health_current_foodbuddy2.text = str(foodbuddy2.health_current) + "/" + str(foodbuddy2.health_max)


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Sets the given values as the ones to use for the UI components
func setValues(_player: Player, food_buddies_active: Array[FoodBuddy]):
	
	player = _player
	active_food_buddies = food_buddies_active
	foodbuddy1 = active_food_buddies[0]
	foodbuddy2 = active_food_buddies[1]
	
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
