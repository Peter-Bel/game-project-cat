extends Area2D

@onready var timer = $Timer

func _on_body_entered(body):
	# ignore if not player
	if body is not Player:
		return
	print("You died")
	timer.start()

func _on_timer_timeout():
	get_tree().reload_current_scene()
