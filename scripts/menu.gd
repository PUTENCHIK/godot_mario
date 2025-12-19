extends Node

@onready var content: Panel = $Panel
@onready var show_fps_toggle: CheckButton = $Panel/CenterContainer/MarginContainer/Main/Settings/HBoxContainer/CheckButton
@onready var font_option: OptionButton = $Panel/CenterContainer/MarginContainer/Main/Settings/VBoxContainer/FontsOptionButton
@onready var music_slider: HSlider = $Panel/CenterContainer/MarginContainer/Main/Settings/MusicBox/MusicValue
@onready var sounds_slider: HSlider = $Panel/CenterContainer/MarginContainer/Main/Settings/SoundsBox/SoundsValue

func _ready() -> void:
	content.visible = false
	Globals.set_menu_size($Panel/CenterContainer)
	Settings.update_menu_elements.connect(_update_menu_elements)
	Settings.update_bus_sliders.connect(_update_bus_sliders)

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

func _update_bus_sliders():
	music_slider.value = Settings.current_music_bus
	sounds_slider.value = Settings.current_sounds_bus

func _on_check_button_toggled(toggled_on: bool) -> void:
	Settings.show_fps.emit(toggled_on)

func _on_font_changed(index: int) -> void:
	Settings.update_font(font_option.get_item_text(index))

func _on_music_value_value_changed(value: float) -> void:
	Settings.update_audio_bus("Music", value)

func _on_sounds_value_value_changed(value: float) -> void:
	Settings.update_audio_bus("Sounds", value)
