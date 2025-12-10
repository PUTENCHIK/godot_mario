extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		if "Character" in body.name:
			Globals.game_over.emit()
		else:
			print("[INFO] " + body.name + " is deleted")
			body.queue_free()
