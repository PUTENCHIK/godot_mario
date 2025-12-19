extends Node2D

var score: int = 0
@onready var label: Label = $Label
@onready var animation: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	score = Globals.add_score(score)
	label.text = "%d" % (score)
	animation.play("default")
	await animation.animation_finished
	queue_free()
