extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# Attack area for player
func _on_attack_area_area_entered(body: Node2D) -> void:
	if (body is Player):
		body.damage(self, 1, 1.0, 1.0)
	print("Entered!")
	
