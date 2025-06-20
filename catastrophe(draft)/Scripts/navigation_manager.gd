extends Node

signal on_trigger_player_spawn


# variables
var transition_time = 0.5
var spawn_door
var scene_fade = null

# change scene
func go_to_level(door, scene):
	if (scene_fade):
		print(scene_fade)
		scene_fade.fade(true)
	var timer = get_tree().create_timer(transition_time)
	await timer.timeout
	spawn_door = door
	get_tree().change_scene_to_file(scene)

func trigger_player_spawn(position: Vector2, direction: String):
	on_trigger_player_spawn.emit(position, direction)
