extends CharacterBody2D

const SPEED = 250.0
const JUMP_VELOCITY = -450.0
const JUMP_EXTRA_VELOCITY = -25.0
const GRAVITY = 1500.0
const MAX_JUMP_TIME = 0.8

enum State {IDLE, RUN, JUMP, DEAD}

@onready var animation = $AnimationPlayer
@onready var sprite = $CharacterSprite
@onready var collision = $CharacterCollision

var current_state: State = State.IDLE
var jump_timer: float = 0.0
var jump_from_enemy: bool = false

signal hit_by_block
signal hit_by_enemy

func set_state(new_state: State):
	current_state = new_state
	if current_state == State.JUMP:
		jump_timer = 0.0

func _ready() -> void:
	set_state(State.IDLE)
	hit_by_block.connect(_on_hit_by_block)
	hit_by_enemy.connect(_on_hit_by_enemy)

func handle_idle():
	animation.play("idle")
	
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = direction * SPEED
		set_state(State.RUN)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED / 14)
	
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		set_state(State.JUMP)

func handle_run():
	animation.play("run")
	
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		set_state(State.IDLE)
		return
	
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		set_state(State.JUMP)

func handle_jump():
	animation.play("jump")
	var direction = Input.get_axis("left", "right")
	velocity.x = lerp(velocity.x, direction * SPEED, 0.2)
	
	# While still pressing 'jump', character jumps higher, but not when
	# character already is falling and unless he jumped from enemy
	if (Input.is_action_pressed("jump") and jump_timer < MAX_JUMP_TIME and
			velocity.y <= 0 and not jump_from_enemy):
		velocity.y += JUMP_EXTRA_VELOCITY * (1 - jump_timer / MAX_JUMP_TIME)
	# If 'jump' is released, then get extra jump velocity is impossible
	if Input.is_action_just_released("jump"):
		jump_timer += MAX_JUMP_TIME

func update_flip():
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		sprite.flip_h = velocity.x < 0

func handle_collisions():
	var collision_count = get_slide_collision_count()
	for c in collision_count:
		var coll = get_slide_collision(c)
		var collider = coll.get_collider()
		var normal = coll.get_normal()
		if "Enemy" in collider.name:
			if abs(normal.x) > 0.5:
				hit_by_enemy.emit()
				set_state(State.DEAD)
			elif normal.y < -0.5:
				collider.dead.emit()
				velocity.y = JUMP_VELOCITY
				jump_from_enemy = true

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			handle_idle()
		State.RUN:
			handle_run()
		State.JUMP:
			handle_jump()
		State.DEAD:
			pass
	
	if not current_state == State.DEAD:
		if not is_on_floor():
			velocity.y += GRAVITY * delta
		
		handle_collisions()
		update_flip()
		move_and_slide()
		
		jump_timer += delta
		
		if is_on_floor() and current_state == State.JUMP:
			jump_from_enemy = false
			set_state(State.RUN if abs(velocity.x) > 0 else State.IDLE)
		if not is_on_floor() and current_state in [State.IDLE, State.RUN]:
			set_state(State.JUMP)

func _on_hit_by_block():
	var threshold = GRAVITY / 8
	if velocity.y < threshold:
		velocity.y = threshold
		jump_timer += MAX_JUMP_TIME

func _on_hit_by_enemy():
	velocity *= 0
	collision.disabled = true
	animation.play("dead")
	await animation.animation_finished
	self.queue_free()
