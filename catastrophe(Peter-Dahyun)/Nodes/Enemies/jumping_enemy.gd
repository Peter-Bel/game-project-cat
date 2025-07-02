extends Enemy


const speed = 10
var is_enemy_chase: bool = true
var is_charging_jump: bool = false
var is_jump_cycle_active: bool = false
var charge_timer = 0.0
const CHARGE_TIME = 0.73

var dead: bool = false

var dir: Vector2
const gravity = 750
var is_roaming: bool = true

var player: CharacterBody2D
var player_in_area = false

func _ready():
	# variables
	knock = 1.0
	# jump
	$JumpCycleTimer.stop()

func _process(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0
	
	player = GameManager.playerBody
	
	if is_charging_jump:
		charge_timer -= delta
		if charge_timer <= 0:
			start_jump()
		return
	move(delta)
	handle_animation()
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

func move(delta):
	if !dead:
		if !is_enemy_chase:
			velocity += dir * speed * delta
		elif is_enemy_chase:
			#var dir_to_player = position.direction_to(player.position) * speed
			#velocity.x = dir_to_player.x
			#dir.x = abs(velocity.x) / velocity.x
			var dir_to_player = position.direction_to(player.position)
			velocity.x = dir_to_player.x * speed
			dir.x = sign(velocity.x)
		is_roaming = true
	elif dead:
		velocity.x = 0
		
func handle_animation():
	var anim_sprite = $AnimatedSprite2D
	if is_charging_jump:
		anim_sprite.play("idle")
		anim_sprite.speed_scale = 2.0
	elif !dead: # and !taking_damage and !is_dealing_damage:
		anim_sprite.play("jump")
		if dir.x == -1:
			anim_sprite.flip_h = false
		elif dir.x == 1:
			anim_sprite.flip_h = true
	elif dead and is_roaming:
		is_roaming = false

func _on_timer_timeout():
	$Timer.wait_time = choose([0.5, 1.0, 1.5]) # randomize the movement of jumping enemy
	if !is_enemy_chase:
		dir = choose([Vector2.RIGHT, Vector2.LEFT])
		velocity.x = 0

func choose(array):
	array.shuffle()
	return array.front()
	
		
func start_jump():
	is_charging_jump = false
	var dir_to_player = position.direction_to(player.position) * speed
	velocity.y = -400	
	velocity.x = dir_to_player.x * 800
	$AnimatedSprite2D.play("jump")


func _on_area_2d_body_entered(body):
	if body is Player:
		print("entered")
		is_enemy_chase = true
		player = body
		player_in_area = true
		start_jump_now()
		start_jump_cycle()


func _on_area_2d_body_exited(body):
	if body is Player:
		print("exited")
		is_enemy_chase = false
		player_in_area = false
		stop_jump_cycle()

func start_jump_now():
	if is_on_floor():
		is_charging_jump = true
		charge_timer = CHARGE_TIME
		$AnimatedSprite2D.play("idle")
		$AnimatedSprite2D.speed_scale = 2.0

func start_jump_cycle():
	if !is_jump_cycle_active:
		is_jump_cycle_active = true
		$JumpCycleTimer.start()

func stop_jump_cycle():
	is_jump_cycle_active = false
	$JumpCycleTimer.stop()
	is_charging_jump = false
	
func _on_jump_cycle_timer_timeout():
	if player_in_area and is_on_floor():
		is_charging_jump = true
		charge_timer = CHARGE_TIME
		$AnimatedSprite2D.play("idle")
		$AnimatedSprite2D.speed_scale = 2.0
