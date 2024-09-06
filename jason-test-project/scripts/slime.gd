extends Node2D

const SPEED = 60
var direction : int = 1

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d_left: RayCast2D = $"RayCast2D Left"
@onready var ray_cast_2d_right: RayCast2D = $"RayCast2D Right"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ray_cast_2d_left.is_colliding():
		direction = 1
		animated_sprite_2d.flip_h = false
	elif ray_cast_2d_right.is_colliding():
		direction = -1
		animated_sprite_2d.flip_h = true

	position.x += direction * SPEED * delta
