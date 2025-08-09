extends Enemy


var speed = 30.0
var direction = 1
@export_node_path var sprite_2d

var splat_size = 25
var splatter_count = 50

# ready
func _ready():
	pass

func _physics_process(delta: float) -> void:
	#movement
	velocity.x = speed
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		for i in splatter_count:
			GameManager.particle("mud_particle", 
			 global_position + Vector2(randf_range(-splat_size, splat_size), randf_range(-splat_size, splat_size)),
			 2, Vector2(randf_range(-0.5, 0.5), randf_range(-3.0, 0.0)), 0.0, [])
		queue_free()
	move_and_slide()
