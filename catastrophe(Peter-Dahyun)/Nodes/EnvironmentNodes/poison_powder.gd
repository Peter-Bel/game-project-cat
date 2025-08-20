extends Enemy

@export var speed = 200.0
#@export var velocity_y: float = -300.0
@export var hit_on_floor: bool = true
@export var lasting_time: float = 2.0
@export var use_gravity = false

var vel =  Vector2.ZERO

func launch(dir: Vector2, spd:float = speed):
	speed = spd
	vel = dir.normalized() * speed
	rotation = vel.angle()
	# animation
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("poison")
	# timer	for lasting poison in the air
	get_tree().create_timer(lasting_time).timeout.connect(queue_free)
	# player damage
	if has_node("AttackArea"):
		$AttackArea.body_entered.connect(_on_powder_hit)
# ready
#func _ready() -> void:
	#velocity.y = velocity_y
	#if has_node("AnimatedSprite2D"):
		#$AnimatedSprite2D.play("poison")	
	#if has_node("AttackArea"):
		#$AttackArea.body_entered.connect(_on_powder_hit)
	## timer for lasting poison in the air
	#get_tree().create_timer(lasting_time).timeout.connect(queue_free)
		
func _physics_process(delta: float) -> void:
	##movement
	#velocity.x = speed	
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta	
	#move_and_slide()
	## when poison hit floor or wall
	#if is_on_floor() and hit_on_floor:
		#queue_free()
	#elif is_on_ceiling() and hit_on_floor:
		#queue_free()
	#elif is_on_wall() and hit_on_floor:
		#queue_free()	
	#movement
	velocity = vel
	if use_gravity:
		velocity += get_gravity() * delta
	move_and_slide()
	# when poison hit floor or wall
	if is_on_floor() and hit_on_floor:
		queue_free()
	elif is_on_ceiling() and hit_on_floor:
		queue_free()
	elif is_on_wall() and hit_on_floor:
		queue_free()	

# when poison hits player
func _on_powder_hit(body: Node2D) -> void:
	super._on_attack_area_body_entered(body)
	queue_free()
	
