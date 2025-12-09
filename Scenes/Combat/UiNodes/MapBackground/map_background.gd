class_name MapBackground
extends Control

@export var table_texture_rect:TextureRect
@export var map_paper_patch:NinePatchRect

func set_map(map_node:MapControllerNode):
	var tile_size = 32
	var papper_padding = 0.5 # Percent of TileWidth to add around map
	var map_rect = map_node.get_map_rect()
	map_paper_patch.size = Vector2i((Vector2(map_rect.size) + Vector2(papper_padding,papper_padding)) * tile_size)
	var real_map_pos = map_node.position + (Vector2(map_rect.position) * Vector2(tile_size, tile_size))
	var paper_pos =  real_map_pos - (Vector2.ONE * (tile_size*papper_padding)/2)
	map_paper_patch.position = paper_pos
	pass
