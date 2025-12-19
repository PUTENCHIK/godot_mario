extends Node

@onready var content: Panel = $Panel
@onready var show_fps_toggle: CheckButton = $Panel/CenterContainer/MarginContainer/Main/Settings/HBoxContainer/CheckButton
@onready var font_option: OptionButton = $Panel/CenterContainer/MarginContainer/Main/Settings/VBoxContainer/FontsOptionButton

func _ready() -> void:
	content.visible = false
	Settings.update_menu_elements.connect(_update_menu_elements)
	Globals.set_menu_size($Panel/CenterContainer)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu") and Globals.is_menu_available:
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

func _set_show_fps():
	show_fps_toggle.button_pressed = Settings.current_show_fps

func _set_fonts_to_option_button():
	var fonts: Array = Settings.fonts.keys()
	for font in fonts:
		font_option.add_item(font)
	font_option.selected = fonts.find(Settings.current_font)

func _update_menu_elements():
	_set_show_fps()
	_set_fonts_to_option_button()

func _on_check_button_toggled(toggled_on: bool) -> void:
	Settings.show_fps.emit(toggled_on)

func _on_font_changed(index: int) -> void:
	Settings.update_font(font_option.get_item_text(index))
