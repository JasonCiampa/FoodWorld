extends Node2D

class_name DialogueInterface


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Interface State #
var active: bool = false
var sleeping: bool = false

# Dialogue State #
var current_dialogue: Dialogue
var characters_active: Array[Node2D]
var initiator: Node2D
var dialogue_moving_forwards: bool
var line_displayed: bool

# Script Directions #
var script_directions: Dictionary = {"GAME": {"Direction": "", "Processing": false}, "DIALOGUE": {"Direction": "", "Processing": false}}
var game_direction: String
var dialogue_direction: String

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass



# Called every frame. Updates the Enemy's physics
func _physics_process(_delta: float) -> void:
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Puts the Dialogue Interface to sleep so that it will not process Dialogue and Player Input until it wakes
func sleep():
	
	# Determine if the Dialogue Interface is not already asleep, then play an animation to put it so sleep
	if not sleeping:
		pass
		# Play an animation to hide the Dialogue Interface
	
	# Set the interface to be sleeping so it remains active but none of the Dialogue is updated
	sleeping = true



# Wakes up the Dialogue Interface so that it will begin processing Dialogue and Player Input again
func wake():
	
	# Determine if the Dialogue Interface is asleep, then play an animation to wake it
	if sleeping:
		pass
		# Play an animation to show the Dialogue Interface
	
	# Set the interface to not be sleeping so it starts updating Dialogue again
	sleeping = false



# Enables and prepares the Dialogue Interface and freezes the updating for the given subjects while the Interface is active
func enable(dialogue_characters: Array[Node2D], dialogue_initiator: Node2D, freeze_subjects: Array[Node2D], conversation_name: String = "") -> void:
	
	# Create an empty Array that will hold Character names
	var character_names: Array[String] = []
	
	# Add each Character's name to the list
	for character in dialogue_characters:
		character_names.append(character.name)
	
	# Sort the Array of Character names alphabetically
	character_names.sort()
	
	# Create an empty String that will hold the name of the Dialogue Resource file to load into the Dialogue Interface
	var file_name: String = ""
	
	# Generate the name of the Dialogue Resource file by formatting each Character's name into the file name
	for name_index in character_names.size():
		if name_index != character_names.size() - 1:
			file_name += (character_names[name_index] + "-")
		else:
			file_name += (character_names[name_index])
	
	
	# Load in the Dialogue Resource File, make the Dialogue Resource prepare the conversation that corresponds to the given conversation name, then store it into the Dialogue Interface
	current_dialogue = load("res://resources/dialogue/" + file_name + ".tres")
	
	# Determine if a conversation name was specified, then load the specified conversation
	if conversation_name != "":
		current_dialogue.prepare_dialogue(conversation_name)
	
	# Otherwise, determine if a conversation should play automatically or if options should be presented to the Player to select from
	else:
		# Iterate through the appropriate and proper lists of conversations in the Dialogue Resource (based on Player location and other game state variables)
		# Check Play conditions to see if a conversation should be played
		# If it shouldn't be played, move on and repeat
		# If it should be played, check if it should be played now or be saved as an option to play
		# If it should be played now, set it as the conversation name and prepare the dialogue to play
		# If it should be saved as option, save it and then continue checking play conditions and repeating the process
		
		# Create a new instance of a Random Number Generator, and use it to randomly select one of the two conversations that currently exist for each combination of Player and Food Buddy
		var rng = RandomNumberGenerator.new()
		var random_conversation_name: String = current_dialogue.conversations.keys()[rng.randi_range(0, 1)]
		current_dialogue.prepare_dialogue(random_conversation_name)
	
	# Store the list of active characters in the Dialogue Interface so that references to all conversation participants can be accessed
	characters_active = dialogue_characters
	
	# Store the Player as the Dialogue initator since this callback only activates when the Player triggers a Dialogue interaction
	initiator = dialogue_initiator
	
	# Set line displayed as false to indicate that the current line hasn't been displayed yet
	line_displayed = false
	
	# Enable the Dialogue Interface
	active = true
	
	# Pause all of the characters' processing while the interface is active
	for subject in freeze_subjects:
		subject.paused = true



# Disables the Dialogue Interface
func disable(unfreeze_subjects: Array[Node2D]):
	
	# Disable the Dialogue Interface and reset all of its values
	current_dialogue = null
	characters_active = []
	initiator = null
	line_displayed = false
	active = false
	
	# Unpause all of the characters' processing now that the interface is no longer active
	for subject in unfreeze_subjects:
		subject.paused = false



# Processes all of the logic involved for the Dialogue Interface
func process(_delta: float):
	
	# Determine if the Dialogue Interface is currently processing a Game Direction from the Dialogue Resource, then continue processing it
	if script_directions["GAME"]["Processing"]:
		
		# Process Game Direction
		print("Game Instruction: " + script_directions["GAME"]["Direction"])
		
		# If Game Direction is done being processed, set the Game value in the processing dictionary to false and remove the Game Direction from the direction dictionary, and wake up the Dialogue Interface
		script_directions["GAME"]["Processing"] = false
		script_directions["GAME"]["Direction"] = ""
		wake()
		return
	
	
	# Determine if the Dialogue Interface is currently processing a Dialogue Direction from the Dialogue Resource, then continue processing it
	if script_directions["DIALOGUE"]["Processing"]:
		
		# Process Dialogue Direction
		print("Dialogue Instruction: " + script_directions["DIALOGUE"]["Direction"])
		
		# If Dialogue Direction is done being processed, set the Dialogue value in the processing dictionary to false and remove the Dialogue Direction from the direction dictionary
		script_directions["DIALOGUE"]["Processing"] = false
		script_directions["DIALOGUE"]["Direction"] = ""
		
		return
	
	
	# Determine if the current line of Dialogue is a Game or Dialogue Direction, then set the interface to appropriately handle the direction
	if current_dialogue.current_speaker_name == "GAME" or current_dialogue.current_speaker_name == "DIALOGUE":
		
		# Determine if the Dialogue is moving forwards, then store the Game Direction, advance the line to the the actual Dialogue, and begin processing the Game Direction
		if dialogue_moving_forwards:
			script_directions[current_dialogue.current_speaker_name]["Direction"] = current_dialogue.current_line
			script_directions[current_dialogue.current_speaker_name]["Processing"] = true
			current_dialogue.adjust_current_line(true)
			
		# The Dialogue is moving backwards which means no Game Directions need to be executed, so adjust the current line backwards
		else:
			current_dialogue.adjust_current_line(false)
		
		# Return so that the new current line can be processed appropriately
		return
	
	
	# Determine if the current line of Dialogue hasn't been displayed, then display it
	if not line_displayed:
		
		# Iterate over characters of String and print them out (like I did in the Pokemon Game)
		print("[" + str(current_dialogue.current_line_number) + "]  " + current_dialogue.current_speaker_name + ": " + current_dialogue.current_line)
		
		# If all of the characters of the current line have been displayed:
		line_displayed = true
		
	else:
		# Detect if the Player has tried to move backwards or forwards with the Dialogue, then adjust the current line in the Dialogue, flag the line to be displayed, and store the current direction of Dialogue
		if Input.is_action_just_pressed("ability1"):
			if current_dialogue.adjust_current_line(false):
				line_displayed = false
				dialogue_moving_forwards = false
		
		elif Input.is_action_just_pressed("ability2"):
			if current_dialogue.adjust_current_line(true):
				line_displayed = false
				dialogue_moving_forwards = true

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
