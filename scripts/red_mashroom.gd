extends CharacterBody2D

const SPEED = 250.0
const GRAVITY = 75.0

@onready var animation: AnimationPlayer = $AnimationPlayer

var animation_finished: bool = false
var direction: bool = true

func _ready() -> void:
	animation.play("appear")
	animation.animation_finished.connect(_on_appear_animation_finished)

func get_dir_coef():
	return 1 if direction else -1

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
	if animation_finished:
		if not is_on_floor():
			velocity.y += GRAVITY
		
		velocity.x = get_dir_coef() * SPEED
		handle_collisions()
		move_and_slide()

func _on_appear_animation_finished(empty):
	animation_finished = true
