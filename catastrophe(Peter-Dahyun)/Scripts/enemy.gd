extends CharacterBody2D
class_name Enemy

# variables 
@onready var animated_sprite = $AnimatedSprite2D
@onready var health_node: Health = $Health
@onready var flash: AnimationPlayer = $AnimatedSprite2D/Flash
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var death_time: Timer = null
var time_to_death = 0.2

# Knockback settings
@export var knock_strength = 220.0
@export var knock_up = -120.0
@export var knock_duration = 0.25
@export var knock_friction = 1400.0
@export var gravity = 1200.0

var knock_time = 0.0
var knock_vel: Vector2= Vector2.ZERO

#var knock = 1.5
#var knock_acc = 0.05
#var knock_dir = Vector2(0,0) 

var active = true

var spd_multiply = 1
var spd_multiply_type = ""

# Attack area for player
func _on_attack_area_body_entered(body: Node2D) -> void:
	if (body is Player and active):
		# print("Enemy")
		var dir = global_position.direction_to(body.global_position)
		body.damage(1, dir)

# damage 
func damage(dmg: int, attacker_to_enemy: Vector2) -> void:
	if (health_node.imortal):
		return
		#knock_dir = dir
		# set health
	health_node.set_health(health_node.health - dmg)
		# print(health_node.health)
	if is_instance_valid(flash):
		flash.play("hit_flash")
		
	# knockback start
	_start_knockback(attacker_to_enemy)
		
	if (health_node.health <= 0):
		active = false
		death(time_to_death)

# death
func death(time: float) -> void:
	if death_time != null:
		#active = false
		return
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
func _on_death() -> void:
	# remove self
	self.queue_free()

# spd multiply
func speed_multiplier(mult: float, type: String):
	if (mult < spd_multiply):
		spd_multiply = mult
		spd_multiply_type = type
	elif (mult == 1 and (type == spd_multiply_type or spd_multiply_type == "")):
		spd_multiply = 1
		spd_multiply_type = ""

#function for knockback motion
func _start_knockback(attacker_to_enemy: Vector2) -> void:
	var knock_dir = attacker_to_enemy.normalized()
	knock_vel = Vector2(knock_dir.x * knock_strength, knock_up)
	knock_time = knock_duration
	
func _update_knockback(delta: float) -> void:
	if knock_time <= 0.0:
		return
	knock_time -= delta
	knock_vel.y += gravity * delta
	knock_vel.x = move_toward(knock_vel.x, 0.0, knock_friction * delta)
	velocity += knock_vel
	if is_on_floor() and knock_vel.y > 0.0:
		knock_vel.y = 0.0
	
func _physics_process(delta: float) -> void:
	# knockback
	#if knock_time > 0.0:
		#knock_time -= delta
		#knock_vel.y += gravity * delta
		#knock_vel.x = move_toward(knock_vel.x, 0.0, knock_friction * delta)
		#
		#velocity += knock_vel
		#
		#if is_on_floor() and knock_vel.y > 0.0:
			#knock_vel.y = 0.0
	_update_knockback(delta)
	move_and_slide()
