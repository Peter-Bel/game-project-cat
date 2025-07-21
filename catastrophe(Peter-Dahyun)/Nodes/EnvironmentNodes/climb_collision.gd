extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if (body is Player):
		body.able_to_climb = true
		print("Climbing")


func _on_body_exited(body: Node2D) -> void:
	if (body is Player):
		body.able_to_climb = false
