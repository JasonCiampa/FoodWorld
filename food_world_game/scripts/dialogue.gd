extends Resource

class_name Dialogue

# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------






# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Name of Dialogue Resource #
var file_name: String

# Characters Involved in Dialogue #
var character_names: PackedStringArray

# Tracking State of Dialogue #
var current_line: String
var current_line_number: int
var current_speaker: String


@export var conversations: Dictionary

# Characters & their lines in this Dialogue #
# A Dictionary with key-values pairs in the format of String-Dictionary, and the value dictionaries are in the format of int-String
@export var conversation_current: Dictionary = {  
	#
	#"Character Name": 
		#{
			#1 : "I am Character 1!", 
			#3 : "We are both cool Characters!"
		#},   
	#
	#"Character Name 2": 
		#{
			#2 : "And I am Character 2!"
		#} 
	#
}



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------






# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Adjusts the current line forwards (to the next line in the dialogue) or backwards (to the previous line in the dialogue). Returns true if the line is adjusted, returns false if not.
func adjust_current_line(forwards: bool = true) -> bool:
	
	# Determine which should be the new line to display: the line that came previously or the line that comes after the current line
	var line_adjuster: int
	
	if forwards:
		line_adjuster = 1
	else:
		line_adjuster = -1
	
	
	# Iterate over each Character involved in the current conversation
	for character in conversation_current:
		
		# Store a reference to the line that should play next if the Character of this iteration has the line. Store 'null' if the Character of this iteration doesn't have the line.
		var new_line = conversation_current[character].get(current_line_number + line_adjuster)
		
		# Check if line that should play next was found from the Character of this iteration, then set it to be the new current line
		if new_line != null:
			current_line = new_line
			current_line_number += line_adjuster
			current_speaker = character
			
			return true
	
	return false


# Loads and parses data from the given .txt file, stores the data into the 'conversations' array, and then saves a new resource with the same name as the .txt file.
func create_and_save_resource(txt_file_name: String):
	
	# Reset all Dialogue properties so that this Resource can serve as a blueprint for the new Resource being created from the given .txt file
	file_name = ""
	character_names = []
	current_line = ""
	current_line_number = 1
	current_speaker = ""
	conversations = {}
	conversation_current = {}
	
	
	# Open the given .txt file
	var txt_file = FileAccess.open("res://" + txt_file_name + ".txt", FileAccess.READ)
	
	
	# Store the first line of the text file as the current line and as the name of this Dialogue Resource. This first line is the title of the Dialogue, which is made up of all of the involved Characters' names
	current_line = txt_file.get_line()
	file_name = current_line
	
	
	# Stores each of the names of the Characters involved in this Dialogue Resource
	character_names = current_line.split("-")
	
	
	# Store the next line of the text file as the current line. This should be the name of the first conversation in the Dialogue script.
	current_line = txt_file.get_line()
	
	# Until the current line isn't empty, move onto the next line
	while current_line == "":
		current_line = txt_file.get_line()
	
	# Until the end of the .txt file is reached, continue parsing and storing conversations into this Dialogue Resource
	while !txt_file.eof_reached():
		
		# Store the current line as the name of the conversation and create a variable to hold all the data for this conversation
		var conversation_name = current_line
		var conversation: Dictionary = {"GAME": {}}
		
		# Create a key with each Character's name for the conversation and assign it an empty dictionary that will eventually hold their Dialogue
		for character_name in character_names:
			conversation[character_name] = {}
		
		# Store the next line of the text file as the current line. This should be a line of Dialogue from the current conversation, but it might not be
		current_line = txt_file.get_line()
		
		# Until the current line isn't empty, move onto the next line
		while current_line == "":
			current_line = txt_file.get_line()
		
		# Until there are no more lines of Dialogue left in the conversation or the end of the file has been reached, continue parsing and storing each Character's respective lines into this conversation
		while not (int(current_line[0]) == 0 or txt_file.eof_reached()):
			print(current_line)
			# Parse and store the String form of the line number by taking whatever String comes before the '.' in this line of Dialogue
			var line_number = current_line.get_slice(".", 0)
			
			# Parse and store the character's name by taking whatever String comes before the ':' in this line of Dialogue and then trimming away the line number portion of that String
			var character_name: String = current_line.get_slice(":", 0).substr(line_number.length() + 2)
			
			# Parse and store the actual Dialogue of this line by taking away the portion of the String containing the line number and character name
			var line_dialogue: String = current_line.substr(line_number.length() + character_name.length() + 4)
			
			# Store the line as a key with the line dialogue as a value into the character dictionary it belongs to for this conversation
			conversation[character_name].get_or_add(int(line_number), line_dialogue)
			
			# Store the next line of the text file as the current line. This should be a line of Dialogue from the current conversation, or the name of the next conversation, or maybe the end of the file
			current_line = txt_file.get_line()
			
			# If the new current line is the end of the file, end the algorithm
			if txt_file.eof_reached():
				break
			
			# If the new current line is an empty line, move it onto the next line over and over until it isn't on an empty line
			while current_line == "":
				current_line = txt_file.get_line()	
		
		# Add the conversation that was just parsed and stored in the previous while loop into the Resource's Dictionary of conversations with this conversation's name as the key
		conversations[conversation_name] = conversation
		conversation_current = conversations[conversation_name]
	
	# Save this Resource with it's file name in the Dialogue folder
	ResourceSaver.save(self, "res://dialogue/" + file_name + ".tres")
	
	# Close the txt_file now that we've finished parsing it
	txt_file.close()

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# ABSTRACT FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
