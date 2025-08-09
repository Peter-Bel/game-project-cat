extends Enemy

var time = 0.0167 * 10
var direction = 1
@onready var attack_area: Area2D = $AttackArea

# ready
func _ready():
	pass

func _physics_process(delta: float) -> void:
	if (direction < 0):
		attack_area.position.x  = abs(attack_area.position.x)*-1
		direction = 0
	time -= delta
	if (time <= 0):
		queue_free()
