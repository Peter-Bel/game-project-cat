extends CharacterBody2D
class_name Player

# constants 
const SPEED = 450.0
const ACC = 30
const JUMP_VELOCITY = -200.0
const JUMP_COOLDOWN = 0.0167 * 4
const JUMP_INCREASE = -18.0
const JUMP_INCREASE_ACC = 55
const ATTACK_TIME = 50
const ATTACK_ACC = 20
const ATTACK_DAMAGE = 100
const ATTACK_DOWN_Y = -200.0
const ATTACK_UP_Y = 75.0
const SPIN_ACC = 5
const SPIN_VELOCITY_X = 185
const SPIN_VELOCITY_Y = 250
const SPIN_X_UP = -110
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var disable: bool = false

# variables
@onready var attack = $AttackArea
@onready var attack_shape_2d: CollisionShape2D = $AttackArea/AttackShape2D
@onready var attack_shape_up_2d: CollisionShape2D = $AttackArea/AttackShapeUp2D
@onready var attack_shape_down_2d: CollisionShape2D = $AttackArea/AttackShapeDown2D
@onready var cam = $Camera
@onready var scene_fade: ColorRect = $"../CanvasLayer/SceneFade"
var spr_state = "Idle"
var state_time = 0

var jump_cooldown = 0
var floor_cooldown = 0
var jump_increase = 0.0

@onready var health_node = $Health
@onready var max_health = health_node.max_health
@onready var health_gui: HBoxContainer = $"../CanvasLayer/heartContainer"
@onready var flash: AnimationPlayer = $AnimatedSprite2D/Flash

var knock = 325
var hurt_time = 0.0167 * 10
var death_time: Timer = null
var time_to_death = 2

var spin = true
var dash_dir_x = 0
var dash_dir_y = 0
var spin_time = 0.0167 * 20

var spd = SPEED
var spd_multiply = 1
var spd_multiply_type = ""

var able_to_climb = false
var climb_spd = 1500.0
var climb_spd_x = 35.0
var climb_jump = -200.0
var climb_regrab_buffer = 0
var climb_regrab_buffer_time = 0.0167 * 15


# ready
func _ready():
	NavigationManager.on_trigger_player_spawn.connect(_on_spawn)
	# health setting
	if (health_gui and health_node):
		health_gui.setMaxHearts(max_health)
		if (GameManager.player_hp < 0):
			health_node.set_health(max_health)
			health_gui.updateHearts(max_health)
		else:
			health_node.set_health(GameManager.player_hp)
			health_gui.updateHearts(health_node.health)
# scene fading
	if scene_fade:
		scene_fade.fade(false)
	else:
		GameManager.unpause_screen()
	# go to the flying enemy.gd, move func 
	GameManager.playerBody = self


# death
func death(time: float):
	if death_time == null:
		death_time = Timer.new()
		add_child(death_time)
		death_time.wait_time = time
		death_time.one_shot = true
	# Connect its timeout signal to a function we want called
	death_time.timeout.connect(_on_death)
	# Start the timer
	death_time.start()
# death timer complete
func _on_death():
	# health reset
	GameManager.player_hp = max_health
	# reload
	get_tree().reload_current_scene()


# spawning position (scene transition)
func _on_spawn(position: Vector2, direction: String):
	global_position = position
	global_position.y += 5
	if (direction == "right"): 
		animated_sprite.flip_h = true
	else:
		animated_sprite.flip_h = false


