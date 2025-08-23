extends Enemy

const speed = 20
var dir_vec: Vector2 = Vector2.ZERO # 2 different ways change directions
var facing: int = 1
var is_enemy_chase: bool = false #if it is true, enemy chase player. if not, enemy moves free
var player: CharacterBody2D

# variables for poison powder attack
@export var poison_node: PackedScene = preload("res://Nodes/EnvironmentNodes/poison_powder.tscn")
@export var projectile_velocity_y: float = -100.0
@export var shoot_interval = 1.0 # reload time
@export var attack_range: float = 220.0 # shoot in this distance
var shoot_cd = 0.0
var is_shooting: bool = false
var fired_once: bool = false 

@onready var spr:AnimatedSprite2D = $AnimatedSprite2D
@onready var shoot_point: Marker2D = $PoisonPowder
@onready var timer: Timer = $Timer

func _ready():
	# chase
	is_enemy_chase = false 
	timer.start()
	timer.timeout.connect(_on_timer_timeout)
	# animation
	spr.frame_changed.connect(_on_sprite_frame_changed)
	spr.animation_finished.connect(_on_sprite_animation_finished)

func _physics_process(delta: float) -> void:
	# movement
	move(delta)
	handle_animation()
	## death 
	#if (!death_time and health_node.health <= 0):
		#animated_sprite_2d.modulate = Color.DIM_GRAY
		#death(time_to_death)
		## animated_sprite.play("Death")
	#if (health_node.health <= 0):
		#position.x += knock_dir.x * knock
		#position.y += knock_dir.y * knock
		#knock = lerp(knock, 0.0, knock_acc)
		
	# cooldown and check attack range. then shoot
	shoot_cd -= delta
	if is_enemy_chase and player:
		var distance = global_position.distance_to(player.global_position)
		if distance <= attack_range and shoot_cd <= 0.0 and not is_shooting:
			start_shoot()
	
	super(delta)

func move(delta):
	if is_enemy_chase:
		player = GameManager.playerBody
		if player:
			var move_dir = (player.global_position - global_position).normalized()
			velocity = move_dir * speed * spd_multiply
			facing = sign(velocity.x) # the flying enemy follows the player
	else:
		velocity += dir_vec * speed * delta

func _on_timer_timeout():
	timer.wait_time = choose([0.25, 0.5, 0.75]) # frequency of changing direction depends on the number of element in array
	if !is_enemy_chase: #when the enemy moves free
		dir_vec = choose([Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN]) #choose direction randomly

func handle_animation():
	if is_shooting or spr.animation == "shoot":
		return
	if spr.animation != "idle":
		spr.play("idle")
	spr.flip_h = (facing < 0)

func choose(array):
	return array.pick_random()
	
# start to chase the player if player enters in red collision
func _on_area_2d_body_entered(body):
	if body is Player:
			print("entered")
			is_enemy_chase = true
			player = body

# start to move rome if player leaves red collision
func _on_area_2d_body_exited(body):
	if body is Player:
		print("exit")
		is_enemy_chase = false
		player = null
		
func start_shoot():
	is_shooting = true
	fired_once = false
	spr.play("shoot")
	
func _on_sprite_frame_changed():
	if is_shooting and spr.animation == "shoot" and spr.frame == 4 and not fired_once:
		if player:
			summon_poison_projectile()
			fired_once = true

func _on_sprite_animation_finished():
	if spr.animation == "shoot":
		is_shooting = false
		shoot_cd = shoot_interval

func summon_poison_projectile() -> void:
	if poison_node == null or player == null:
		return
	var inst = poison_node.instantiate()
	get_tree().current_scene.add_child(inst)
	inst.global_position = shoot_point.global_position
	
	# direction and velocity toward player
	var dir = (player.global_position - inst.global_position).normalized()	
	var linear_speed = 180.0	
	if inst.has_method("launch"):
		inst.launch(dir, linear_speed)
