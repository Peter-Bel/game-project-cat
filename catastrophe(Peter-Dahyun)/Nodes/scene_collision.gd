extends Area2D
class_name Door 

# variables
@export var spawn_direction = "right"
@export var destination_scene: String
@export var destination_door: String

var path = "ScenesDefault/default"
@onready var destination = $Destination


func _on_body_entered(body: Node2D) -> void:
	if (body is Player):
		NavigationManager.go_to_level(destination_door, destination_scene)
