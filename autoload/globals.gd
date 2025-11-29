extends Node

const TIME_ON_LEVEL = 100

var random = RandomNumberGenerator.new()
var is_game_over: bool = false

signal game_over

func _ready() -> void:
	game_over.connect(_on_game_over)

func pause():
	get_tree().set_pause(true)

func resume():
	if not is_game_over:
		get_tree().set_pause(false)

func exit():
	get_tree().quit()

func _on_game_over():
	pause()
	is_game_over = true
