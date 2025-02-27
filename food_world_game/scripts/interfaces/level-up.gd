extends Control


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var text_level_up: Label
var text_choose_upgrade: Label

var button_health: TextureButton
var text_health: Label

var button_stamina: TextureButton
var text_stamina: Label

var button_power: TextureButton
var text_power: Label

var player: Player
var foodbuddy1: FoodBuddy
var foodbuddy2: FoodBuddy
var character_status: StatusPanel

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
	
	text_level_up = $"Level-Up/Level-up Text Container/Level-up Text"
	text_choose_upgrade = $"Choose Upgrade/Choose Upgrade Container/Choose Upgrade Text"
	
	button_health = $"Health/Health Button Container/Health Button"
	text_health = $"Health/Health Text Container/Health Text"
	
	button_stamina = $"Stamina/Stamina Button Container/Stamina Button"
	text_stamina = $"Stamina/Stamina Text Container/Stamina Text"
	
	button_power = $"Power/Power Button Container/Power Button"
	text_power = $"Power/Power Text Container/Power Text"



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Sets the given values as the ones to use for the UI components
func setValues(_player: Player, _foodbuddy1: FoodBuddy, _foodbuddy2: FoodBuddy, _character_status: StatusPanel):
	
	player = _player
	foodbuddy1 = _foodbuddy1
	foodbuddy2 = _foodbuddy2
	character_status = _character_status



func _on_health_button_button_down() -> void:
	player.health_max += 5
	foodbuddy1.health_max += 5
	foodbuddy2.health_max += 5
	
	player.health_current = player.health_max
	foodbuddy1.health_current = foodbuddy1.health_max
	foodbuddy2.health_current = foodbuddy2.health_max
	
	character_status.health_bar_player.max_value = player.health_max
	character_status.health_bar_foodbuddy1.max_value = foodbuddy1.health_max
	character_status.health_bar_foodbuddy2.max_value = foodbuddy2.health_max
	print(player.health_current)


func _on_stamina_button_button_down() -> void:
	player.stamina_max += 5
	print(player.stamina_max)
	
	player.stamina_max += 5
	player.stamina_current = player.stamina_max
	
	character_status.stamina_bar_player.max_value = player.stamina_max



func _on_power_button_button_down() -> void:
	player.attack_damage["Kick"] = player.attack_damage["Kick"] + 3
	player.attack_damage["Punch"] = player.attack_damage["Punch"] + 3
	print(player.attack_damage)

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
