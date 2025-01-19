extends FoodBuddy

class_name FoodBuddyFusion


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Food Buddies Fused #
var food_buddy1: FoodBuddy
var food_buddy2: FoodBuddy

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	
	self.name = "FoodBuddyFusion"
	
	ready()
	
	update_location_points()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if not paused:
		process(delta)



# Called every frame. Updates the Food Buddy Fusion's physics
func _physics_process(delta: float) -> void:
	
	if not paused:
		
		# Adjust the Food Buddy's position based on its velocity
		move_and_slide()
		
		# Call the custom "physics_process()" function that Food Buddy subclasses will define individually
		physics_process(delta)
	
	update_location_points()

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Sets the Food Buddies of this Food Buddy Fusion
func set_food_buddies(food_buddy_1: FoodBuddy, food_buddy_2: FoodBuddy):
	food_buddy1 = food_buddy_1
	food_buddy2 = food_buddy_2

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ABSTRACT FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# A custom ready function that each Food Buddy Fusion subclass should personally define. This is called in the default Food Buddy Fusion class's '_ready()' function
func ready():
	pass



# A custom process function that each Food Buddy Fusion subclass should personally define. This is called in the default Food Buddy Fusion class's '_process()' function
func process(_delta: float):
	pass



# A custom physics_process function that each Food Buddy Fusion subclass should personally define. This is called in the default Food Buddy Fusion class's '_physics_process()' function
func physics_process(_delta: float) -> void:
	pass



# Ability Functions #

# A custom function to execute the Food Buddy Fusion's ability 1 that each Food Buddy Fusion subclass should personally define. This is called in the game.gd's "_on_player_use_ability_buddy()" callback function.
func use_ability1():
	# THIS CODE SHOULD BE MANUALLY WRITTEN FOR EACH FOOD BUDDY BECAUSE EVERY ABILITY WILL HAVE A DIFFERENT EXECUTION
	print(name + "'s Ability 1 has been triggered!")
	pass



# A custom function to execute the Food Buddy Fusion's ability 2 that each Food Buddy Fusion subclass should personally define. This is called in the game.gd's "_on_player_use_ability_buddy()" callback function.
func use_ability2():
	# THIS CODE SHOULD BE MANUALLY WRITTEN FOR EACH FOOD BUDDY BECAUSE EVERY ABILITY WILL HAVE A DIFFERENT EXECUTION
	print(name + "'s Ability 2 has been triggered!")
	pass



# A custom function to execute the Food Buddy Fusion's special attack that each Food Buddy Fusion subclass should personally define.
func use_special_attack():
	# THIS CODE SHOULD BE MANUALLY WRITTEN FOR EACH FOOD BUDDY BECAUSE EVERY ABILITY WILL HAVE A DIFFERENT EXECUTION
	pass


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
