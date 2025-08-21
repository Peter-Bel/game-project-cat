extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var animation = "start"
@onready var player: Player = $"../Player"
var state = "Sit"

var start_time = 4


func _physics_process(delta: float) -> void:
	if (animation == "start"):
		# sit
		if (state == "Sit"):
			if (floor(animated_sprite_2d.frame) == 36):
				player.shake(7)
			if (animated_sprite_2d.frame >= 46):
				state = "Run"
		# run
		else:
			start_time -= delta
			if not is_on_floor():
				velocity += get_gravity() * delta
			velocity.x = SPEED
			if (start_time <= 0):
				get_tree().change_scene_to_file("res://Scenes/Levels/Level 1/Level1_Room1.tscn")
			else:
				start_time -= delta
	
	animated_sprite_2d.play(state)
	move_and_slide()
