extends Camera2D

# variables
var shake = 0
@onready var br = $BottomRight.get_global_position()
@onready var tl = $TopLeft.get_global_position()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	limit_bottom = br.y 
	limit_right = br.x
	limit_top = tl.y
	limit_left = tl.x
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (shake > 0):
		limit_bottom = br.y + shake
		limit_right = br.x + shake
		limit_top = tl.y - shake
		limit_left = tl.x - shake
		position.y += randf_range(-shake, shake)
		position.x += randf_range(-shake, shake)
		shake -= delta * 10
		if (shake <= 0):
			limit_bottom = br.y 
			limit_right = br.x
			limit_top = tl.y
			limit_left = tl.x
	
