extends Node

# player values
var player_hp = -1

# playerBody for flying enemy.gd
# go to player.gd and find Gamemager in the _ready func
var playerBody: CharacterBody2D

# freeze frame
func freeze_frame(timeScale, duration):
	Engine.time_scale = timeScale
	var timer = get_tree().create_timer(timeScale * duration)
	await timer.timeout
	Engine.time_scale = 1
