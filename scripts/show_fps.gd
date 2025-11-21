extends Label

func _process(delta: float) -> void:
	text = "FPS: %d" % (1 / delta)
