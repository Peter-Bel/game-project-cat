extends Control
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (animated_sprite_2d.frame >= 23):
		get_tree().change_scene_to_file("res://Scenes/Levels/Level 1/Level1_Room1.tscn")
