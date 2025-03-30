class_name ZoneNode
extends Node2D

@onready var area_tile_map:TileMapLayer = $AreaTileMap
@onready var tile_sprite:Sprite2D = $Sprite2D

var _zone:BaseZone

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if _zone == null:
		printerr("Zone Node created with no zone.")
		self.queue_free()
	else:
		_build_zone_area()

func _build_zone_area():
	self.visible = true
	var pos = _zone.get_pos()
	var arr = _zone._area_matrix.to_map_spots(MapPos.new(0,0,pos.z))
	if arr.size() == 1 and arr[0] == Vector2i.ZERO:
		var texture = _zone.get_zone_texture()
		if texture:
			tile_sprite.texture = texture
		tile_sprite.show()
		area_tile_map.hide()
	else:
		var texture = _zone.get_zone_texture()
		if texture:
			area_tile_map.tile_set.get_source(1).texture = texture
		area_tile_map.set_cells_terrain_connect(arr,0,0)
		tile_sprite.hide()
		area_tile_map.show()
	
