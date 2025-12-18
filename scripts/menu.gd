extends Node

@onready var content: Panel = $Panel
@onready var font_option: OptionButton = $Panel/CenterContainer/MarginContainer/Main/Settings/VBoxContainer/FontsOptionButton

func _ready() -> void:
	content.visible = false
	_set_fonts_to_option_button()

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

func _set_fonts_to_option_button():
	var fonts: Array = Settings.fonts.keys()
	for font in fonts:
		font_option.add_item(font)
	font_option.selected = 0

func _on_font_changed(index: int) -> void:
	Settings.update_font(font_option.get_item_text(index))
