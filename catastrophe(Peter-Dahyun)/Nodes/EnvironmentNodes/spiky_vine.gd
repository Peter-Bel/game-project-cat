extends Node2D

var active = true

func _on_attack_area_body_entered(body: Node2D) -> void:
	if (body is Player and active):
		# print("Enemy")
		var dir = global_position.direction_to(body.global_position)
		body.damage(1, dir)
