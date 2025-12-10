extends Node

const TIME_RANKS = 4
const SCORE_RANKS = 5

@onready var score_label: Label = $ScoreBox/Score
@onready var time_label: Label = $TimeBox/Time
@onready var extra_lives_label: Label = $ExtraLivesBox/ExtraLives

var time_left: float
var decrease_time: bool = true

func _ready() -> void:
	time_left = Globals.TIME_ON_LEVEL
	Globals.character_start_rebirth.connect(_on_character_died)
	Globals.character_end_rebirth.connect(_on_character_resurrected)

func _process(delta: float) -> void:
	if decrease_time:
		time_left -= delta
	_update_time_label()
	_update_score_label()
	_update_extra_lives_label()
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

func _on_character_died():
	decrease_time = false

func _on_character_resurrected():
	decrease_time = true
