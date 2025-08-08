extends Enemy

@export_node_path var sprite_2d

var direction = 1
var sprite = "gem"
var gravity = 375.0

#gem
var gem_speed = 80.0
var gem_time = 0.0167 * 30

#rock
var rock_speed = randf_range(60.0, 100.0)


# ready
func _ready():
	pass

func _physics_process(delta: float) -> void:
	animated_sprite_2d.animation = sprite
	#gem
	if (animated_sprite_2d.animation == "gem"):
		if (gem_time > 0):
			gem_time -= delta
			animated_sprite_2d.set_rotation
			rotation = direction
		else:
			velocity = Vector2(cos(direction) * gem_speed, sin(direction) * gem_speed)
	#rock
	if (animated_sprite_2d.animation == "rock"):
		velocity.y = velocity.y + gravity * delta
		velocity.x = rock_speed * direction
	
	# Add the gravity.
	if (move_and_slide()):
		queue_free()
	move_and_slide()
