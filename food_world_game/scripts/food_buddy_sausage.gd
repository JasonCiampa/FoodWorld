class_name SausageLink

extends FoodBuddy

# MY FUNCTIONS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#A custom ready function personally defined for Link. This is called in the default FoodBuddy class's '_ready()' function
func ready():
	
	# Store a reference to a list of all enemies currently loaded into the game
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	
	## Iterate over each enemy in the list of enemies currently loaded into the game
	#for enemy in enemies:
		#
		## Determine if Link's use_ability_solo signal hasn't been connected to the Enemy's callback function, then connect it
		#if not use_ability_solo.is_connected(enemy._on_food_buddy_use_ability_solo):
			#use_ability_solo.connect(enemy._on_food_buddy_use_ability_solo)
		#
		## Determine if the enemy's die signal hasn't been connected to Link's callback function, then connect it
		#if not enemy.die.is_connected(_on_enemy_die):
			#enemy.die.connect(_on_enemy_die)



#A custom process function personally defined for Link. This is called in the default FoodBuddy class's '_process()' function
func process():
	pass



#A custom physics_process function personally defined for Link. This is called in the default FoodBuddy class's '_physics_process()' function
func physics_process(delta: float) -> void:
	pass



#A custom use_ability1 function personally defined for Link. This is called in the FoodBuddy class's "_on_player_use_ability_buddy()" callback function.
func use_ability1():
	pass



#A custom use_ability2 function personally defined for Link. This is called in the FoodBuddy class's "_on_player_use_ability_buddy()" callback function.
func use_ability2():
	pass
	

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
