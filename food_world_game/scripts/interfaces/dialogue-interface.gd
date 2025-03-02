extends Control

class_name DialogueInterface


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var text_textbox: Label
var text_character_name: Label

var text_conversation1_name: Label
var text_conversation2_name: Label
var text_conversation3_name: Label


var image_character: TextureRect

var button_next: TextureButton
var button_back: TextureButton
var button_exit: TextureButton


var button_conversation1: TextureButton
var button_conversation2: TextureButton
var button_conversation3: TextureButton

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
	
	text_conversation1_name = $"Conversation Options/Conversation/Conversation Text Container/Conversation Text"
	text_conversation2_name = $"Conversation Options/Conversation 2/Conversation Text Container/Conversation Text"
	text_conversation3_name = $"Conversation Options/Conversation 3/Conversation Text Container/Conversation Text"
	
	button_conversation1 = $"Conversation Options/Conversation/Conversation Button Container/Conversation Button"
	button_conversation2 = $"Conversation Options/Conversation 2/Conversation Button Container/Conversation Button"
	button_conversation3 = $"Conversation Options/Conversation 3/Conversation Button Container/Conversation Button"
	
	image_character = $"Textbox/Textbox Character Image Container2/Textbox Character Image" 
	button_next = $"Next/Next Button Container/Next Button"
	button_back = $"Back/Back Button Container/Back Button"
	button_exit = $"Exit/Exit Button Container/Exit Button"
	animator = $"Animator"
	char_delay_timer = $"Char Delay Timer"



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if !player.is_interacting:
		if !animator.is_playing():
			self.visible = false
			self.process_mode = Node.PROCESS_MODE_DISABLED
		
		return
	
	if current_dialogue == null:
		return
	
	
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
	
	button_conversation1.disabled = false
	button_conversation2.disabled = false
	button_conversation3.disabled = false
	
	
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
					if conversations_played.get(conversation) == null:
						conversation_name = conversation
						break
					
					# Otherwise this conversation has already played once, so let the user determine if they want to play it again
					else:
						conversation_options.append(conversation)
	
	# Determine if no conversation was automatically selected
	if conversation_name == "":
		
		# Determine if there are conversation options for the user to manually select
		if conversation_options.size() > 0:
			current_dialogue.current_speaker_name = ""
			text_character_name.text = ""
			current_char_string = ""
			current_char_index = 0
		
			# Store the list of active characters in the Dialogue Interface so that references to all conversation participants can be accessed
			characters_active = dialogue_characters
			
			# Set line displayed as false to indicate that the current line hasn't been displayed yet
			line_displayed = false
			
			# Create a string that will hold each of the character's names separated by commas
			var characters_string: String
			
			# Iterate over each character name
			for character in range(character_names.size() - 1, -1, -1):
				
				# If the character's name is player, remove the name from the list
				if character_names[character] == "Player":
					character_names.remove_at(character)
			
			if character_names.size() == 2:
				# Set the dialogue's current line to instruct the user to select a convo to have with the characters
				current_dialogue.current_line = "Select a conversation listed above to have with " + character_names[0] + " and " + character_names[1] + "."
			
			else:
				
				# Iterate over each character name
				for character in range(0, character_names.size()):
					
					# Determine that this isn't the last character, then add a comma when adding their name to the string
					if character != character_names.size() - 1:
						characters_string = characters_string + character_names[character] + ", "
						
					# Otherwise, this is the last character, so add "and" and a "."
					else:
						characters_string = characters_string + "and " + character_names[character] + "."
				
				# Set the dialogue's current line to instruct the user to select a convo to have with the characters
				current_dialogue.current_line = "Select a conversation listed above to have with " + characters_string
			
			text_conversation1_name.text = conversation_options[0].replace("-", " ")
			
			if conversation_options.size() > 1:
				text_conversation2_name.text = conversation_options[1].replace("-", " ")
			else:
				text_conversation2_name.text = ""
				button_conversation2.disabled = true
			
			if conversation_options.size() > 2:
				text_conversation3_name.text = conversation_options[2].replace("-", " ")
			else:
				text_conversation3_name.text = ""
				button_conversation3.disabled = true
			
			# Animate the UI onto the screen, then have it stay in place
			animator.play("enter_UI")
			animator.queue("enter_selection_UI")
			animator.queue("stay_UI")
		
		# Otherwise, there are no automatically playing conversations and none for the user to play for this group of characters, so return and set them to be not interacting anymore
		else:
			player.is_interacting = false
			return
	
	# Otherwise, a conversation was automatically selected or manually passed into the start() call
	else:
		
		# Remove any conversation options there were
		conversation_options.clear()
		
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
		
		# Animate the UI onto the screen, then have it stay in place
		animator.play("enter_UI")
		animator.queue("stay_UI")
	
	
	# Pause all of the characters' processing while the interface is active
	for subject in freeze_subjects:
		subject.paused = true
	
	frozen_subjects = freeze_subjects
	
	# Set the UI to be visible and processing
	self.visible = true
	self.process_mode = Node.PROCESS_MODE_INHERIT


