extends CharacterBody2D
class_name Player

# constants 
const SPEED = 150.0
const ACC = 30
const JUMP_VELOCITY = -200.0
const JUMP_COOLDOWN = 0.0167 * 4
const JUMP_INCREASE = -18.0
const JUMP_INCREASE_ACC = 55
const ATTACK_TIME = 50
const ATTACK_ACC = 20
const ATTACK_DAMAGE = 10
const SPIN_ACC = 5
const SPIN_VELOCITY_X = 185
const SPIN_VELOCITY_Y = 250
const SPIN_X_UP = -110
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# variables
@onready var attack = $AttackArea
@onready var attack_shape = $AttackArea/AttackShape2D
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
	# flip sprite
	if (spr_state == "Idle"):
		if (direction > 0): animated_sprite.flip_h = false
		elif (direction < 0): animated_sprite.flip_h = true
		# direction
		if direction:
			velocity.x = lerp(velocity.x, direction * SPEED, ACC * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
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
			spr_state = "Attack" 
			cam.shake = 3
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
		velocity.x = lerp(velocity.x, SPEED * direction, SPIN_ACC * delta)
		# reset 
		if is_on_floor() and state_time != spin_time:
			state_time = 0
	
	### Attack
	attack_shape.disabled = true
	# flip collision
	if animated_sprite.flip_h:
		attack.position.x  = abs(attack.position.x)*-1
	else: 
		attack.position.x  = abs(attack.position.x)
	# attacking sprite
	if (spr_state == "Attack"):
		# time reduction and hitbox time
		state_time = delta
		if (animated_sprite.frame < 2):
			attack_shape.disabled = false
		# movement
		if (is_on_floor()):
			velocity.x = lerp(velocity.x, direction * (SPEED / 3), ATTACK_ACC * delta)
		else: 
			velocity.x = lerp(velocity.x, direction * SPEED, ATTACK_ACC * delta)
		# reset
		if animated_sprite.frame > 3:
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
func _on_attack_area_area_entered(area: Area2D) -> void:
	# get correct area2D
	var parent = null
	if (area.name == "Area2D"):
		parent = area.get_parent()
	# if enemy
	if parent is Enemy:
		cam.shake = 5
		var p_pos = parent.global_position
		var dir = global_position.direction_to(parent.global_position)
		var dist = global_position.distance_to(parent.global_position)
		var mid = (global_position + parent.global_position) / 2
		parent.damage(ATTACK_DAMAGE, dir)
		# particle
		GameManager.freeze_frame(0.15, 0.1)
		GameManager.particle("player_attack_hit", mid, 0, Vector2(0, 0), 0.0, [animated_sprite.flip_h, false, 0])
