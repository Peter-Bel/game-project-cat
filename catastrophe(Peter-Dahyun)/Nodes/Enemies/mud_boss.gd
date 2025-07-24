extends Enemy


const SPEED = 200.0
const JUMP_VELOCITY = -400.0

var flip = 1

var state = "default"
var state_timer = 0.0
var time_to_action_min = 0.0167 * 90
var time_to_action_max = 0.0167 * 150

@onready var player: Player = $"../../Player"

var mud_node = preload("res://Nodes/EnvironmentNodes/mud_ball.tscn")
var projectile_y_spd = -500.0

func _physics_process(delta: float) -> void:
	if (state == "default"):
		if (state_timer <= 0):
			state_timer = randf_range(time_to_action_min, time_to_action_max)
			state = "spit"
		else:
			state_timer -= delta
			flip = sign(player.global_position.x - global_position.x)
	elif (state == "spit"):
		if (floor(animated_sprite_2d.frame) == 8):
			animated_sprite_2d.frame += 1
			summon_mud_projectile((player.global_position.x - global_position.x)
			 * ((projectile_y_spd / get_gravity().y) * 2) * -1)
		if (animated_sprite_2d.frame >= 13):
			state = "default"
	elif (state == "jump_squat"):
		if (floor(animated_sprite_2d.frame) == 6):
			state = "junmp"
			position.y -= 1
			velocity.y = -400.0
	elif (state == "jump"):
		if (is_on_floor()):
			state = "default"
	
	animated_sprite_2d.flip_h = flip - 1
	animated_sprite_2d.play(state)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()

func summon_mud_projectile(mud_speed: float):
	# print("summoning fail")
	var inst = mud_node.instantiate()
	inst.set_name("mud")
	add_child(inst)
	inst.global_position = global_position 
	inst.global_position.y -= 24.0
	inst.velocity.y = projectile_y_spd
	inst.speed = mud_speed
	
