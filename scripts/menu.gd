extends Node

@onready var content: Panel = $Panel

func _ready() -> void:
	content.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		if content.visible:
			_resume_game()
		else:
			_pause_game()

func _pause_game():
	Globals.pause()
	content.show()

func _resume_game():
	Globals.resume()
	content.hide()

func _exit_game():
	Globals.exit()

func _on_check_button_toggled(toggled_on: bool) -> void:
	Settings.show_fps.emit(toggled_on)
