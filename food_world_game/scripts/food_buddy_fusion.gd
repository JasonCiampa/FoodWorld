extends CharacterBody2D

class_name FoodBuddyFusion


# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Animations #
var sprite: AnimatedSprite2D
var animation_player: AnimationPlayer

# Hitbox #
var hitbox: Area2D

# Inventory #
var inventory: Array = []
var inventory_size: int = 12

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var food_buddy1
var food_buddy2

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ready()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	process()



# Called every frame. Updates the Food Buddy Fusion's physics
func _physics_process(delta: float) -> void:
	physics_process(delta)



# Constructor: called when FoodBuddyFusion is instantiated
func _init(food_buddy_1: FoodBuddy, food_buddy_2: FoodBuddy):
	food_buddy1 = food_buddy_1
	food_buddy2 = food_buddy_2

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# ABSTRACT FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# A custom ready function that each Food Buddy Fusion subclass should personally define. This is called in the default Food Buddy Fusion class's '_ready()' function
func ready():
	pass



# A custom process function that each Food Buddy Fusion subclass should personally define. This is called in the default Food Buddy Fusion class's '_process()' function
func process():
	pass



# A custom physics_process function that each Food Buddy Fusion subclass should personally define. This is called in the default Food Buddy Fusion class's '_physics_process()' function
func physics_process(delta: float) -> void:
	pass



# A custom function to execute the Food Buddy Fusion's ability 1 that each Food Buddy Fusion subclass should personally define.
func use_ability1():
	# THIS CODE SHOULD BE MANUALLY WRITTEN FOR EACH FOOD BUDDY FUSION BECAUSE EVERY ABILITY WILL HAVE A DIFFERENT EXECUTION
	pass



# A custom function to execute the Food Buddy Fusion's ability 2 that each Food Buddy Fusion subclass should personally define.
func use_ability2():
	# THIS CODE SHOULD BE MANUALLY WRITTEN FOR EACH FOOD BUDDY FUSION BECAUSE EVERY ABILITY WILL HAVE A DIFFERENT EXECUTION
	pass



# A custom function to execute the Food Buddy Fusion's special attack that each Food Buddy Fusion subclass should personally define.
func use_special_attack():
	# THIS CODE SHOULD BE MANUALLY WRITTEN FOR EACH FOOD BUDDY FUSION BECAUSE EVERY ABILITY WILL HAVE A DIFFERENT EXECUTION
	pass


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
