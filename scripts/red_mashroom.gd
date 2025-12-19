extends CharacterBody2D

const SPEED = 250.0
const GRAVITY = 75.0
const SCORE_REWARD = 1000

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var collision: CollisionShape2D = $RedMashroomCollision
@onready var sprite: Sprite2D = $RedMashroomSprite
@onready var reward_label_scene: PackedScene = preload("res://scenes/ui/reward_label.tscn")
@onready var spawn_player: AudioStreamPlayer2D = $SpawnPlayer
@onready var eat_player: AudioStreamPlayer2D = $EatPlayer

var animation_finished: bool = false
var direction: bool = true
var is_eaten: bool = false

signal eaten

func _ready() -> void:
	animation.play("appear")
	spawn_player.play()
	animation.animation_finished.connect(_on_appear_animation_finished)
	eaten.connect(_on_eaten)

func handle_collisions():
	var collision_count = get_slide_collision_count()
	for c in collision_count:
		var coll = get_slide_collision(c)
		var collider = coll.get_collider()
		var normal = coll.get_normal()
		if collider.name == "Character":
			eaten.emit()
		else:
			if abs(normal.x) == 1:
				velocity.x -= Globals.get_dir_coef(direction) * 2 * SPEED
				direction = not direction

func _physics_process(delta: float) -> void:
	if animation_finished and not is_eaten:
		if not is_on_floor():
			velocity.y += GRAVITY
		
		velocity.x = Globals.get_dir_coef(direction) * SPEED
		handle_collisions()
		move_and_slide()

func _on_appear_animation_finished(empty):
	animation_finished = true

func _on_eaten():
	if not is_eaten:
		is_eaten = true
		Globals.red_mushroom_eaten.emit()
		eat_player.play()
		var reward_label: Node2D = reward_label_scene.instantiate()
		reward_label.score = SCORE_REWARD
		get_parent().add_child(reward_label)
		reward_label.global_position = global_position
		reward_label.global_position.y -= 64
		sprite.visible = false
		collision.disabled = true
		await reward_label.animation.animation_finished
		queue_free()
