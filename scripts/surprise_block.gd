extends StaticBody2D

@export var red_mushroom_chance: float = 0.2
# other bonuses
# Other chances that single coin will be spawned

@onready var coin_node: Node2D = $CoinNode
@onready var animation_state: AnimationPlayer = $AnimationState
@onready var animation_hit: AnimationPlayer = $AnimationHit
@onready var hit_area_collision: CollisionShape2D = $SurpriseBlockHitArea/HitCollision
@onready var red_mashroom_scene: PackedScene = preload("res://scenes/bonuses/red_mashroom.tscn")
@onready var jumping_coin_scene: PackedScene = preload("res://scenes/ui/jumping_coin.tscn")

var spawn_disabled: bool = false

func _ready() -> void:
	if 1 - red_mushroom_chance < 0:
		print("[WARN] Chances into Surprise Block are greater than 1")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and "Character" in body.name and not spawn_disabled and \
			not animation_hit.is_playing():
		body.hit_by_block.emit()
		animation_hit.play("hit")
		_spawn_bonus()
		await animation_hit.animation_finished
		_disable()

func _spawn_bonus():
	if not spawn_disabled:
		spawn_disabled = true
		var chance = randf()
		# Bonus
		if chance >= 1 - red_mushroom_chance:
			spawn_disabled = true
			_spawn_red_mushroom()
		# Single coin
		else:
			_spawn_coin()

func _spawn_coin():
	var coin: Node2D = jumping_coin_scene.instantiate()
	coin_node.add_child(coin)
	coin.global_position = global_position

func _spawn_red_mushroom():
	var bonus = red_mashroom_scene.instantiate()
	get_parent().add_child(bonus)
	bonus.global_position = global_position

func _disable():
	animation_state.play("disabled")
	hit_area_collision.disabled = true
