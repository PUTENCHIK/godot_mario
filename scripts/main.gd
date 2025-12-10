extends Node2D

@onready var menu: Node = $UI/Menu
@onready var character_scene = preload("res://scenes/living/character.tscn")
@onready var world = $World
@onready var show_fps = $"UI/Show FPS"

var current_level: Node2D = null
var levels: Dictionary = {
	"First": preload("res://scenes/levels/first_level.tscn"),
	"Second": preload("res://scenes/levels/second_level.tscn"),
}
var character: CharacterBody2D = null
var camera: Camera2D = null

func _ready() -> void:
	Globals.restart_level.connect(_on_restart_level)
	load_character()
	if len(levels.keys()) == 0:
		print("[ERROR] No levels")
		return
	load_level("Second")
	character_to_spawn()
	limit_character_camera()
	set_menu_size()
	
	Settings.show_fps.connect(_on_toggle_show_fps)
	Globals.level_finished.connect(_on_level_finished)

func load_character():
	if character:
		character.queue_free()
	character = character_scene.instantiate()
	camera = character.get_node("CharacterCamera")
	world.add_child(character)

func load_level(level_name: String):
	if current_level:
		current_level.queue_free()
	if level_name not in levels:
		print("[ERROR] Not such level: " + level_name)
		return
	current_level = levels[level_name].instantiate()
	world.add_child(current_level)

func character_to_spawn():
	var spawn = current_level.get_node("Spawn")
	if spawn == null:
		print("[ERROR] Level must have marker 'Spawn'")
		return
	character.global_position = spawn.global_position

func limit_character_camera():
	if camera == null:
		print("[ERROR] Camera can't be null")
		return
	if current_level == null:
		print("[ERROR] Current level can't be null")
		return
	var tilemap: TileMapLayer = current_level.get_node("TileMaps/Level")
	if tilemap == null:
		print("[ERROR] Current level must have TileMaps/Level")
		return
	var map_rect = tilemap.get_used_rect()
	var tile_size = tilemap.tile_set.tile_size
	var map_size = map_rect.size * tile_size
	camera.limit_right = map_size.x
	camera.limit_bottom = map_size.y

func set_menu_size():
	var window_size: Vector2i = DisplayServer.window_get_size()
	var container: CenterContainer = menu.get_node("Panel/CenterContainer")
	container.size.x = window_size.x
	container.size.y = window_size.y

func _on_toggle_show_fps(toggle_on: bool):
	show_fps.visible = toggle_on

func _on_restart_level():
	load_character()
	character_to_spawn()
	limit_character_camera()
	set_menu_size()

func _on_level_finished():
	load_character()
	load_level("Second")
	character_to_spawn()
	limit_character_camera()
	set_menu_size()
