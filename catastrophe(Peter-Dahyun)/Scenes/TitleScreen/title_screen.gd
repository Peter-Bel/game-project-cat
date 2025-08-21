extends Control

@onready var main_buttons: VBoxContainer = $Buttons/MainButtons
@onready var controls: Panel = $Controls

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_buttons.visible = true
	controls.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/Level 1/Level1_Room1.tscn")

func _on_controls_button_pressed() -> void:
	print ("Controls pressed")
	main_buttons.visible = false
	controls.visible = true

func _on_credits_button_pressed() -> void:
	print ("Credits pressed")

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_back_button_pressed() -> void:
	_ready()
