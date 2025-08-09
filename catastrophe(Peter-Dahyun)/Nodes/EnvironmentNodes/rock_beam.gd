extends Enemy

@export_node_path var sprite_2d
@onready var collision_shape_2d: CollisionShape2D = $AttackArea/CollisionShape2D

@onready var player: Player = $"../../../Player"

var direction = 0.0

# ready
func _ready():
	pass

func _physics_process(delta: float) -> void:
	if (animated_sprite_2d.animation == "start"):
		if (floor(animated_sprite_2d.frame) <= 2):
			if (player): 
				look_at(player.global_position)
			# look_at(get_global_mouse_position())
			print(direction)
		if (floor(animated_sprite_2d.frame) == 5):
			animated_sprite_2d.animation = "beam"
			collision_shape_2d.disabled = false
	elif (animated_sprite_2d.animation == "beam"):
		if (floor(animated_sprite_2d.frame) == 4):
			collision_shape_2d.disabled = true
		if (floor(animated_sprite_2d.frame) >= 7):
			queue_free()
	
