extends Parallax2D

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_left"):
		self.scroll_offset.x += 5
	elif Input.is_action_pressed("ui_right"):
		self.scroll_offset.x -= 5
		
