extends Control

class_name BerryBotInterface


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var text_berry_count: Label
var text_sauna_occupancy: Label

var text_juicebox_count: Label
var text_juice_count: Label
var text_craft_count: Label
var text_craft_cost: Label

var button_deposit: TextureButton
var button_craft: TextureButton
var button_increment_craft_count: TextureButton
var button_decrement_craft_count: TextureButton

var image_juice_pipe: TextureRect

var animator: AnimationPlayer

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var active_food_buddies: Array[FoodBuddy]

var frozen_subjects: Array[Node2D]

var player: Player
var brittany: FoodBuddy

var sauna_current_occupant_times: Array[float]
var sauna_occupant_stay_time: int = 15
var sauna_occupant_juice_drop: int = 10
var sauna_occupancy_max: int = 15

var juicebox_cost: int = 50

var craft_count_max: int = 20



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text_berry_count = $"Sauna/Berries/Berries Text Container/Berries Text"
	text_sauna_occupancy = $"Sauna/Occupancy/Occupancy Text Container/Occupancy Text"
	text_juicebox_count = $"Crafting/Juice Boxes/Juice Boxes Text Container/Juice Boxes Text"
	text_juice_count = $"Crafting/Juice/Juice Text Container/Juice Text"
	text_craft_count = $"Crafting/Count/Count Text Container/Count Text"
	text_craft_cost = $"Crafting/Cost/Cost Text Container/Cost Text"
	button_deposit = $"Sauna/Deposit/Deposit Button Container/Deposit Button"
	button_craft = $"Crafting/Craft/Craft Button Container/Craft Button"
	button_increment_craft_count = $"Crafting/Count/Count Increment Button Container/Count Increment Button"
	button_decrement_craft_count = $"Crafting/Count/Count Decrement Button Container/Count Decrement Button"
	image_juice_pipe = $"Pipe/Pipe Image Container/Pipe Image"
	animator = $"Animator"



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# Iterate over 
	for time in range(sauna_current_occupant_times.size() - 1, -1, -1):
		
		if sauna_current_occupant_times[time] < sauna_occupant_stay_time:
			sauna_current_occupant_times[time] += delta
		else:
			sauna_current_occupant_times.remove_at(time)
			player.juice += sauna_occupant_juice_drop
			text_juice_count.text = str("Juice: ", player.juice)
			text_sauna_occupancy.text = str("Sauna Occupancy: ", sauna_current_occupant_times.size())
			
			if int(text_craft_count.text) * juicebox_cost > player.juice:
				button_craft.disabled = true
			else:
				button_craft.disabled = false
			
			if sauna_current_occupant_times.size() < sauna_occupancy_max and player.berries > 0:
				button_deposit.disabled = false



# Called every frame. Updates the Enemy's physics
func _physics_process(_delta: float) -> void:
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Sets the given values as the ones to use for the UI components
func setValues(_player: Player, _brittany: FoodBuddy):
	
	player = _player
	brittany = _brittany
	
	text_berry_count.text = "Berries: " + str(player.berries) + "/" + str(player.berries_max)
	text_sauna_occupancy.text = str("Sauna Occupancy: ", 0)
	text_juicebox_count.text = "Juice Boxes: " + str(player.juiceboxes)
	text_juice_count.text = "Juice: " + str(player.juice)
	text_craft_count.text = "1"
	text_craft_cost.text = str("Cost: ", juicebox_cost)
	
	#button_deposit.disabled = true
	#button_craft.disabled = true
	#button_increment_craft_count.disabled = true
	button_decrement_craft_count.disabled = true




