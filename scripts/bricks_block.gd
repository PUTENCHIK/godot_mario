extends StaticBody2D

const MULTIPLE_COINS_AMOUNT = 5

@export var multiple_coin_chance: float = 0.1

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var coin_node: Node2D = $CoinNode
@onready var jumping_coin_scene: PackedScene = preload("res://scenes/ui/jumping_coin.tscn")

var spawn_disabled: bool = false
var coins_spawned: int = 0

func _ready() -> void:
	if 1 - multiple_coin_chance < 0:
		print("[WARN] Chances into Bricks Block are greater than 1")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and "Character" in body.name and \
			not animation.is_playing() and Globals.is_block_hit_available:
		Globals.toggle_block_hit_available()
		body.hit_by_block.emit()
		animation.play("hit")
		_try_spawn_coin()
		await animation.animation_finished
		Globals.toggle_block_hit_available()

func _try_spawn_coin():
	if not spawn_disabled:
		if coins_spawned > 0:
			if coins_spawned == MULTIPLE_COINS_AMOUNT:
				spawn_disabled = true
				return
			_spawn_coin()
		else:
			var chance = randf()
			# Multiple coins
			if chance >= 1 - multiple_coin_chance:
				_spawn_coin()
			# Just block without bonuses
			else:
				spawn_disabled = true

func _spawn_coin():
	var coin: Node2D = jumping_coin_scene.instantiate()
	coin_node.add_child(coin)
	coin.global_position = global_position
	coins_spawned += 1
