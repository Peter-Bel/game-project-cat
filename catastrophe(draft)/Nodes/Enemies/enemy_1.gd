<<<<<<< HEAD
extends CharacterBody2D


class_name Enemy 
=======
extends Node2D
class_name Enemy

>>>>>>> parent of 4db7ca4 (Merge branch 'main' into Peter_Levels&PlayerImplimentatoin)



# variables
<<<<<<< HEAD
const SPEED = 30
var direction = -1
<<<<<<< HEAD
=======
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_node: Health = $Health
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var death_time: Timer = null
var time_to_death = 0.2

var knock = 1.5
var knock_acc = 0.05
var direction = Vector2(0,0) 

var active = true
>>>>>>> parent of 4db7ca4 (Merge branch 'main' into Peter_Levels&PlayerImplimentatoin)

=======
>>>>>>> parent of c852502 (Merge pull request #4 from Peter-Bel/Peter_Levels&PlayerImplimentatoin)

# Called when the node enters the scene tree for the first time.
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> parent of c852502 (Merge pull request #4 from Peter-Bel/Peter_Levels&PlayerImplimentatoin)
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
<<<<<<< HEAD
=======
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (!death_time and health_node.health <= 0):
		death(time_to_death)
		animated_sprite.play("Death")
	if (health_node.health <= 0):
		position.x += direction.x * knock
		position.y += direction.y * knock
		knock = lerp(knock, 0.0, knock_acc)

>>>>>>> parent of 4db7ca4 (Merge branch 'main' into Peter_Levels&PlayerImplimentatoin)
=======
>>>>>>> parent of c852502 (Merge pull request #4 from Peter-Bel/Peter_Levels&PlayerImplimentatoin)

# Attack area for player
func _on_attack_area_body_entered(body: Node2D) -> void:
	if (body is Player):
		# print("Enemy")
		var dir = global_position.direction_to(body.global_position)
		body.damage(1, dir)


# damage 
func damage(damage: int, direction: Vector2) -> void:
	pass
