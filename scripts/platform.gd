extends RigidBody2D

enum Axes {HORIZONTAL, VERTICAL}

@export var AXIS: Axes = Axes.HORIZONTAL
@export var IMPULSE: float = 40
@export var MOVING_TIME: float = 3.0
@export var APPLING_IMPULSE_PERCENT: float = 0.2
@export var IS_BROKEN: bool = false

@export var direction: bool = false
var timer: float = 0.0

func get_direction_vector(direct: bool = true) -> Vector2:
	var vectors = {
		Axes.HORIZONTAL: {
			true: Vector2.RIGHT,
			false: Vector2.LEFT,
		},
		Axes.VERTICAL: {
			true: Vector2.UP,
			false: Vector2.DOWN,
		},
	}
	return vectors[AXIS][direction if direct else not direction]

func _ready() -> void:
	if IS_BROKEN:
		set_collision_mask_value(3, true)
		set_collision_mask_value(4, true)
		set_collision_mask_value(5, true)
		set_collision_mask_value(8, true)

func _physics_process(delta: float) -> void:
	if timer > MOVING_TIME:
		direction = not direction
		timer = 0.0
	
	if timer <= MOVING_TIME * APPLING_IMPULSE_PERCENT:
		apply_impulse(get_direction_vector() * IMPULSE / MOVING_TIME)
	if timer > MOVING_TIME * (1 - APPLING_IMPULSE_PERCENT):
		apply_impulse(get_direction_vector(false) * IMPULSE / MOVING_TIME)
	
	timer += delta
