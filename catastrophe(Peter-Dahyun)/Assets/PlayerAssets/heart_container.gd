extends HBoxContainer
class_name Heart 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# max hearts function
func setMaxHearts(max: int):
	var heartGuiClass = preload("res://Assets/PlayerAssets/heart_gui.tscn")
	for i in range(max):
		var heart = heartGuiClass.instantiate()
		add_child(heart)

func updateHearts(current: int):
	var hearts = get_children()
	# update to empty / full
	for i in range(current):
		hearts[i].update(true)
	for i in range(current, hearts.size()):
		hearts[i].update(false)