# Disables the Dialogue Interface
func end():
	conversation_options.clear()
	
	# Disable the Dialogue Interface and reset all of its values
	current_dialogue = null
	#characters_active = []
	line_displayed = false
	current_char_index = 0
	current_char_string = ""
	
	text_character_name.text = ""
	text_textbox.text = ""
	
	
	button_conversation1.disabled = true
	button_conversation2.disabled = true
	button_conversation3.disabled = true
	button_next.disabled = true
	button_back.disabled = true
	button_exit.disabled = true
	
	
	player.is_interacting = false
	
	# Unpause all of the characters' processing now that the interface is no longer active
	for subject in frozen_subjects:
		subject.paused = false
	
	animator.queue("RESET")


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
	
	# Determine if there are more than three conversation options and that the last option isn't already set
	if conversation_options.size() > 3 and conversation_options[conversation_options.size() - 1] != text_conversation3_name.text:
		
		# Iterate over each conversation option until you reach the option stored in the first UI button
		for conversation in range(0, conversation_options.size()):
			
			# Determine if the conversation of this iteration is the same conversation stored in the first UI button, then shift the buttons so that the next conversation option moves into the first UI button
			if conversation_options[conversation] == text_conversation1_name.text:
				text_conversation1_name.text = conversation_options[conversation + 1]
				text_conversation2_name.text = conversation_options[conversation + 2]
				text_conversation3_name.text = conversation_options[conversation + 3]
				
				if conversation + 3 == conversation_options.size() - 1:
					button_next.disabled = true
					button_back.disabled = false
				else:
					button_back.disabled = false
					button_next.disabled = false
				
				break
		
		return
	
	if current_dialogue.adjust_current_line(true):
		line_displayed = false
		dialogue_moving_forwards = true
		text_character_name.text = current_dialogue.current_speaker_name
		current_char_index = 0
		current_char_string = ""
		
		# If the line is not adjusted forward, disable the next button because there is no other lines
		if !current_dialogue.adjust_current_line(true):
			button_back.disabled = false
			button_next.disabled = true
		else:
			button_back.disabled = false
			button_next.disabled = false
			current_dialogue.adjust_current_line(false)
		
		

# Adjust the current line in the Dialogue backwards, flag the line to be displayed, and store the current direction of Dialogue
func _on_back_button_down() -> void:
	
	# Determine if there are more than three conversation options and that the first option isn't already set
	if conversation_options.size() > 3 and conversation_options[0] != text_conversation1_name.text:
		
		# Iterate over each conversation option until you reach the option stored in the first UI button
		for conversation in range(0, conversation_options.size()):
			
			# Determine if the conversation of this iteration is the same conversation stored in the third UI button, then shift the buttons so that the previous conversation option moves into the third UI button
			if conversation_options[conversation] == text_conversation3_name.text:
				text_conversation1_name.text = conversation_options[conversation - 3]
				text_conversation2_name.text = conversation_options[conversation - 2]
				text_conversation3_name.text = conversation_options[conversation - 1]
				
				if conversation - 3 == 0:
					button_back.disabled = true
					button_next.disabled = false
				else:
					button_back.disabled = false
					button_next.disabled = false
				
				break
		
		return
	
	if current_dialogue.adjust_current_line(false):
		line_displayed = false
		dialogue_moving_forwards = false
		
		if current_dialogue.current_speaker_name != "PLAY" and current_dialogue.current_speaker_name != "PLAY_WHEN":
			text_character_name.text = current_dialogue.current_speaker_name
		
		current_char_index = 0
		current_char_string = ""
		
		if current_dialogue.current_line_number == current_dialogue.starting_line_number:
			button_back.disabled = true
			button_next.disabled = false
		else:
			button_back.disabled = false
			button_next.disabled = false


func _on_exit_button_down() -> void:

	
	end()


func select_conversation(conversation_name: String):
	button_conversation1.disabled = true
	button_conversation2.disabled = true
	button_conversation3.disabled = true
	
	button_next.disabled = false
	
	conversation_options.clear()
	
	animator.play("exit_selection_UI")
	
	# Determine if this conversation hasn't been played yet, then add it to the list of conversations that have been played now that it has for the first time
	if conversations_played.get(conversation_name) == null:
		conversations_played.get_or_add(conversation_name, 1)
	
	# Otherwise, this conversation has played before but is playing again, so increment the number of times it has played by 1
	else:
		conversations_played.get_or_add(conversation_name, conversations_played.get(conversation_name) + 1)
	
	
	# Prepare the conversation in the dialogue resource
	current_dialogue.prepare_dialogue(conversation_name)
	text_character_name.text = current_dialogue.current_speaker_name
	text_textbox.text = ""
	current_char_string = ""
	current_char_index = 0
	
	# Set line displayed as false to indicate that the current line hasn't been displayed yet
	line_displayed = false



func _on_conversation1_button_down() -> void:
	select_conversation(text_conversation1_name.text)

func _on_conversation2_button_down() -> void:
	select_conversation(text_conversation2_name.text)

func _on_conversation3_button_down() -> void:
	select_conversation(text_conversation3_name.text)


func _on_animator_current_animation_changed(animation_name: String) -> void:
	
	if animation_name == "stay_UI":
		
		if conversation_options.size() == 0:
			button_back.disabled = true
			button_next.disabled = false
		
		elif conversation_options.size() > 3:
			button_back.disabled = true
			button_next.disabled = false
		
		button_exit.disabled = false
