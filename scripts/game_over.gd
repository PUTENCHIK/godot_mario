extends Node

@export var loss_text: String = "GAME OVER!"
@export var win_text: String = "YOU WON!"

@onready var content: Panel = $Panel
@onready var main_label: Label = $Panel/CenterContainer/VBoxContainer/MainLabel
@onready var score_label: Label = $Panel/CenterContainer/VBoxContainer/ScoreBox/Score
@onready var audio: AudioStreamPlayer = $Audio

func _ready() -> void:
	content.hide()
	Globals.set_menu_size($Panel/CenterContainer)
	Globals.show_game_over_menu.connect(_on_show_game_over_menu)

func _on_show_game_over_menu(is_win: bool):
	_update_score()
	_update_text(is_win)
	if not audio.playing:
		audio.play()
	Globals.is_menu_available = false
	content.show()
	Globals.pause()

func _update_score():
	score_label.text = str(Globals.score)

func _update_text(is_win: bool):
	main_label.text = win_text if is_win else loss_text

func _on_restart_button_pressed() -> void:
	content.hide()
	audio.stop()
	Globals.restart_level.emit(true)

func _on_exit_button_pressed() -> void:
	Globals.exit()
