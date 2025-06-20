extends Panel



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# update health
func update(whole: bool):
	var sprite = $Sprite2D
	if whole:
		sprite.frame = 0
	else:
		sprite.frame = 1
