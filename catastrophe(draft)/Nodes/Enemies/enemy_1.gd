extends Node2D
class_name Enemy 


# variables
@onready var health = 10


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# Attack area for player
func _on_attack_area_body_entered(body: Node2D) -> void:
	if (body is Player):
		# print("Enemy")
		var dir = global_position.direction_to(body.global_position)
		body.damage(1, dir)


# damage 
func damage(damage: int, direction: Vector2) -> void:
	pass
