extends FoodBuddy

class_name Malick

func ready():
	speed_normal = 20
	speed_current = speed_normal


# A custom process function that each Food Buddy subclass should personally define. This is called in the default FoodBuddy class's '_process()' function
func process():
	
	# Determine the Food Buddy's current field state, then alter their movement/attack behavior based on that field state
	if field_state_current == FieldState.FOLLOW:
		target_player.emit(self)
		move_towards_target.emit(self, target, 30)
	elif field_state_current == FieldState.FORAGE:
		pass
	elif field_state_current == FieldState.FUSION:
		pass
	elif field_state_current == FieldState.SOLO:
		pass
	elif field_state_current == FieldState.PLAYER:
		pass
	
	pass
