extends Enemy


const SPEED = 75.0
const JUMP_VELOCITY = -400.0

var flip = 1

@onready var health: Health = $Health
# var max_health = health.max_health

var state_choose_close = ["run", "swing", "swing", "gem_attack"]
var state_choose_far = ["run", "gem_attack", "beam"]
var state_choose = state_choose_far
var state_choose_max = state_choose.size()

var state = "default"
var state_timer = 0.0
var time_to_action_min = 0.0167 * 30
var time_to_action_max = 0.0167 * 110

var run_time_min = 0.0167 * 90
var run_time_max = 0.0167 * 150
var run_time = randf_range(run_time_min, run_time_max)

var gem_count = 14
var gem_offset = 28

var rock_velocity_y = [-75, -225]

@onready var player: Player = $"../../Player"

var rock_node = preload("res://Nodes/EnvironmentNodes/rock_attacks.tscn")
var beam_node = preload("res://Nodes/EnvironmentNodes/rock_beam.tscn")
var swing_node = preload("res://Nodes/EnvironmentNodes/rock_swing.tscn")

func _physics_process(delta: float) -> void:
	if (state == "default"):
		if (state_timer <= 0):
			state_timer = randf_range(time_to_action_min, time_to_action_max)
			print(state_timer)
			state = state_choose[randi_range(0, state_choose_max-1)]
		else:
			state_timer -= delta
			flip = sign(player.global_position.x - global_position.x)
	elif (state == "run"):
		if (is_on_wall()):
			flip *= -1
		velocity.x = SPEED * flip
		if (run_time > 0):
			run_time -= delta
		else:
			state = "default"
			velocity.x = 0
			run_time = randf_range(run_time_min, run_time_max)
	elif (state == "gem_attack"):
		if (floor(animated_sprite.frame) == 6):
			animated_sprite.frame += 1
			for i in gem_count:
				summon_gems(deg_to_rad(170 + (200/(gem_count-1))*i), gem_offset)
		if (floor(animated_sprite.frame) >= 8):
			state = "default"
	elif (state == "beam"):
		if (floor(animated_sprite.frame) == 11):
			animated_sprite.frame += 1
			summon_beam(25)
		if (floor(animated_sprite.frame) >= 26):
			state = "default"
	elif (state == "swing"):
		if (floor(animated_sprite.frame) == 9):
			animated_sprite.frame += 1
			summon_stones(25)
			summon_stones(35)
			summon_swing()
		elif (floor(animated_sprite.frame) >= 17):
			state = "default"
	
	animated_sprite_2d.flip_h = flip - 1
	animated_sprite_2d.play(state)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()
	# death 
	if (!death_time and health_node.health <= 0):
		death(time_to_death)
	if (health_node.health <= 0):
		position.x += knock_dir.x * knock
		position.y += knock_dir.y * knock
		knock = lerp(knock, 0.0, knock_acc)
		get_tree().change_scene_to_file("res://Scenes/TitleScreen/CutScene2.tscn")

func summon_gems(angle: float, offset: float):
	# print("summoning fail")
	var inst = rock_node.instantiate()
	inst.set_name("gem")
	add_child(inst)
	inst.direction = angle
	inst.global_position = global_position 
	inst.global_position.x += cos(angle) * offset
	inst.global_position.y += sin(angle) * offset

func summon_beam(offset: float):
	# print("summoning fail")
	var inst = beam_node.instantiate()
	var inst_pos = Vector2(global_position.x, global_position.y - offset)
	# inst.direction = (inst_pos).angle_to(player.global_position) 
	inst.set_name("beam")
	add_child(inst)
	inst.global_position = global_position 
	inst.global_position.y -= offset

func summon_stones(offset: float):
	# stones
	var inst = rock_node.instantiate()
	inst.set_name("rock")
	add_child(inst)
	inst.sprite = "rock"
	inst.direction = flip
	inst.global_position = global_position 
	inst.global_position.x += offset * flip
	inst.velocity.y = randi_range(rock_velocity_y[0], rock_velocity_y[1])

func summon_swing():
	var inst = swing_node.instantiate()
	inst.set_name("swing")
	add_child(inst)
	inst.direction = flip
	inst.global_position = global_position

func _on_close_area_body_entered(body: Node2D) -> void:
	if (body is Player):
		state_choose = state_choose_close
		state_choose_max = state_choose.size()

func _on_close_area_body_exited(body: Node2D) -> void:
	if (body is Player):
		state_choose = state_choose_far
		state_choose_max = state_choose.size()
