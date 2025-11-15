extends StaticBody2D

@onready var animation_blink: AnimationPlayer = $AnimationBlink
@onready var animation_hit: AnimationPlayer = $AnimationHit

var animation_playing: bool = false

func _ready() -> void:
	animation_blink.play("blink");

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.name == "Character" and not animation_playing:
		body.hit_by_block.emit()
		animation_playing = true
		animation_hit.play("hit")
		await animation_hit.animation_finished
		animation_playing = false
