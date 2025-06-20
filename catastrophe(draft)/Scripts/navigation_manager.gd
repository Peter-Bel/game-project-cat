extends Node

signal on_trigger_player_spawn

var spawn_door

func go_to_level(door, scene):
	spawn_door = door
	get_tree().change_scene_to_file(scene)

func trigger_player_spawn(position: Vector2, direction: String):
	on_trigger_player_spawn.emit(position, direction)
