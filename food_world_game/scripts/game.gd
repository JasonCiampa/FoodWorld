extends Node2D

# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

@onready var player: Player = $Player
@onready var enemy: Enemy = $Enemy
@onready var food_buddy: FoodBuddy = $"Food Buddy"

var link_the_sausage_link: SausageLink = load("res://scenes/food_buddy_sausage.tscn").instantiate()

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

enum World { SWEETS, GARDEN, COLISEUM, MEAT, SEAFOOD, JUNKFOOD, PERISHABLE, SPUD }

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

var duplicates = []

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	
	# Load Link into the SceneTree 
	add_child(link_the_sausage_link)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# Determine if the Player has left-clicked, then create a duplicate of Link, add it to a list of duplicates, and then add the duplicate to the SceneTree
	if Input.is_action_just_pressed("ability1"):
		duplicates.append(link_the_sausage_link.duplicate())
		add_child(duplicates[-1])
	
	# Determine if the Player has right-clicked, then determine if there are any duplicates currently, then remove the duplicate from the SceneTree and the list of duplicates
	if Input.is_action_just_pressed("ability2"):
		if duplicates.size() > 0:
			remove_child(duplicates[0])
			duplicates.remove_at(0)



# Called every frame. Updates the Player's physics
func _physics_process(delta: float) -> void:
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Callback function that executes whenever an Enemy dies: removes the Enemy from the SceneTree
func _on_enemy_die(enemy: Enemy) -> void:
	remove_child(enemy)



# Determines which world the Player is currently located in
func determine_player_location_world() -> World:
	
	# Implement checks to find out which world the Player is in based on the tile type that they're touching and their coordinates and return the correct world
	
	return World.COLISEUM
