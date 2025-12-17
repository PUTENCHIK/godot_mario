extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		if body.name == "Character":
			Globals.game_over.emit()
		else:
			print("[INFO] %s is deleted" % [body.name])
			body.queue_free()
