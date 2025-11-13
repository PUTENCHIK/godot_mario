extends CharacterBody2D

const BASE_SPEED = 100.0
const SPEED_DELTA = 20.0
const GRAVITY = 70.0
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $SimpleEnemySprite
@onready var collision: CollisionShape2D = $SimpleEnemyCollision

enum State {IDLE, WALK, FALL, DEAD}

var SPEED: float = BASE_SPEED - SPEED_DELTA + Globals.random.randf_range(0, 2*SPEED_DELTA)
var current_state: State
# false - left, true - right
@export var direction: bool
var is_dead: bool = false

signal dead

func get_dir_coef():
	return 1 if direction else -1

func set_state(state: State):
	current_state = state

func _ready() -> void:
	set_state(State.WALK)
	dead.connect(_on_dead)

func handle_idle():
	animation.play("idle")

func handle_walk():
	animation.play("walk")
	
	velocity.x = get_dir_coef() * SPEED

func handle_fall():
	animation.play("fall")

func update_flip():
	sprite.flip_h = not direction

func handle_collisions():
	var collision_count = get_slide_collision_count()
	for c in collision_count:
		var coll = get_slide_collision(c)
		var collider = coll.get_collider()
		var normal = coll.get_normal()
		if collider.name != "Character":
			if abs(normal.x) == 1:
				velocity.x -= get_dir_coef() * 2 * SPEED
				direction = not direction

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			handle_idle()
		State.WALK:
			handle_walk()
		State.FALL:
			handle_fall()
		State.FALL:
			pass
	
	if current_state != State.DEAD and not is_on_floor():
		if current_state != State.FALL:
			set_state(State.FALL)
		velocity.y += GRAVITY

	if current_state != State.DEAD:
		handle_collisions()
		update_flip()
		move_and_slide()
		
		if is_on_floor() and current_state == State.FALL:
			set_state(State.WALK)

func _on_dead():
	if current_state != State.DEAD:
		set_state(State.DEAD)
		SPEED = 0
		collision.disabled = true
		animation.play("dead")
		await animation.animation_finished
		self.queue_free()
