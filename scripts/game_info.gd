extends Node

const TIME_RANKS = 4
const SCORE_RANKS = 6

@onready var score_label: Label = $ScoreBox/Score
@onready var time_label: Label = $TimeBox/Time
@onready var extra_lives_label: Label = $ExtraLivesBox/ExtraLives
@onready var coins_label: Label = $CoinsBox/HBoxContainer/Coins

var time_left: float
var decrease_time: bool = true

func zero_timer():
	time_left = Globals.TIME_ON_LEVEL

func _ready() -> void:
	zero_timer()
	Globals.character_start_rebirth.connect(_on_character_died)
	Globals.character_end_rebirth.connect(_on_character_resurrected)
	Globals.level_finished.connect(_on_level_finished)

func _process(delta: float) -> void:
	if decrease_time:
		time_left -= delta
	_update_time_label()
	_update_score_label()
	_update_extra_lives_label()
	_update_coins()
	if time_left <= 0:
		Globals.game_over.emit()

func _update_time_label():
	var new_label = str(int(time_left))
	time_label.text = "0".repeat(TIME_RANKS - len(new_label)) + new_label

func _update_score_label():
	var score = str(Globals.score)
	score_label.text = "0".repeat(SCORE_RANKS - len(score)) + score

func _update_extra_lives_label():
	var text = str(Globals.extra_lives)
	extra_lives_label.text = text

func _update_coins():
	var text = str(Globals.coins)
	coins_label.text = text

func _on_character_died():
	decrease_time = false

func _on_character_resurrected():
	decrease_time = true
	time_left = Globals.TIME_ON_LEVEL

func _on_level_finished():
	zero_timer()
