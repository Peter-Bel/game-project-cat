extends Enemy

# movement parameters
@export var speed = 30.0
# set height of hop jump. the more negative num, the higher hop
@export var hop_jump_vy = -300 # when enemy roams
@export var attack_jump_vy = -250 # when enemy attacks
@export var gravity = 1200.0
# Finite State Machine. Statements list of jumping enemy
enum State {IDLE, HOP, CHASE, ATTACK}
var state: State = State.IDLE
# initial direction
var dir = -1
# Raycast. Detect Wall
@onready var ray_wall_left = $RayWallL
@onready var ray_wall_right = $RayWallR
# Detect sensor 
@onready var detect_area = $ChaseArea
# Animation
@onready var spr: AnimatedSprite2D = $AnimatedSprite2D
# player
var player: CharacterBody2D
# timer for deciding enemy's movement (between "idle" and "jump")
var decide_timer = 0.0
# decison interval [0.7, 1.2]
@export var decision_interval = Vector2(0.7, 1.2)
var want_hop_impulse = false
# attack cooldown
var atk_cd = 0.0
@export var attack_cooldown = 1.0
var want_attack_impulse = false
# chase range
@onready var detect_chase_range = 100.0
# prevent flipping direction from colliding the player
var face_change_threshold = 4.0

func _ready():
	# Set initial statement and direction
	randomize()
	_set_state(State.IDLE)
	decide_timer = randf_range(decision_interval.x, decision_interval.y)
	_update_facing_visual()

# function to change direction when enemy collides wall
func _is_hitting_wall() -> bool:
	if dir == -1:
		return ray_wall_left and ray_wall_left.is_colliding()
	else:
		return ray_wall_right and ray_wall_right.is_colliding()
		
# function to detect player eneters in ChaseArea
func _on_area_2d_body_entered(body: Node):
	if body is Player:
		player = body
		print("player entered")
		_set_state(State.CHASE)
		
# function to return idle statement
func _on_area_2d_body_exited(body):
	if body is Player:
		print("player exited")
		player = null
		_set_state(State.IDLE)

func _is_player_in_range(scale = 1.0) -> bool:
	if player == null:
		return false
	return global_position.distance_to(player.global_position) <= detect_chase_range * scale

# 물리 프레인마다 실행되는 함수. "중력 적용", "상태별 행동", "이동" 처리
func _physics_process(delta: float):
	# gravity
	if !is_on_floor():
		velocity.y += gravity * delta
	# attack cooldown
	if atk_cd > 0.0:
		atk_cd = max(0.0, atk_cd - delta)
	if _is_hitting_wall():
		dir *= -1
		_update_facing_visual()
	
	# logics for each statements
	match state:
		# idle statement
		State.IDLE:
			#animation
			_play("idle")
			velocity.x = move_toward(velocity.x, 0.0, 2000 * delta)
			# decide state. idle:hop = 3:7
			decide_timer -= delta
			if decide_timer <= 0.0:
				decide_timer = randf_range(decision_interval.x, decision_interval.y)
				if randf() < 0.3:
					_set_state(State.IDLE)
				else:
					_set_state(State.HOP)
					want_hop_impulse = true
		# hop statement
		State.HOP:
			#animation
			_play("jump")
			# start hopping
			if want_hop_impulse and is_on_floor():
				velocity.y = hop_jump_vy
				velocity.x = speed * dir
				want_hop_impulse = false
			# aftering landing, return "idle" statement for next decision
			if is_on_floor() and velocity.y >= 0.0 and !want_hop_impulse:
				_set_state(State.IDLE)
		# chase statement
		State.CHASE:
			_play("jump")
			_face_towards_player()
			velocity.x = speed * dir
			if is_on_floor() and atk_cd <= 0.0 and _is_player_in_range():
				_set_state(State.ATTACK)
				want_attack_impulse = true
			# if the player is not in range, return idle state
			if player == null or !_is_player_in_range(1.3):
				_set_state(State.IDLE)
		# attack statement
		State.ATTACK:
			_play("jump")
			if want_attack_impulse and is_on_floor() and player != null:
				_face_towards_player()
				var sign_x = sign(player.global_position.x - global_position.x)
				velocity.x = speed * 1.3 * int(sign_x)
				velocity.y = attack_jump_vy
				want_attack_impulse = false
				atk_cd = attack_cooldown
			# aftering landing, return chase statement	
			if is_on_floor() and velocity.y >= 0.0 and atk_cd > 0.0:
				_set_state(State.CHASE) 
			
	move_and_slide()
	
	# death 
	if (!death_time and health_node.health <= 0):
		animated_sprite_2d.modulate = Color.DIM_GRAY
		death(time_to_death)
		# animated_sprite.play("Death")
	if (health_node.health <= 0):
		position.x += knock_dir.x * knock
		position.y += knock_dir.y * knock
		knock = lerp(knock, 0.0, knock_acc)
	
	# collide wall -> change dir
	if _is_hitting_wall():
		dir *= -1
		# flip animation
		_update_facing_visual()

# 현재 개구리의 상태를 바꿀때
# update enemy's statement
func _set_state(s: State):
	state = s
	if s == State.IDLE:
		decide_timer = randf_range(decision_interval.x, decision_interval.y)

# animation
func _play(anim: String):
	if spr.animation != anim:
		spr.play(anim)

func _update_facing_visual():
	spr.flip_h = (dir == 1)
	
func _face_towards_player():
	if player == null:
		return
	var dir_x = player.global_position.x - global_position.x
	if absf(dir_x) > face_change_threshold:
		dir = 1 if dir_x > 0.0 else -1
		_update_facing_visual()
