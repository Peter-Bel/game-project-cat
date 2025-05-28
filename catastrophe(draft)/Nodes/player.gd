extends CharacterBody2D
class_name Player

# constants 
const SPEED = 150.0
const ACC = 30
const MAX_HP = 3
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


# ready
func _ready():
	NavigationManager.on_trigger_player_spawn.connect(_on_spawn)



# spawning position (scene transition)
func _on_spawn(position: Vector2, direction: String):
	global_position = position
	global_position.y += 5
	print(direction)
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
		if Input.is_action_just_pressed("attack"): # attack
			spr_state = "Attack" 
			cam.shake = 5
		elif (!is_on_floor()): # air
			spr_state = "Air"
		elif (direction != 0): # run
			spr_state = "Run"
	# air 
	if (spr_state == "Air"):
		animated_sprite.frame = sign(velocity.y)
	# play sprite
	animated_sprite.play(spr_state)
	
	
	### Attackd
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
	
	
	### reset sprite state
	if (state_time <= 0): 
		spr_state = "Idle"
	else: 
		state_time -= delta
	
	move_and_slide()



# damage and health
func damage(node: Node2D, damage: int, knock: float, direction: float):
	velocity.y -= 100


# attack collision
func _on_attack_area_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
