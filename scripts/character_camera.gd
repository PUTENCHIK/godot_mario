extends Camera2D

@export var tilemap: TileMapLayer

func _ready() -> void:
	var map_rect = tilemap.get_used_rect()
	var tile_size = tilemap.tile_set.tile_size
	var map_size = map_rect.size * tile_size
	limit_right = map_size.x
	#limit_bottom = map_size.y
