extends StaticBody2D

@export var red_mushroom_chance: float = 0.3
@export var green_mushroom_chance: float = 0.3
# Other chances that sunflower will be spawned

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var hit_area_collision: CollisionShape2D = $HitArea/CollisionShape2D
@onready var red_mushroom_scene: PackedScene = preload("res://scenes/bonuses/red_mushroom.tscn")
@onready var green_mushroom_scene: PackedScene = preload("res://scenes/bonuses/green_mushroom.tscn")
@onready var sunflower_scene: PackedScene = preload("res://scenes/bonuses/sunflower.tscn")
@onready var hit_player: AudioStreamPlayer2D = $HitPlayer

var spawn_disabled: bool = false

func _ready() -> void:
	if 1 - red_mushroom_chance - green_mushroom_chance < 0:
		print("[WARN] Chances into Secret Block are greater than 1")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.name == "Character" and not spawn_disabled and \
			not animation.is_playing() and Globals.is_block_hit_available:
		if hit_area_collision.global_position.y > body.global_position.y:
			return
		hit_player.play()
		Globals.toggle_block_hit_available()
		collision.set_deferred("disabled", false)
		body.hit_by_block.emit()
		animation.play("hit")
		_try_spawn_content()
		await animation.animation_finished
		Globals.toggle_block_hit_available()
		hit_area_collision.disabled = true

func _try_spawn_content():
	if not spawn_disabled:
		spawn_disabled = true
		var chance = randf()
		# Bonus
		if chance >= 1 - red_mushroom_chance:
			_spawn_bonus(red_mushroom_scene, get_parent())
		elif chance >= 1 - red_mushroom_chance - green_mushroom_chance:
			_spawn_bonus(green_mushroom_scene, get_parent())
		else:
			_spawn_bonus(sunflower_scene, get_parent())

func _spawn_bonus(scene: PackedScene, container):
	var bonus = scene.instantiate()
	container.add_child(bonus)
	bonus.global_position = global_position
