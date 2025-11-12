extends CharacterBody2D

const BASE_SPEED = 100.0
const SPEED_DELTA = 30.0
const GRAVITY = 400.0
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $SimpleEnemySprite

enum State {IDLE, WALK, FALL, DEAD}

var SPEED: float = BASE_SPEED - SPEED_DELTA + Globals.random.randf_range(0, SPEED_DELTA)
var current_state: State
# false - left, true - right
@export var direction: bool

func get_dir_coef():
	return 1 if direction else -1

func set_state(state: State):
	current_state = state

func _ready() -> void:
	set_state(State.WALK)
	print(SPEED)

func handle_idle():
	animation.play("idle")

func handle_walk():
	animation.play("walk")
	
	velocity.x = get_dir_coef() * SPEED

func update_flip():
	sprite.flip_h = not direction

func handle_collisions(delta: float):
	var collision_count = get_slide_collision_count()
	for c in collision_count:
		var collision = get_slide_collision(c)
		var collider = collision.get_collider()
		var normal = collision.get_normal()
		#if "Wall" in collider.name or "TileMapLayer" in collider.name:
		if abs(normal.x) == 1:
			velocity.x -= get_dir_coef() * 2 * SPEED
			direction = not direction

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			handle_idle()
		State.WALK:
			handle_walk()
	
	if not is_on_floor():
		velocity.y += GRAVITY
	
	handle_collisions(delta)
	update_flip()
	move_and_slide()
	
	if is_on_floor() and current_state == State.FALL:
		# to WALK
		pass
