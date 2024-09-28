extends Node2D

@onready var player: Player = $Player
@onready var enemy: Enemy = $Enemy
@onready var food_buddy: FoodBuddy = $"Food Buddy"

var food_buddy_duplicate: FoodBuddy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	food_buddy_duplicate = food_buddy.duplicate()
	food_buddy_duplicate.global_position.x = 20
	food_buddy_duplicate.global_position.y = 20
	
	add_child(food_buddy_duplicate)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
