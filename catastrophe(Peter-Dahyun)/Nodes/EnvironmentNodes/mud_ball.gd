extends Enemy


var speed = 30.0
var direction = 1


# ready
func _ready():
	print(global_position)

func _physics_process(delta: float) -> void:
	#movement
	velocity.x = speed
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		queue_free()
	move_and_slide()
