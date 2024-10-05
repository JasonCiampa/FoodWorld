class_name Enemy

extends CharacterBody2D

# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Animations #
var sprite: AnimatedSprite2D
var animation_player: AnimationPlayer

# Hitbox #
var hitbox: Area2D

# On-Screen Notifier #
var on_screen_notifier: VisibleOnScreenNotifier2D

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

signal use_ability

signal target_player
signal target_closest_food_buddy

signal move_towards_target

signal die
signal killed_target

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Health #
var health_current: int
var health_max: int
var alive: bool = true

# Target #
var target: Node2D = null
var target_distance: float

# Abilities #
var ability1_damage: int = 10

# Speed #
var speed_normal: int = 50
var speed_current: int = speed_normal

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Store references to the Enemy's Nodes
	sprite = $AnimatedSprite2D
	animation_player = $AnimationPlayer
	hitbox = $Area2D
	on_screen_notifier = $VisibleOnScreenNotifier2D



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



# Called every frame. Updates the Enemy's physics
func _physics_process(delta: float) -> void:
	use_solo_attack()
	move_and_slide()


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# ABSTRACT FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# A custom ready function that each Enemy subclass should personally define. This is called in the default Enemy class's '_ready()' function
func ready():
	pass



# A custom process function that each Enemy subclass should personally define. This is called in the default Enemy class's '_process()' function
func process():
	pass



# A custom physics_process function that each Enemy subclass should personally define. This is called in the default Enemy class's '_physics_process()' function
func physics_process(delta: float) -> void:
	pass



# A custom function to execute the Enemy's ability 1 that each Enemy subclass should personally define. This is called in the Enemy class's "_on_player_use_ability_buddy()" callback function.
func use_ability1():
	# THIS CODE SHOULD BE MANUALLY WRITTEN FOR EACH ENEMY BECAUSE EVERY ABILITY WILL HAVE A DIFFERENT EXECUTION
	pass



# A custom function to execute the Enemy's ability 2 that each Enemy subclass should personally define. This is called in the Enemy class's "_on_player_use_ability_buddy()" callback function.
func use_ability2():
	# THIS CODE SHOULD BE MANUALLY WRITTEN FOR EACH ENEMY BECAUSE EVERY ABILITY WILL HAVE A DIFFERENT EXECUTION
	pass


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Executes the logic for a Enemy's solo attack
func use_solo_attack():
	
	# Determine if the Enemy has a target currently, then move towards them. Otherwise, have the Enemy look for a new target.
	if target != null and target.alive:
		move_towards_target.emit(self, target, 10)
	else:
		#target_player.emit(self)
		target_closest_food_buddy.emit(self)
		return
		
	# Determine if the Enemy is in range of the target, then make them stop moving and launch their solo attack
	if target_distance <= 30:
		velocity.x = 0
		velocity.y = 0
		use_ability.emit(self, ability1_damage)

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
