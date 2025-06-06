extends Node2D


class_name Enemy 


# variables
const SPEED = 30
var direction = -1

@onready var health = 10
@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var ray_cast_bottomL = $RayCastBottomLeft
@onready var ray_cast_bottomR = $RayCastBottomRight
@onready var animated_sprite = $AnimatedSprite2D
# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# if enemy detects  a wall, change its direction
	if ray_cast_right.is_colliding():
		direction = -1
	elif ray_cast_left.is_colliding():
		direction = 1
	# if enemy detects cliff, change its direction
	elif  direction == 1 and !ray_cast_bottomR.is_colliding():
		direction = -1
	elif direction == -1 and !ray_cast_bottomL.is_colliding():
		direction = 1
	animated_sprite.flip_h = direction == -1
	
	position.x += direction * SPEED * delta	

# Attack area for player
func _on_attack_area_body_entered(body: Node2D) -> void:
	if (body is Player):
		# print("Enemy")
		var dir = global_position.direction_to(body.global_position)
		body.damage(1, dir)


# damage 
func damage(damage: int, direction: Vector2) -> void:
	pass
