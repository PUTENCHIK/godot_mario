extends CharacterBody2D

const SPEED = 500
const GRAVITY = 5000
const JUMP_VELOCITY = 40000

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var direction: bool = true
var is_disappeared: bool = false

func _ready() -> void:
	update_animation()

func update_animation():
	if direction:
		animation.play("rotate_right")
	else:
		animation.play("rotate_left")

func handle_collisions():
	var collision_count = get_slide_collision_count()
	for c in collision_count:
		var slide_collision = get_slide_collision(c)
		var collider = slide_collision.get_collider()
		var normal = slide_collision.get_normal()
		if collider is not CharacterBody2D:
			if abs(normal.x) == 1:
				disappear()
		else:
			if "hit_by_fireball" in collider:
				collider.hit_by_fireball.emit(direction)
			disappear()

func update_flip():
	sprite.flip_h = not direction

func _physics_process(delta: float) -> void:
	if not is_disappeared:
		if not is_on_floor():
			velocity.y += GRAVITY * delta
		else:
			velocity.y -= JUMP_VELOCITY * delta
		
		velocity.x = Globals.get_dir_coef(direction) * SPEED
		
		handle_collisions()
		update_flip()
		move_and_slide()

func disappear():
	if not is_disappeared:
		is_disappeared = true
		animation.play("disappear")
		collision.disabled = true
		await animation.animation_finished
		queue_free()
