extends StaticBody2D

@export var UP_TIME = 5.0
@export var DOWN_TIME = 3.0

@onready var hit_animation: AnimationPlayer = $AnimationHit
@onready var state_animation: AnimationPlayer = $AnimationState
@onready var audio_player: AudioStreamPlayer2D = $EatingPlayer

var is_up: bool = false
var state_timer: float = randf_range(0, DOWN_TIME)

func _ready() -> void:
	hit_animation.play("hit")

func handle_state():
	if state_timer > (UP_TIME if is_up else DOWN_TIME):
		state_animation.play("down" if is_up else "up")
		is_up = not is_up
		state_timer = 0.0

func _process(delta: float) -> void:
	if not state_animation.is_playing():
		handle_state()
		state_timer += delta
	
	if is_up and not audio_player.playing:
		audio_player.play()
	elif not is_up:
		audio_player.stop()

func _on_hit_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.name == "Character":
		body.take_hit_by_enemy()
