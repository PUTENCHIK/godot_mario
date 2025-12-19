extends Node

const CONFIG_PATH: String = "user://mario.cfg"
const DEFAULT_SHOW_FPS: bool = true
const DEFAULT_FONT: String = "Pixelify"

@onready var main_theme: Theme = preload("res://resources/main_theme.tres")
@onready var fonts: Dictionary = {
	"Pixelify": preload("res://resources/pixelify-font.ttf"),
	"Tomorrow": preload("res://resources/tomorrow-font.ttf"),
}

var current_show_fps: bool = DEFAULT_SHOW_FPS
var current_font: String = DEFAULT_FONT

signal show_fps(toggle_on)
signal update_menu_elements

func update_font(font_name: String):
	if font_name not in fonts:
		print("[ERROR] No such font '%s' in files" % [font_name])
		return
	main_theme.default_font = fonts[font_name]
	current_font = font_name

func save_settings():
	var config = ConfigFile.new()
	config.set_value("settings", "show_fps", current_show_fps)
	config.set_value("settings", "font", current_font)
	config.save(CONFIG_PATH)

func load_settings():
	var config = ConfigFile.new()
	var error = config.load(CONFIG_PATH)
	if error == OK:
		show_fps.emit(config.get_value("settings", "show_fps", DEFAULT_SHOW_FPS))
		update_font(config.get_value("settings", "font", DEFAULT_FONT))
		update_menu_elements.emit()
