extends Node2D

class_name DialogueInterface


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var player: Player

# Interface State #
var active: bool = false
var sleeping: bool = false

var conversations_played: Dictionary

# Dialogue State #
var conversation_options: Array
var current_dialogue: Resource
var characters_active: Array[Node2D]
var initiator: Node2D
var dialogue_moving_forwards: bool
var line_displayed: bool


# Script Directions #
var script_directions: Dictionary = {
	"GAME": {
		"Direction": "", 
		"Processing": false
	}, 
	
	"DIALOGUE": {
		"Direction": "", 
		"Processing": false
	}
}


var play_parser: Dictionary = {
	"player_level" : play_parse_player_level
}

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
func start(_player: Player, dialogue_characters: Array[Node2D], dialogue_initiator: Node2D, freeze_subjects: Array[Node2D], conversation_name: String = "") -> void:
	
	player = _player
	
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
	
	# Determine if a conversation name was not specified, then attempt to automatically select one
	if conversation_name == "":
		
		# Iterate over every possible conversation included in this dialogue resource
		for conversation in current_dialogue.conversations:
			
			var play_conditions_true: bool = true
			
			# Iterate over all of the play conditions in the conversation
			for play_condition in current_dialogue.conversations[conversation]["PLAY"].keys():
				
				# Parse out the callback function to trigger that will process the play condition
				var callback = current_dialogue.conversations[conversation]["PLAY"][play_condition].get_slice('=', 0)
				
				# Trigger a callback function to process the play condition, and determine if it evaluates to false
				if not play_parser[callback].call(current_dialogue.conversations[conversation]["PLAY"][play_condition].substr(callback.length() + 2)):
					
					# The condition was false so the conversation shouldn't play
					play_conditions_true = false
					
					break
			
			# Determine if the conversation's play conditions evaluated to true, then determine when the conversation should play
			if play_conditions_true:
				
				# Store a reference to the list of keys that play_when has (this is actually just a list with a single key, because play_when only needs one value (now or user) (as of 3/1/25)
				var keys = current_dialogue.conversations[conversation]["PLAY_WHEN"].keys()
				
				# Determine if the conversation should play now
				if "now" in current_dialogue.conversations[conversation]["PLAY_WHEN"][keys[0]]:
					
					print("oh yeah im jaking it")
					conversation_name = conversation
					break
					
					# THE COMMENTED OUT CODE BELOW WAS A WORK IN PROGRESS TOWARDS AN "UNLESS" CONDITION, WHICH BASICALLY SAYS PLAY THIS CONVERSATION NOW UNLESS THIS CONDITION IS TRUE, IN WHICH CASE LET THE USER DECIDE WHEN TO PLAY THE CONVO
					# THIS MAY NOT BE NECESSARY
					## Store the "unless" condition attached to the "now" (if there is one)
					#var unless = conversation["PLAY_WHEN"].get_slice('=', 1)
					#
					#if unless.length() == 0:
						#conversation_name = conversation
						#break
					#
					#else:
						#
						## Trigger a callback function to process the play condition, and determine if it evaluates to false
						#if not play_parser[callback].call(conversation["PLAY_WHEN"].substr(callback.length() + 1)):
							#
							## The condition was false so the conversation shouldn't play
							#play_conditions_true = false
							#
							#break
				
				# Otherwise, this conversation doesn't need to be played now, so add the conversation name to a list of conversation options for the user to select from later (if no conversation auto-plays)
				elif "user" in current_dialogue.conversations[conversation]["PLAY_WHEN"][keys[0]]:
					
					# Determine if this conversation hasn't been played yet, then set it as the conversation that will be played
					if conversations_played.get(conversation_name) == null:
						conversations_played.get_or_add(conversation_name, 1)
						conversation_name = conversation
						break
					
					# Otherwise this conversation has already played once, so let the user determine if they want to play it again
					else:
						conversation_options.append(conversation)
	
	
	print("CONVO OPTIONS: ", conversation_options)
	
	# Determine if this conversation hasn't been played yet, then add it to the list of conversations that have been played now that it has for the first time
	if conversations_played.get(conversation_name) == null:
		conversations_played.get_or_add(conversation_name, 1)
	
	# Otherwise, this conversation has played before but is playing again, so increment the number of times it has played by 1
	else:
		conversations_played.get_or_add(conversation_name, conversations_played.get(conversation_name) + 1)
	
	
	# Prepare the conversation in the dialogue resource
	current_dialogue.prepare_dialogue(conversation_name)
	
	# Store the list of active characters in the Dialogue Interface so that references to all conversation participants can be accessed
	characters_active = dialogue_characters
	
	# Store the Player as the Dialogue initator since they are the only one who can (currently) start conversations (as of 1/19/25)
	initiator = dialogue_initiator
	
	# Set line displayed as false to indicate that the current line hasn't been displayed yet
	line_displayed = false
	
	# Enable the Dialogue Interface
	active = true
	
	# Pause all of the characters' processing while the interface is active
	for subject in freeze_subjects:
		subject.paused = true


# Disables the Dialogue Interface
func end(unfreeze_subjects: Array[Node2D]):
	
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



# PLAY PARSER #

# Parses the play instruction with this format: 'PLAY: player_level=|>=|1'
func play_parse_player_level(condition: String):
	
	var operator: String = condition.get_slice("|", 0)
	var value: String = condition.get_slice("|", 1)
	
	print("Player Level Current", player.level_current)
	print("Operator: ", operator)
	print("Value: ", value)
	
	if operator == ">":
		return player.level_current > int(value)
	
	elif operator == ">=":
		return player.level_current >= int(value)
	
	elif operator == "<":
		return player.level_current < int(value)
	
	elif operator == "<=":
		return player.level_current <= int(value)
	
	elif operator == "==":
		return player.level_current == int(value)
	
	elif operator == "!=":
		return player.level_current != int(value)
	
	
