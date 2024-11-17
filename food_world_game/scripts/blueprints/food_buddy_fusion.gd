extends Interactable

class_name FoodBuddyFusion


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

signal killed_target

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Food Buddies #
var food_buddy1: FoodBuddy
var food_buddy2: FoodBuddy

# Abilities #
var ability_damage: Dictionary = { "Solo": 10, "Ability1": 15, "Ability2": 20 }
var ability_range: Dictionary = { "Solo": 10, "Ability1": 15, "Ability2": 20 }
var ability_stamina_cost: Dictionary = { "Ability 1": [5, "Gradual"], "Ability 2": [10, "Gradual"] }

# Level and XP #
var xp_current: int
var xp_max: int

# Inventory #
var inventory: Array = []
var inventory_size: int = 12

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	
	ready()
	
	update_location_points()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if not paused:
		process(delta)



# Called every frame. Updates the Food Buddy Fusion's physics
func _physics_process(delta: float) -> void:
	
	if not paused:
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
func process(delta: float):
	pass



# A custom physics_process function that each Food Buddy Fusion subclass should personally define. This is called in the default Food Buddy Fusion class's '_physics_process()' function
func physics_process(delta: float) -> void:
	pass



# A custom function to execute the Food Buddy Fusion's ability 1 that each Food Buddy Fusion subclass should personally define.
func use_ability1():
	# THIS CODE SHOULD BE MANUALLY WRITTEN FOR EACH FOOD BUDDY FUSION BECAUSE EVERY ABILITY WILL HAVE A DIFFERENT EXECUTION
	print("Food Buddy Fusion's Ability 1 has been triggered!")
	pass



# A custom function to execute the Food Buddy Fusion's ability 2 that each Food Buddy Fusion subclass should personally define.
func use_ability2():
	# THIS CODE SHOULD BE MANUALLY WRITTEN FOR EACH FOOD BUDDY FUSION BECAUSE EVERY ABILITY WILL HAVE A DIFFERENT EXECUTION
	print("Food Buddy Fusion's Ability 2 has been triggered!")
	pass



# A custom function to execute the Food Buddy Fusion's special attack that each Food Buddy Fusion subclass should personally define.
func use_special_attack():
	# THIS CODE SHOULD BE MANUALLY WRITTEN FOR EACH FOOD BUDDY FUSION BECAUSE EVERY ABILITY WILL HAVE A DIFFERENT EXECUTION
	print("Food Buddy Fusion's Special Attack has been triggered!")
	pass


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
