class_name MapBackground
extends Control

@export var table_texture_rect:TextureRect
@export var map_paper_patch:NinePatchRect

func set_map(map_node:MapControllerNode):
	var tile_size = 32
	var papper_padding = 0.5 # Percent of TileWidth to add around map
	var map_rect = map_node.get_map_rect()
	
	# Paper Map sizing and positioning
	var real_map_pos = map_node.position + (Vector2(map_rect.position) * Vector2(tile_size, tile_size))
	var paper_pos =  real_map_pos - (Vector2.ONE * (tile_size*papper_padding)/2)
	map_paper_patch.size = Vector2i((Vector2(map_rect.size) + Vector2(papper_padding,papper_padding)) * tile_size)
	map_paper_patch.position = paper_pos
	
	# Wood Table positioning
	var map_center = Vector2i(
		map_paper_patch.position.x + (map_paper_patch.size.x / 2),
		map_paper_patch.position.y + (map_paper_patch.size.y / 2))
		
	table_texture_rect.position = Vector2(
		map_center.x - (table_texture_rect.size.x / 2),
		map_center.y - (table_texture_rect.size.y / 2)
	)
	
	
	pass
