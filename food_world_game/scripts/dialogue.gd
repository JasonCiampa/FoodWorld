extends Resource

class_name Dialogue

# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------






# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Tracking State of Dialogue #
var current_line: String
var current_line_number: int

@export var conversations: Array[Dictionary]

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

# Adjusts the current line forwards (to the next line in the dialogue) or backwards (to the previous line in the dialogue)
func adjust_current_line(forwards: bool = true):
	
	# Determine which should be the new line to display: the line that came previously or the line that comes after the current line
	var line_adjuster: int
	
	if forwards:
		line_adjuster = 1
	else:
		line_adjuster = -1
	
	
	# Iterate over each Character involved in the current conversation
	for character in conversation_current:
		
		# Iterate over each line that the Character of this iteration has in the current conversation
		for line in conversation_current[character]:
			
			# Store a reference to the line that should play next if the Character of this iteration has the line. Store 'null' if the Character of this iteration doesn't have the line.
			var new_line: String = line.get(current_line_number + line_adjuster)
			
			# Check if line that should play next was found from the Character of this iteration, then set it to be the new current line
			if new_line != null:
				current_line = new_line
				current_line_number += line_adjuster
				
				return



# Loads and parses data from the given .txt file, stores the data into the 'conversations' array, and then saves a new resource with the same name as the .txt file.
func create_new_dialogue_resource(file_name: String):
	var txt_file = FileAccess.open("res://testtext.txt", FileAccess.READ)
	var current_line = txt_file.get_line()
	var content = txt_file.get_as_text()
	print(current_line)
	current_line = txt_file.get_line()
	print(current_line)
	current_line = txt_file.get_line()
	print(current_line)
	current_line = txt_file.get_line()
	print(current_line)
	current_line = txt_file.get_line()

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# ABSTRACT FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
