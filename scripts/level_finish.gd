extends Node2D

@export var is_final: bool = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.name == "Character":
		if is_final:
			Globals.level_finished.emit()
		else:
			Globals.level_finished.emit()
