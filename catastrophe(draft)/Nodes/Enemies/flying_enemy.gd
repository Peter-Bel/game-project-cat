extends CharacterBody2D

var speed = 200
var motion = Vector2.ZERO
var player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	motion = Vector2.ZERO
	if player:
		motion = position.direction_to(player.position) * speed
	velocity = motion
	move_and_slide()

func _on_area_2d_body_entered(body):
	print("entered")
	player = body
	pass # Replace with function body.


func _on_area_2d_body_exited(body):
	print("exit")
	player = null
	pass # Replace with function body.
