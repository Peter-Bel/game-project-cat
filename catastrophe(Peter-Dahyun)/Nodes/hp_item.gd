extends Area2D

@export var amount = 1
@export var consume_at_full = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	set_process(true)

# floating motion
var _base_y = INF
func _process(delta: float) -> void:
	if _base_y == INF:
		_base_y = position.y
	# bouncing
	position.y = _base_y + sin(Time.get_ticks_msec()/1000.0 * 3.0) * 2.0

func _on_body_entered(body: Node) -> void:
	if body is not Player:
		return
	
	var hp = body.health_node.health
	var max_hp = body.max_health
	
	# when player has full hearts
	if hp >= max_hp and not consume_at_full:
		return
		
	var new_hp = clamp(hp + amount, 0, max_hp)
	body.health_node.set_health(new_hp)
	if body.health_gui:
		body.health_gui.updateHearts(new_hp)
	GameManager.player_hp = new_hp
	print("HP 1 UP")
	
	# HP item disappears
	monitoring = false
	if has_node("CollisionShape2D"):
		$"CollisionShape2D".disabled = true
	queue_free()
