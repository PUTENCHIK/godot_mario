extends CharacterBody2D

const BASE_SPEED = 100.0
const SPEED_DELTA = 20.0
const GRAVITY = 70.0
const SCORE_REWARD = 200
const CHANGE_DIRECTION_INTERVAL = 0.1

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $SimpleEnemySprite
@onready var collision: CollisionShape2D = $SimpleEnemyCollision

@onready var reward_label_scene: PackedScene = preload("res://scenes/ui/reward_label.tscn")

enum State {IDLE, WALK, DEAD}

var SPEED: float = BASE_SPEED - SPEED_DELTA + Globals.random.randf_range(0, 2*SPEED_DELTA)
var current_state: State
# false - left, true - right
@export var direction: bool
var change_direction_timer: float = CHANGE_DIRECTION_INTERVAL

signal hit_by_character
signal hit_by_fireball(fireball_direction: bool)

func get_dir_coef():
	return 1 if direction else -1

func set_state(state: State):
	current_state = state

func _ready() -> void:
	set_state(State.WALK)
	hit_by_character.connect(_on_hit_by_character)
	hit_by_fireball.connect(_on_hit_by_fireball)
	Globals.character_start_rebirth.connect(_on_character_died)
	Globals.character_end_rebirth.connect(_on_character_resurrected)

func handle_idle():
	animation.play("idle")

func handle_walk():
	animation.play("walk")
	
	velocity.x = get_dir_coef() * SPEED

func update_flip():
	sprite.flip_h = not direction

func change_direction():
	if change_direction_timer > CHANGE_DIRECTION_INTERVAL:
		velocity.x -= get_dir_coef() * 2 * SPEED
		direction = not direction
		change_direction_timer = 0.0

func handle_collisions():
	var collision_count = get_slide_collision_count()
	for c in collision_count:
		var coll = get_slide_collision(c)
		var collider = coll.get_collider()
		var normal = coll.get_normal()
		if collider:
			if collider.name == "Character":
				collider.handle_enemy_collision(self, normal)
			else:
				if abs(normal.x) == 1:
					change_direction()

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			handle_idle()
		State.WALK:
			handle_walk()
		State.DEAD:
			pass
	
	if current_state != State.DEAD and not is_on_floor():
		velocity.y += GRAVITY

	if current_state != State.DEAD:
		handle_collisions()
		update_flip()
		move_and_slide()
		
		change_direction_timer += delta

func _on_hit_by_character():
	_on_dead("crushed")

func _on_hit_by_fireball(fireball_direction: bool):
	_on_dead("blow_up_right" if fireball_direction else "blow_up_left")

func _on_dead(animation_name: String):
	if current_state != State.DEAD:
		set_state(State.DEAD)
		velocity.x = 0
		collision.disabled = true
		animation.play(animation_name)
		update_flip()
		Globals.increase_multi_kill()
		var reward_label: Node2D = reward_label_scene.instantiate()
		reward_label.score = SCORE_REWARD
		add_child(reward_label)
		reward_label.global_position = global_position
		await animation.animation_finished
		self.queue_free()

func _on_character_died(empty: bool):
	set_collision_mask_value(3, false)

func _on_character_resurrected(empty: bool):
	set_collision_mask_value(3, true)
