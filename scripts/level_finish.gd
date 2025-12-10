extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body.name)
	if body is CharacterBody2D and "Character" in body.name:
		Globals.level_finished.emit()