# Enables the Food Buddy FieldState Interface and freezes the updating for the given subjects while the Interface is active
func start(_freeze_subjects: Array[Node2D]):
	
	# Store the currently frozen subjects so they can be unfrozen when selection is complete
	frozen_subjects = _freeze_subjects
	
	# Pause all of the characters' processing while the interface is active
	for subject in frozen_subjects:
		subject.paused = true
	
	# Set the UI to be visible and processing
	self.visible = true
	self.process_mode = Node.PROCESS_MODE_INHERIT
	
	## Animate the UI onto the screen, then have it stay in place
	#animator.play("enter_UI")
	#animator.queue("stay_UI")
	
	# Iterate over each tilemap that could be on screen right now and disable it
	for tilemap in player.current_tilemaps:
		tilemap.modulate.a = 0.25
	
	var craft_count = int(text_craft_count.text)
	
	# Determine if the cost of crafting craft_count juiceboxes is higher than the amount of juice the player has currently
	if craft_count * juicebox_cost > player.juice:
		button_craft.disabled = true
	else:
		button_craft.disabled = false
	
	if craft_count == 1:
		button_decrement_craft_count.disabled = true
	elif craft_count == craft_count_max:
		button_increment_craft_count.disabled = true
	else:
		button_decrement_craft_count.disabled = false
		button_increment_craft_count.disabled = false
	
	if player.berries == 0:
		button_deposit.disabled = true
	else:
		button_deposit.disabled = false
	
	text_berry_count.text = str("Berries: ", player.berries)



# Disables the Food Buddy FieldState Interface
func end():
	
	# Pause all of the characters' processing while the interface is active
	for subject in frozen_subjects:
		subject.paused = false
	
	# Iterate over each tilemap that could be on screen right now and disable it
	for tilemap in player.current_tilemaps:
		tilemap.modulate.a = 1
	
	# Set the UI to be invisible and not processing
	self.visible = false
	
	#animator.play("RESET")


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


func _on_exit_button_down() -> void:
	end()
	player.is_interacting = false


func _on_craft_count_decrement_button_down() -> void:
	var craft_count = int(text_craft_count.text) - 1
	
	if craft_count == 1:
		button_decrement_craft_count.disabled = true
	elif craft_count < craft_count_max:
		button_increment_craft_count.disabled = false
	
	# Determine if the cost of crafting craft_count juiceboxes is higher than the amount of juice the player has currently
	if craft_count * juicebox_cost > player.juice:
		button_craft.disabled = true
	else:
		button_craft.disabled = false
	
	text_craft_cost.text = str("Cost: ", craft_count * juicebox_cost)
	text_craft_count.text = str(craft_count)


func _on_craft_count_increment_button_down() -> void:
	var craft_count: int = int(text_craft_count.text) + 1
	
	if craft_count == craft_count_max:
		button_increment_craft_count.disabled = true
	elif craft_count > 1:
		button_decrement_craft_count.disabled = false
	
	# Determine if the cost of crafting craft_count juiceboxes is higher than the amount of juice the player has currently
	if craft_count * juicebox_cost > player.juice:
		button_craft.disabled = true
	else:
		button_craft.disabled = false
	
	text_craft_cost.text = str("Cost: ", craft_count * juicebox_cost)
	text_craft_count.text = str(craft_count)

func _on_craft_button_down() -> void:
	
	var craft_count: int = int(text_craft_count.text)
	var craft_cost: int = craft_count * juicebox_cost
	
	# Determine if the cost of crafting craft_count juiceboxes is higher than the amount of juice the player has currently
	if craft_count * juicebox_cost <= player.juice:
		player.juice -= craft_count * juicebox_cost
		text_juice_count.text = str("Juice: ", player.juice)
		
		player.juiceboxes += craft_count
		text_juicebox_count.text = str("Juice Boxes: ", player.juiceboxes)
		
		if craft_count * juicebox_cost >= player.juice:
			button_craft.disabled = true
		
	else:
		button_craft.disabled = true


func _on_deposit_button_down() -> void:
	
	var sauna_occupancy: int = int(text_sauna_occupancy.text)
	
	
	# Until the sauna reaches full capacity or the player runs out of berries, add berries to the sauna
	if sauna_occupancy < sauna_occupancy_max and player.berries > 0:
		sauna_occupancy += 1
		player.berries -= 1
		
		if sauna_occupancy == sauna_occupancy_max or player.berries == 0:
			button_deposit.disabled = true
		
		text_sauna_occupancy.text = str("Sauna Occupancy: ", sauna_occupancy)
		text_berry_count.text = str("Berries: ", player.berries)
		sauna_current_occupant_times.append(0)
