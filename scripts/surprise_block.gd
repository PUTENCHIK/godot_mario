extends StaticBody2D

@onready var red_mashroom_scene = preload("res://scenes/bonuses/red_mashroom.tscn")
@onready var animation_state: AnimationPlayer = $AnimationState
@onready var animation_hit: AnimationPlayer = $AnimationHit
@onready var hit_area_collision: CollisionShape2D = $SurpriseBlockHitArea/HitCollision

# Has bonus spawned already
var has_spawned: bool = false

func _ready() -> void:
	animation_state.play("blink");

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and "Character" in body.name and not has_spawned \
			and not animation_hit.is_playing():
		body.hit_by_block.emit()
		animation_hit.play("hit")
		_spawn_bonus()
		await animation_hit.animation_finished
		_disable()

func _spawn_bonus():
	if has_spawned:
		return
	has_spawned = true
	var bonus: Node2D = red_mashroom_scene.instantiate()
	add_child(bonus)
	bonus.global_position = global_position

func _disable():
	animation_state.play("disabled")
	hit_area_collision.disabled = true
