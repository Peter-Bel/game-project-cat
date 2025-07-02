extends Node2D

# variables
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var type = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# set sprite
func spr(spr: String):
	animated_sprite_2d.play(spr)
	animated_sprite_2d.frame = 0

# set image
func img(img: Array):
	var len = img.size()
	#flip x
	if (len >= 1):
		animated_sprite_2d.flip_h = img[0]
	if (len >= 2):
		animated_sprite_2d.flip_v = img[1]
	if (len >= 3):
		animated_sprite_2d.rotation = deg_to_rad(img[2])

# animation finish
func _on_animated_sprite_2d_animation_finished() -> void:
	if (type == 0):
		if animated_sprite_2d.animation_finished:
			self.queue_free()
