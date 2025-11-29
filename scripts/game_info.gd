extends Node

const TIME_RANKS = 4

@onready var score_label: Label = $ScoreBox/Score
@onready var time_label: Label = $TimeBox/Time

var time_left: float

func _ready() -> void:
	time_left = Globals.TIME_ON_LEVEL

func _process(delta: float) -> void:
	time_left -= delta
	_update_time_label()
	if time_left <= 0:
		Globals.game_over.emit()

func _update_time_label():
	var new_label = str(int(time_left))
	time_label.text = "0".repeat(TIME_RANKS - len(new_label)) + new_label
