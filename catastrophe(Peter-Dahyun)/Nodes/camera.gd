extends Camera2D

# variables
var shake = 0
var shake_max = 0
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
	# reset shake
	if (shake <= 0):
		shake_max = 0
	if (shake_max > 0):
		if (shake < shake_max):
			shake = shake_max
	# player and shake
	var player = get_parent()
	if (shake > 0):
		limit_bottom = br.y + shake
		limit_right = br.x + shake
		limit_top = tl.y - shake
		limit_left = tl.x - shake
		global_position.y = player.global_position.y + randf_range(-shake, shake)
		global_position.x = player.global_position.x + randf_range(-shake, shake)
		shake -= delta * 10
		if (shake <= 0):
			limit_bottom = br.y 
			limit_right = br.x
			limit_top = tl.y
			limit_left = tl.x
			global_position.y = player.global_position.y
			global_position.x = player.global_position.x
		shake_max = shake
