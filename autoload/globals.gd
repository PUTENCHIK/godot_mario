extends Node

const DELAY_AFTER_DEATH = 2.0
const TIME_ON_LEVEL = 100
const START_EXTRA_LIVES = 100
const MAX_MULTI_KILL = 4
const MULTI_KILL_COEF = {
	0: 1,
	1: 1,
	2: 2,
	3: 4,
	4: 8
}

var score: int = 0
var extra_lives: int = START_EXTRA_LIVES
var coins: int = 0

var random = RandomNumberGenerator.new()
var is_game_over: bool = false
var is_level_reloading: bool = false
var multi_kill: int = 0

signal game_over
signal restart_level
signal character_start_rebirth
signal character_end_rebirth

func _ready() -> void:
	game_over.connect(_on_game_over)

func reset_multi_kill():
	multi_kill = 0

func increase_multi_kill():
	multi_kill = min(multi_kill+1, MAX_MULTI_KILL)

func add_score(value: int):
	value = value * MULTI_KILL_COEF[multi_kill]
	score += value
	return value

func pause():
	get_tree().set_pause(true)

func resume():
	if not is_game_over:
		get_tree().set_pause(false)

func exit():
	get_tree().quit()

func _on_game_over():
	if extra_lives > 0:
		if not is_level_reloading:
			is_level_reloading = true
			character_start_rebirth.emit()
			await get_tree().create_timer(DELAY_AFTER_DEATH).timeout
			restart_level.emit()
			extra_lives -= 1
			is_level_reloading = false
			character_end_rebirth.emit()
	else:
		pause()
		is_game_over = true
