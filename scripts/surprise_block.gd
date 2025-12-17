extends StaticBody2D

@export var red_mushroom_chance: float = 0.1
@export var green_mushroom_chance: float = 0.1
@export var sunflower_chance: float = 0.05
# Other chances that single coin will be spawned

@onready var coin_node: Node2D = $CoinNode
@onready var animation_state: AnimationPlayer = $AnimationState
@onready var animation_hit: AnimationPlayer = $AnimationHit
@onready var hit_area_collision: CollisionShape2D = $SurpriseBlockHitArea/HitCollision
@onready var red_mushroom_scene: PackedScene = preload("res://scenes/bonuses/red_mushroom.tscn")
@onready var green_mushroom_scene: PackedScene = preload("res://scenes/bonuses/green_mushroom.tscn")
@onready var sunflower_scene: PackedScene = preload("res://scenes/bonuses/sunflower.tscn")
@onready var jumping_coin_scene: PackedScene = preload("res://scenes/ui/jumping_coin.tscn")

var spawn_disabled: bool = false

func _ready() -> void:
	if 1 - red_mushroom_chance - green_mushroom_chance - sunflower_chance < 0:
		print("[WARN] Chances into Surprise Block are greater than 1")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.name == "Character" and not spawn_disabled and \
			not animation_hit.is_playing() and Globals.is_block_hit_available:
		Globals.toggle_block_hit_available()
		body.hit_by_block.emit()
		animation_hit.play("hit")
		_try_spawn_content()
		await animation_hit.animation_finished
		Globals.toggle_block_hit_available()
		_disable()

func _try_spawn_content():
	if not spawn_disabled:
		spawn_disabled = true
		var chance = randf()
		# Bonus
		if chance >= 1 - red_mushroom_chance:
			_spawn_bonus(red_mushroom_scene, get_parent())
		elif chance >= 1 - red_mushroom_chance - green_mushroom_chance:
			_spawn_bonus(green_mushroom_scene, get_parent())
		elif chance >= 1 - red_mushroom_chance - green_mushroom_chance - sunflower_chance:
			_spawn_bonus(sunflower_scene, get_parent())
		# Single coin
		else:
			_spawn_bonus(jumping_coin_scene, coin_node)

func _spawn_bonus(scene: PackedScene, container):
	var bonus = scene.instantiate()
	container.add_child(bonus)
	bonus.global_position = global_position

func _disable():
	animation_state.play("disabled")
	hit_area_collision.disabled = true
