extends ColorRect

# variables
var play = ''


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.pause_screen()
	NavigationManager.scene_fade = self 
	# $AnimationPlayer.play('Dark')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (play != ''):
		$AnimationPlayer.play(play)
		play = ''

# animation
func fade(fade: bool):
	if (fade):
		play = 'Fade'
		GameManager.pause_screen()
	else:
		play = 'Open'

# unpause when finished
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if ($AnimationPlayer.assigned_animation == 'Open'):
		GameManager.unpause_screen()
