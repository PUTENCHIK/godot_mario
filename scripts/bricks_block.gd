extends StaticBody2D

@export var multiple_coins_amount = 5
@export var multiple_coin_chance: float = 0.1

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var collision: CollisionShape2D = $BricksBlockCollision
@onready var hit_area: Area2D = $BricksBlockHitArea
@onready var coin_node: Node2D = $CoinNode
@onready var jumping_coin_scene: PackedScene = preload("res://scenes/ui/jumping_coin.tscn")

var spawn_disabled: bool = false
var coins_spawned: int = 0

func _ready() -> void:
	if 1 - multiple_coin_chance < 0:
		print("[WARN] Chances into Bricks Block are greater than 1")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.name == "Character" and \
			not animation.is_playing() and Globals.is_block_hit_available:
		_handle_character_hit(body)

func _handle_character_hit(character: CharacterBody2D):
	character.hit_by_block.emit()
	_try_spawn_coin()
	if not spawn_disabled or not character.is_big:
		Globals.toggle_block_hit_available()
		animation.play("hit")
		await animation.animation_finished
		Globals.toggle_block_hit_available()
	elif character.is_big:
		_destroy()

func _try_spawn_coin():
	if not spawn_disabled:
		if coins_spawned > 0:
			if coins_spawned == multiple_coins_amount:
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

func _destroy():
	Globals.toggle_block_hit_available()
	collision.disabled = true
	hit_area.monitoring = false
	animation.play("destroy")
	await animation.animation_finished
	Globals.toggle_block_hit_available()
	queue_free()
