extends Enemy

const speed = 50
var dir: Vector2 # 2 different ways change directions
var is_enemy_chase: bool #if it is true, enemy chase player. if not, enemy moves free

var player: CharacterBody2D

# variables


func _ready():
	# variables
	knock = 2.0
	# chase
	is_enemy_chase = false 
	$Timer.start()

func _process(delta):
	move(delta)
	handle_animation()
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
	if is_enemy_chase:
		player = GameManager.playerBody
		velocity = position.direction_to(player.position) * speed # the flying enemy's position sets to the player's position
		dir.x = abs(velocity.x) / velocity.x # the flying enemy follows the player
	if !is_enemy_chase:
		velocity += dir * speed * delta
	move_and_slide()

func _on_timer_timeout():
	$Timer.wait_time = choose([0.25, 0.5, 0.75]) # frequency of changing direction depends on the number of element in array
	if !is_enemy_chase: #when the enemy moves free
		dir = choose([Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN]) #choose direction randomly

func handle_animation():
	var animated_sprite = $AnimatedSprite2D
	animated_sprite.play("idle")
	if dir.x == -1:
		animated_sprite.flip_h = true
	elif dir.x == 1:
		animated_sprite.flip_h = false

func choose(array):
	array.shuffle() #shuffle the values in the given array
	return array.front() #choose whatever value in the front

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
