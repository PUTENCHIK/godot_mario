extends Node

var random = RandomNumberGenerator.new()

func pause():
	get_tree().set_pause(true)

func resume():
	get_tree().set_pause(false)

func exit():
	get_tree().quit()
