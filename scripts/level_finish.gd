extends Node2D

@export var is_final: bool = false
@export var destination: String

func _ready() -> void:
	if len(destination) == 0 and not is_final:
		print("[ERROR] Destination of %s must be set" % [name])

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.name == "Character":
		if is_final:
			Globals.game_finished.emit()
		else:
			Globals.level_finished.emit(destination)
