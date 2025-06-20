extends Node2D
class_name Enemy


# variables
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_node: Health = $Health
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var flash: AnimationPlayer = $AnimatedSprite2D/Flash


var death_time: Timer = null
var time_to_death = 0.2

var knock = 1.5
var knock_acc = 0.05
var direction = Vector2(0,0) 

var active = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (!death_time and health_node.health <= 0):
		death(time_to_death)
		animated_sprite.play("Death")
	if (health_node.health <= 0):
		position.x += direction.x * knock
		position.y += direction.y * knock
		knock = lerp(knock, 0.0, knock_acc)


# Attack area for player
func _on_attack_area_body_entered(body: Node2D) -> void:
	if (body is Player and active):
		# print("Enemy")
		var dir = global_position.direction_to(body.global_position)
		body.damage(1, dir)

# damage 
func damage(damage: int, dir: Vector2) -> void:
	if (health_node.imortal):
		pass
	else:
		direction = dir
		# set health
		health_node.set_health(health_node.health - damage)
		print(health_node.health)
		flash.play("hit_flash")


# death
func death(time: float):
	if death_time == null:
		active = false
		death_time = Timer.new()
		add_child(death_time)
		death_time.wait_time = time
		death_time.one_shot = true
		animated_sprite_2d.modulate = Color.DARK_GRAY
	# Connect its timeout signal to a function we want called
	death_time.timeout.connect(_on_death)
	# Start the timer
	death_time.start()
# death timer complete
func _on_death():
	# remove self
	self.queue_free()
