class_name Enemy

extends RigidBody2D

# NODES #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Animations #
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Hitbox #
@onready var hitbox: Area2D = $Area2D


@onready var visible_on_screen_enabler_2d: VisibleOnScreenEnabler2D = $VisibleOnScreenEnabler2D
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# SIGNALS #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# ENUMS #----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# VARIABLES #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Health #
var health_current: int
var health_max: int

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# GODOT FUNCTIONS #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

func _ready() -> void:
	mass = 10
	lock_rotation = true

func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	pass

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





# MY FUNCTIONS #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Determines if an attack has landed and reduces health if it has
func process_attack(attack_hitbox: Area2D, damage: int):
	
	# Store a list of all hitboxes that the hitbox of the attack has overlapped with
	var hitboxes = attack_hitbox.get_overlapping_areas()
	
	# Determine if the Enemy's hitbox is in the list of hitboxes that the attack's hitbox overlapped with, then reduce their health
	if hitbox in hitboxes:
		health_current -= damage
		print(health_current)



# Called everytime the Player uses an ability while in the Solo fighting style.
func _on_player_use_ability_solo(attack_hitbox: Area2D, damage_amount: int) -> void:
	process_attack(attack_hitbox, damage_amount)


# Called everytime a Food Buddy uses an ability while in the Solo fighting style.
func _on_food_buddy_use_ability_solo(attack_hitbox: Area2D, damage_amount: int) -> void:
	process_attack(attack_hitbox, damage_amount)

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
