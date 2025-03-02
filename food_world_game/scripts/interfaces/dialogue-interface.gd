extends Control

class_name DialogueInterface


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var text_textbox: Label
var text_character_name: Label

var image_character: TextureRect

var button_next: TextureButton
var button_back: TextureButton
var button_exit: TextureButton

var animator: AnimationPlayer

var char_delay_timer: Timer

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var player: Player

var frozen_subjects: Array[Node2D]


var conversations_played: Dictionary

# Dialogue State #
var conversation_options: Array
var current_dialogue: Resource
var characters_active: Array[Node2D]
var dialogue_moving_forwards: bool
var line_displayed: bool

var current_char_index: int
var current_char_string: String = ""


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
	text_character_name = $"Textbox/Textbox Character Name Container/Textbox Character Name Text"
	text_textbox = $"Textbox/Textbox Text Container/Textbox Text"
	image_character = $"Textbox/Textbox Character Image Container2/Textbox Character Image" 
	button_next = $"Next/Next Button Container/Next Button"
	button_back = $"Back/Back Button Container/Previous Button"
	button_exit = $"Exit/Exit Button Container/Exit Button"
	animator = $"Animator"
	char_delay_timer = $"Char Delay Timer"



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	# Determine if the Dialogue Interface is currently processing a Game Direction from the Dialogue Resource, then continue processing it
	if script_directions["GAME"]["Processing"]:
		
		# Process Game Direction
		print("Game Instruction: " + script_directions["GAME"]["Direction"])
		
		# If Game Direction is done being processed, set the Game value in the processing dictionary to false and remove the Game Direction from the direction dictionary
		script_directions["GAME"]["Processing"] = false
		script_directions["GAME"]["Direction"] = ""
		
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
	if current_dialogue.current_speaker_name == "PLAY" or current_dialogue.current_speaker_name == "PLAY_WHEN":
		
		current_dialogue.adjust_current_line(true)
	
	
	
	elif current_dialogue.current_speaker_name == "GAME" or current_dialogue.current_speaker_name == "DIALOGUE":
	
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
	if not line_displayed and not animator.current_animation == "enter_UI":
		
		if char_delay_timer.is_stopped():
			current_char_index = current_char_index + 1
			
			if current_char_index == current_dialogue.current_line.length():
				
				# If all of the characters of the current line have been displayed:
				line_displayed = true
				text_textbox.text = current_dialogue.current_line
			
			current_char_string = current_dialogue.current_line.substr(0, current_char_index)
			
			text_textbox.text = current_char_string
			
			char_delay_timer.start(0.04)



# Called every frame. Updates the Enemy's physics
func _physics_process(_delta: float) -> void:
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

func setValues(_player: Player):
	player = _player



# Enables and prepares the Dialogue Interface and freezes the updating for the given subjects while the Interface is active
func start(dialogue_characters: Array[Node2D], freeze_subjects: Array[Node2D], conversation_name: String = "") -> void:
	
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
	
	if current_dialogue == null:
		return
	
	
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
					
					conversation_name = conversation
					break
				
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
	
	if conversation_name == "":
		player.is_interacting = false
		return
	
	# Determine if this conversation hasn't been played yet, then add it to the list of conversations that have been played now that it has for the first time
	if conversations_played.get(conversation_name) == null:
		conversations_played.get_or_add(conversation_name, 1)
	
	# Otherwise, this conversation has played before but is playing again, so increment the number of times it has played by 1
	else:
		conversations_played.get_or_add(conversation_name, conversations_played.get(conversation_name) + 1)
	
	
	# Prepare the conversation in the dialogue resource
	current_dialogue.prepare_dialogue(conversation_name)
	text_character_name.text = current_dialogue.current_speaker_name
	current_char_string = ""
	current_char_index = 0
	
	
	# Store the list of active characters in the Dialogue Interface so that references to all conversation participants can be accessed
	characters_active = dialogue_characters
	
	# Set line displayed as false to indicate that the current line hasn't been displayed yet
	line_displayed = false
	
	# Enable the Dialogue Interface
	
	# Pause all of the characters' processing while the interface is active
	for subject in freeze_subjects:
		subject.paused = true
	
	frozen_subjects = freeze_subjects
	
	# Set the UI to be visible and processing
	self.visible = true
	self.process_mode = Node.PROCESS_MODE_INHERIT
	
	# Animate the UI onto the screen, then have it stay in place
	animator.play("enter_UI")
	animator.queue("stay_UI")


# Disables the Dialogue Interface
func end():
	
	# Disable the Dialogue Interface and reset all of its values
	current_dialogue = null
	characters_active = []
	line_displayed = false
	current_char_index = 0
	current_char_string = ""
	
	text_character_name.text = ""
	text_textbox.text = ""
	
	
	player.is_interacting = false
	
	# Unpause all of the characters' processing now that the interface is no longer active
	for subject in frozen_subjects:
		subject.paused = false
	
	# Set the UI to be invisible and not processing
	self.visible = false
	self.process_mode = Node.PROCESS_MODE_DISABLED
	
	animator.play("RESET")


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



# PLAY PARSER #

# Parses the play instruction with this format: 'PLAY: player_level=|>=|1'
func play_parse_player_level(condition: String):
	
	var operator: String = condition.get_slice("|", 0)
	var value: String = condition.get_slice("|", 1)
	
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
	
	

# Adjust the current line in the Dialogue forwards, flag the line to be displayed, and store the current direction of Dialogue
func _on_next_button_down() -> void:
	
	if current_dialogue.adjust_current_line(true):
		line_displayed = false
		dialogue_moving_forwards = true
		text_character_name.text = current_dialogue.current_speaker_name
		current_char_index = 0
		current_char_string = ""
		

# Adjust the current line in the Dialogue backwards, flag the line to be displayed, and store the current direction of Dialogue
func _on_previous_button_down() -> void:
	if current_dialogue.adjust_current_line(false):
		line_displayed = false
		dialogue_moving_forwards = false
		
		if current_dialogue.current_speaker_name != "PLAY" and current_dialogue.current_speaker_name != "PLAY_WHEN":
			text_character_name.text = current_dialogue.current_speaker_name
		
		current_char_index = 0
		current_char_string = ""


func _on_exit_button_down() -> void:
	end()
