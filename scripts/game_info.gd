extends Node

const TIME_RANKS = 4
const SCORE_RANKS = 6

@onready var score_label: Label = $ScoreBox/Score
@onready var time_label: Label = $TimeBox/Time
@onready var extra_lives_label: Label = $ExtraLivesBox/ExtraLives
@onready var coins_label: Label = $CoinsBox/HBoxContainer/Coins
@onready var bonuses_box: VBoxContainer = $BonusesBox
@onready var bonuses_textures = {
	"red_mushroom": preload("res://assets/bonuses/red_mushroom.png"),
	"sunflower": preload("res://assets/bonuses/sunflower_display.png"),
}

var time_left: float
var decrease_time: bool = true
var is_red_mushroom_shown: bool = false
var is_sunflower_shown: bool = false

func zero_timer():
	time_left = Globals.TIME_ON_LEVEL

func _ready() -> void:
	zero_timer()
	Globals.character_start_rebirth.connect(_on_character_died)
	Globals.character_end_rebirth.connect(_on_character_resurrected)
	Globals.level_finished.connect(_on_level_finished)
	Globals.red_mushroom_eaten.connect(_on_red_mushroom_eaten)
	Globals.sunflower_eaten.connect(_on_sunflower_eaten)
	Globals.character_not_big_anymore.connect(_on_character_not_big_anymore)
	Globals.clear_bonuses.connect(_on_clear_bonuses)

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

func _on_character_died(freeze_time: bool):
	if freeze_time:
		decrease_time = false

func _on_character_resurrected(zero_time: bool):
	decrease_time = true
	if zero_time:
		time_left = Globals.TIME_ON_LEVEL

func _on_level_finished():
	zero_timer()

func _add_display_bonus(bonus_name: String):
	if bonus_name not in bonuses_textures:
		print("[ERROR] No such bonus: %s" % [bonus_name])
		return
	var rect: TextureRect = TextureRect.new()
	rect.texture = bonuses_textures[bonus_name]
	bonuses_box.add_child(rect)

func _on_red_mushroom_eaten():
	if not is_red_mushroom_shown:
		is_red_mushroom_shown = true
		_add_display_bonus("red_mushroom")

func _on_sunflower_eaten():
	if not is_sunflower_shown:
		is_sunflower_shown = true
		_add_display_bonus("sunflower")

func _on_character_not_big_anymore():
	for child in bonuses_box.get_children():
		if child.texture == bonuses_textures["red_mushroom"]:
			is_red_mushroom_shown = false
			child.queue_free()

func _on_clear_bonuses():
	for child in bonuses_box.get_children():
		remove_child(child)
		child.queue_free()
	is_red_mushroom_shown = false
	is_sunflower_shown = false
