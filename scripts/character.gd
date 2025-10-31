extends CharacterBody2D

const SPEED = 250.0
const JUMP_VELOCITY = -450.0
const GRAVITY = 800.0
enum State {IDLE, RUN, JUMP}

@onready var animation = get_node("AnimationPlayer")
@onready var sprite = get_node("CharacterSprite")

var current_state: State = State.IDLE

func set_state(new_state: State):
	current_state = new_state

func _ready() -> void:
	set_state(State.IDLE)

func handle_idle():
	animation.play("idle")
	
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = direction * SPEED
		set_state(State.RUN)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED / 20)
	
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

func update_flip():
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		sprite.flip_h = velocity.x < 0

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			handle_idle()
		State.RUN:
			handle_run()
		State.JUMP:
			handle_jump()
	
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	update_flip()
	move_and_slide()
	
	if is_on_floor() and current_state == State.JUMP:
		set_state(State.RUN if abs(velocity.x) > 0 else State.IDLE)
	if not is_on_floor() and current_state in [State.IDLE, State.RUN]:
		set_state(State.JUMP)
