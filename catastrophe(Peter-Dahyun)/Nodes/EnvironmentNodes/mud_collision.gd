extends Area2D

@onready var timer: Timer = $Timer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_timer_timeout():
	# bodies collision
	var bodies = get_overlapping_bodies()
	var body_size = 8
	for i in bodies:
		var collision_shape = i.get_node("CollisionShape2D")
		if (collision_shape):
			if (collision_shape.shape is CircleShape2D):
				body_size = collision_shape.shape.radius
			elif (collision_shape.shape is RectangleShape2D):
				body_size = collision_shape.shape.extents.x
		if (i is Player or i is Enemy):
			for j in floor(body_size / 4):
				GameManager.particle("mud_particle",
				 i.global_position + Vector2(randf_range(-body_size,body_size), randf_range(-body_size,body_size)),
				 1, Vector2(randf_range(-0.25, 0.25), randf_range(-0.25, 0.25)), 0.0, [])


func _on_body_entered(body: Node2D) -> void:
	if (body is Enemy):
		body.speed_multiplier(0.75, "mud")
	if (body is Player):
		body.spd_multiply = 0.25
		print("Mud enter");


func _on_body_exited(body: Node2D) -> void:
	if (body is Player):
		body.spd_multiply = 1
	if (body is Enemy):
		body.speed_multiplier(1.0, "mud")
