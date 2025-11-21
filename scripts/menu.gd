extends Node2D

func _ready() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		if visible:
			_resume_game()
		else:
			_pause_game()

func _pause_game():
	Globals.pause()
	show()

func _resume_game():
	Globals.resume()
	hide()

func _exit_game():
	Globals.exit()
