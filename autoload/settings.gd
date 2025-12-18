extends Node

@onready var main_theme: Theme = preload("res://resources/main_theme.tres")
@onready var fonts: Dictionary = {
	"Pixelify": preload("res://resources/pixelify-font.ttf"),
	"Tomorrow": preload("res://resources/tomorrow-font.ttf"),
}

signal show_fps(toggle_on)

func update_font(font_name: String):
	if font_name not in fonts:
		print("[ERROR] No such font '%s' in files" % [font_name])
		pass
	main_theme.default_font = fonts[font_name]
