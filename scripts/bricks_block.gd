extends StaticBody2D

@onready var animation: AnimationPlayer = $AnimationPlayer

var animation_playing: bool = false

func _ready() -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and "Character" in body.name and not animation_playing:
		body.hit_by_block.emit()
		animation_playing = true
		animation.play("hit")
		await animation.animation_finished
		animation_playing = false
