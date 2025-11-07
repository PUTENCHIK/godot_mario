extends Node2D

@onready var character: CharacterBody2D = $Character

#var bricks_blocks: Array[StaticBody2D] = []

func _ready() -> void:
	#link_character_with_bricks_blocks()
	pass

#func link_character_with_bricks_blocks():
	#var static_node = $Static
	#if static_node:
		#for child in static_node.get_children():
			#if child.name.begins_with("BricksBlock") and child is StaticBody2D:
				#bricks_blocks.append(child)
	#
	#for brick in bricks_blocks:
		#pass
	#
	#character.hit_bricks_block.connect(_on_hit_bricks_block)
#
#func _on_hit_bricks_block():
	#pass
