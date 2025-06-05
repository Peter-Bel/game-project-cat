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
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# variables
@onready var attack = $AttackArea
@onready var attack_shape = $AttackArea/AttackShape2D
@onready var cam = $Camera
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


# death
func death(time: int):
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
	
	### animation 
	# idle (base)
	if (spr_state == "Idle"): 
		if (health_node.health <= 0):
			spr_state = "Death"
			death(1)
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
