extends Node2D

@export var splash_force: float = 300.0

func _process(delta: float) -> void:
	var water = get_node("../../water")
	var parent = get_parent()
	var index = water.get_closest_point_index(parent.global_position.x)
	var velocity_y = splash_force
	
	if parent is CharacterBody2D:
		velocity_y = parent.velocity.y
	elif parent is RigidBody2D:
		velocity_y = parent.linear_velocity.y


	if parent.global_position.y >= water.get_point_y_position(index):
		print("Player Y:", parent.global_position.y, "Water Y:", water.get_point_y_position(index))
		if abs(velocity_y) > 10:
			water.splash_point(index, velocity_y)
			#queue_free()