# Main event
func _physics_process(delta: float) -> void:
	if (disable):
		return
	
	# speed
	spd = SPEED * spd_multiply
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		spin = true
	
	### Handle jump.
	# timers
	if Input.is_action_just_pressed("jump"): jump_cooldown = JUMP_COOLDOWN 
	if is_on_floor(): floor_cooldown = JUMP_COOLDOWN;
	# start jumping
	if (jump_cooldown > 0) and spr_state == "Idle": # jumping
		if (is_on_floor() or floor_cooldown > 0):
			velocity.y = JUMP_VELOCITY
			jump_increase = JUMP_INCREASE
	# jump boost
	if (jump_increase < -1 and Input.is_action_pressed("jump")):
		velocity.y += jump_increase;
	# lower timer
	if (jump_cooldown > 0): 
		jump_cooldown -= delta; 
	if (floor_cooldown > 0): 
		floor_cooldown -= delta;
	jump_increase = lerp(0.0, jump_increase, JUMP_INCREASE_ACC * delta)
	
	## Horizontal Movement
	# Get input direction (-1, 0, 1)
	var direction = Input.get_axis("left", "right")
	var direction_ud = Input.get_axis("up", "down")
	# flip sprite
	if (spr_state == "Idle"):
		if (direction > 0): animated_sprite.flip_h = false
		elif (direction < 0): animated_sprite.flip_h = true
		# direction
		if direction:
			velocity.x = lerp(velocity.x, direction * spd, ACC * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, spd)
	
	## Spin Direction 
	dash_dir_x = direction
	dash_dir_y = Input.get_axis("up", "down")
	
	### animation and states
	# idle (base)
	if (spr_state == "Idle"): 
		if (health_node.health <= 0):
			spr_state = "Death"
			death(1)
		elif Input.is_action_just_pressed("spin") and (dash_dir_x != 0 or dash_dir_y != 0) and spin: # spin
			spr_state = "Spin"
			state_time = spin_time
			spin = false
			if (dash_dir_y != 0):
				velocity.y = SPIN_VELOCITY_Y * dash_dir_y
				GameManager.particle("player_dash", position, 0, Vector2(0, 0), 0.0, [false, false ,90 * sign(dash_dir_y) + (20 * sign(dash_dir_x) * sign(-dash_dir_y))])
			else:
				GameManager.particle("player_dash", position, 0, Vector2(0, 0), 0.0, [animated_sprite.flip_h, false, 0])
				velocity.x += SPIN_VELOCITY_X * dash_dir_x
				velocity.y = SPIN_X_UP
		elif Input.is_action_just_pressed("attack"): # attack
			if (direction_ud > 0 and !is_on_floor()):
				spr_state = "Attack_Down"
			if (direction_ud < 0):
				spr_state = "Attack_Up"
			if (direction_ud == 0):
				spr_state = "Attack" 
		elif Input.is_action_pressed("up") and able_to_climb and climb_regrab_buffer <= 0:
			spr_state = "Climb"
		elif (!is_on_floor()): # air
			spr_state = "Air"
		elif (direction != 0): # run
			spr_state = "Run"
	# air 
	if (spr_state == "Air"):
		animated_sprite.frame = sign(velocity.y)
	# play sprite
	animated_sprite.play(spr_state)
	
	## Spin
	if (spr_state == "Spin"):
		# x velocity
		velocity.x = lerp(velocity.x, spd * direction, SPIN_ACC * delta)
		# reset 
		if is_on_floor() and state_time != spin_time:
			state_time = 0
	
	## Climb
	if (spr_state == "Climb"):
		velocity.x = lerp(velocity.x, climb_spd_x * direction, delta * ACC)
		if (Input.is_action_pressed("up")):
			velocity.y = -climb_spd * delta
		elif (Input.is_action_pressed("down")):
			velocity.y = climb_spd * delta
		else:
			animated_sprite.frame = 0
			velocity.y = 0
		if (Input.is_action_pressed("jump")):
			velocity.y = climb_jump
			jump_increase = JUMP_INCREASE
			spr_state = "Idle"
			climb_regrab_buffer = climb_regrab_buffer_time
		if (able_to_climb):
			spin = true
			state_time = delta
	if (climb_regrab_buffer > 0):
		climb_regrab_buffer -= delta 
		print(climb_regrab_buffer)
	
	### Attack
	attack_shape_2d.disabled = true
	attack_shape_down_2d.disabled = true
	attack_shape_up_2d.disabled = true
	# flip collision
	if animated_sprite.flip_h and spr_state == "Attack":
		attack.position.x  = abs(attack.position.x)*-1
	else: 
		attack.position.x  = abs(attack.position.x)
	# attacking sprite
	if (spr_state == "Attack" or spr_state == "Attack_Up" or spr_state == "Attack_Down"):
		# time reduction and hitbox time
		state_time = delta
		if (animated_sprite.frame < 2):
			if (spr_state == "Attack"):
				attack_shape_2d.disabled = false
			elif (spr_state == "Attack_Up"):
				attack_shape_up_2d.disabled = false
			elif (spr_state == "Attack_Down"):
				attack_shape_down_2d.disabled = false
		# movement
		if (is_on_floor()):
			velocity.x = lerp(velocity.x, direction * (spd / 3), ATTACK_ACC * delta)
		else: 
			velocity.x = lerp(velocity.x, direction * spd, ATTACK_ACC * delta)
		# reset
		if animated_sprite.frame > 3:
			spr_state = "Idle"
	# attacking sprite for down
	if (spr_state == "Attack_Down"):
		if (is_on_floor()):
			spr_state = "Idle"
	
	# death
	if (spr_state == "Death"):
		state_time = 2
		velocity.x = lerp(velocity.x, 0.0, 0.1)
	
	### reset sprite state
	if (state_time <= 0): 
		spr_state = "Idle"
	else: 
		state_time -= delta
	
	### image 
	# death and imortal
	if (health_node.imortal and spr_state != "Hurt"):
		animated_sprite.modulate.a = randi_range(0, 1) * 1
	else:
		animated_sprite.modulate.a = 1
	
	# movment
	move_and_slide()


# damage and health
func damage(damage: int, direction: Vector2) -> void:
	# imortal
	if !health_node.imortal:
		# knockback, states, and game feel
		velocity.x = direction.x * knock
		velocity.y = (direction.y * knock/2) - knock/3
		cam.shake = 7
		spr_state = "Hurt"
		state_time = hurt_time
		flash.play("hit_flash")
		GameManager.freeze_frame(0.15, 0.2)
		# set health
		health_node.set_health(health_node.health - damage)
		health_node.set_imortal_time(1.5)
		GameManager.player_hp = health_node.health
		if (health_gui):
			health_gui.updateHearts(health_node.health)


# Enemy Attack
func _on_attack_area_body_entered(body: Node2D) -> void:
	if body is Enemy:
		# attack up and down velocity
		if (spr_state == "Attack_Up"):
			velocity.y += ATTACK_UP_Y
		elif (spr_state == "Attack_Down"):
			if (velocity.y > ATTACK_DOWN_Y):
				velocity.y = ATTACK_DOWN_Y
			else:
				velocity.y += ATTACK_DOWN_Y / 2
		# image stats
		cam.shake = 5
		var p_pos = body.global_position
		var dir = global_position.direction_to(body.global_position)
		var dist = global_position.distance_to(body.global_position)
		var mid = (global_position + body.global_position) / 2
		body.damage(ATTACK_DAMAGE, dir)
		# particle
		GameManager.freeze_frame(0.15, 0.1)
		GameManager.particle("player_attack_hit", mid, 0, Vector2(0, 0), 0.0, [animated_sprite.flip_h, false, 0])


func shake(amount: int) -> void:
	cam.shake = amount
