extends Enemy

# variables
const SPEED = 30
var direction = -1

@onready var health = 10
@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var ray_cast_bottomL = $RayCastBottomLeft
@onready var ray_cast_bottomR = $RayCastBottomRight


# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# if enemy detects  a wall, change its direction
	if ray_cast_right.is_colliding():
		direction = -1
	elif ray_cast_left.is_colliding():
		direction = 1
	# if enemy detects cliff, change its direction
	elif  direction == 1 and !ray_cast_bottomR.is_colliding():
		direction = -1
	elif direction == -1 and !ray_cast_bottomL.is_colliding():
		direction = 1
	animated_sprite.flip_h = direction == -1
	position.x += direction * SPEED * delta	* spd_multiply
	# death 
	if (!death_time and health_node.health <= 0):
		death(time_to_death)
		animated_sprite.play("Death")
	if (health_node.health <= 0):
		position.x += knock_dir.x * knock
		position.y += knock_dir.y * knock
		knock = lerp(knock, 0.0, knock_acc)
