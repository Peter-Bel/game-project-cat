extends Node2D

# variables
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer

var type = 0
var sprite

var move = Vector2(0,0)
var time = 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# mud
	if (sprite == "mud_particle"):
		animated_sprite_2d.frame = randi_range(0, 4)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# movement
	if (move != Vector2(0,0)):
		position += move

# set sprite
func spr(spr: String):
	animated_sprite_2d.play(spr)

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

func _on_timer_timeout() -> void:
	if (type == 1):
		self.queue_free()
