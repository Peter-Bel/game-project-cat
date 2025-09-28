extends Control
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var scene_fade: ColorRect = $CanvasLayer/SceneFade

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (scene_fade):
		scene_fade.fade(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (animated_sprite_2d.frame > 40):
		get_tree().change_scene_to_file("res://Scenes/TitleScreen/TitleScreen.tscn")
