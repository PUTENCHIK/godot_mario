extends Node2D

@onready var jump_animation: AnimationPlayer = $JumpAnimation
@onready var rotate_animation: AnimationPlayer = $RotateAnimation

func _ready() -> void:
	jump_animation.play("jump")
	rotate_animation.play("default")
	Globals.add_coins(1)
	Globals.score += Globals.COIN_REWARD
	await jump_animation.animation_finished
	queue_free()
