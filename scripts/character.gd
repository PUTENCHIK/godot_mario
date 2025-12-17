extends CharacterBody2D

const SPEED = 250.0
const JUMP_VELOCITY = -600.0
const JUMP_EXTRA_VELOCITY = -55.0
const GRAVITY = 3200.0
const MAX_JUMP_TIME = 1.0
const SHOOTING_INTERVAL = 0.4

enum State {IDLE, RUN, JUMP, DEAD}

@onready var animation = $AnimationPlayer
@onready var sprite = $CharacterSprite
@onready var collision = $CharacterCollision
@onready var fireball_scene: PackedScene = preload("res://scenes/other/fireball.tscn")

var current_state: State = State.IDLE
var jump_timer: float = 0.0
var jump_from_enemy: bool = false
var is_shooting_enable: bool = false
var shooting_timer: float = 0.0

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
	Globals.game_over.connect(_on_hit_by_enemy)
	Globals.sunflower_eaten.connect(_on_sunflower_eaten)

func _input(event: InputEvent) -> void:
	if is_shooting_enable and event.is_action_pressed("shoot") and \
			shooting_timer >= SHOOTING_INTERVAL and Globals.coins > 0:
		var fireball: CharacterBody2D = fireball_scene.instantiate()
		fireball.direction = not sprite.flip_h
		get_parent().add_child(fireball)
		fireball.global_position = global_position
		fireball.global_position.x += (-1 if sprite.flip_h else 1) * 32
		fireball.velocity.y -= 400
		
		shooting_timer = 0.0
		Globals.coins -= 1

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
		var slide_collision = get_slide_collision(c)
		var collider = slide_collision.get_collider()
		var normal = slide_collision.get_normal()
		if collider:
			if "Enemy" in collider.name:
				if abs(normal.x) > 0.5:
					Globals.game_over.emit()
				elif normal.y < -0.5:
					collider.hit_by_character.emit()
					velocity.y = JUMP_VELOCITY
					jump_from_enemy = true
			elif "RedMushroom" in collider.name:
				collider.eaten.emit()
			elif "GreenMushroom" in collider.name:
				collider.eaten.emit()
			elif "Sunflower" in collider.name:
				collider.eaten.emit()
			elif "PickableCoin" in collider.name:
				collider.taken.emit()

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
	
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	handle_collisions()
	update_flip()
	move_and_slide()
	
	jump_timer += delta
	shooting_timer += delta
	
	if is_on_floor() and current_state != State.JUMP:
		Globals.reset_multi_kill()
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
	set_state(State.DEAD)
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_collision_mask_value(4, false)
	velocity *= 0
	animation.play("dead")
	await animation.animation_finished
	process_mode = Node.PROCESS_MODE_INHERIT

func _on_sunflower_eaten():
	is_shooting_enable = true
	shooting_timer = SHOOTING_INTERVAL
