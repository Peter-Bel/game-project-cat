extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if NavigationManager.spawn_door != null:
		# print(NavigationManager.spawn_door)
		_on_level_position(NavigationManager.spawn_door)
		

func _on_level_position(destination: String):
	var path = "Doors/Door_" + destination
	var door = get_node(path) as Door
	if (door):
		NavigationManager.trigger_player_spawn(door.destination.global_position, door.spawn_direction)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
