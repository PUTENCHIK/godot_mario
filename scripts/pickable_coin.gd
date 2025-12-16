extends CharacterBody2D

const GRAVITY = 4000.0
const SCORE_REWARD = Globals.COIN_REWARD

@onready var blink_animation: AnimationPlayer = $BlinkAnimation
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var reward_label_scene: PackedScene = preload("res://scenes/ui/reward_label.tscn")

var is_taken: bool = false

signal taken

func _ready() -> void:
	blink_animation.play("blink")
	taken.connect(_on_taken)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	move_and_slide()

func _on_taken():
	if not is_taken:
		is_taken = true
		Globals.add_coins(1)
		var reward_label: Node2D = reward_label_scene.instantiate()
		reward_label.score = SCORE_REWARD
		get_parent().add_child(reward_label)
		reward_label.global_position = global_position
		sprite.visible = false
		collision.disabled = true
		await reward_label.animation.animation_finished
		queue_free()
