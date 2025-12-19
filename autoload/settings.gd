extends Node

const CONFIG_PATH: String = "user://mario.cfg"
const DEFAULT_SHOW_FPS: bool = true
const DEFAULT_FONT: String = "Pixelify"
const DEFAULT_BUS_VALUE: float = 0.3

@onready var main_theme: Theme = preload("res://resources/main_theme.tres")
@onready var fonts: Dictionary = {
	"Pixelify": preload("res://resources/pixelify-font.ttf"),
	"Tomorrow": preload("res://resources/tomorrow-font.ttf"),
}

var current_show_fps: bool = DEFAULT_SHOW_FPS
var current_font: String = DEFAULT_FONT
var current_music_bus: float = DEFAULT_BUS_VALUE
var current_sounds_bus: float = DEFAULT_BUS_VALUE

signal show_fps(toggle_on)
signal update_menu_elements
signal update_bus_sliders

func update_font(font_name: String):
	if font_name not in fonts:
		print("[ERROR] No such font '%s' in files" % [font_name])
		return
	main_theme.default_font = fonts[font_name]
	current_font = font_name

func update_audio_bus(bus_name: String, value: float):
	if bus_name not in ["Music", "Sounds"]:
		print("[ERROR] Bus %s doesn't exist" % [bus_name])
		return
	if value < 0 or value > 1:
		print("[ERROR] Value of bus must be in [0, 1]")
		return
	var bus_idx = AudioServer.get_bus_index(bus_name)
	if bus_idx == -1:
		return
	AudioServer.set_bus_volume_linear(bus_idx, value)
	if bus_name == "Music":
		current_music_bus = value
	else:
		current_sounds_bus = value

func save_settings():
	var config = ConfigFile.new()
	config.set_value("settings", "show_fps", current_show_fps)
	config.set_value("settings", "font", current_font)
	config.set_value("settings", "music_bus", current_music_bus)
	config.set_value("settings", "sounds_bus", current_sounds_bus)
	config.save(CONFIG_PATH)

func load_settings():
	var config = ConfigFile.new()
	var error = config.load(CONFIG_PATH)
	if error == OK:
		show_fps.emit(config.get_value("settings", "show_fps", DEFAULT_SHOW_FPS))
		update_font(config.get_value("settings", "font", DEFAULT_FONT))
		update_audio_bus("Music", config.get_value("settings", "music_bus", DEFAULT_BUS_VALUE))
		update_audio_bus("Sounds", config.get_value("settings", "sounds_bus", DEFAULT_BUS_VALUE))
		update_menu_elements.emit()
		update_bus_sliders.emit()
