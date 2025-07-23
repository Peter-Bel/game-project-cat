extends Node

# player values
var player_hp = -1
#particles
var particle_node = preload("res://Nodes/ParticlesAndGui/particle.tscn")

# playerBody for flying enemy.gd
# go to player.gd and find Gamemager in the _ready func
var playerBody: CharacterBody2D

# freeze frame
func freeze_frame(timeScale, duration):
	Engine.time_scale = timeScale
	var timer = get_tree().create_timer(timeScale * duration)
	await timer.timeout
	Engine.time_scale = 1

# create particles
func particle(spr: String, pos: Vector2, type: int, move: Vector2, speed: float, img: Array):
	var inst = particle_node.instantiate()
	# type
	inst.type = type
	# sprite
	inst.sprite = spr
	# position and initialize
	inst.position = pos
	add_child(inst)
	# movement
	inst.move = move
	# sprite setting
	inst.spr(spr)
	# image setting
	inst.img(img)

# pause and unpause for screen transition
func pause_screen():
	get_tree().paused = true
func unpause_screen():
	get_tree().paused = false
