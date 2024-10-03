class_name ZoneNode
extends Node2D

@onready var area_tile_map:TileMapLayer = $AreaTileMap

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
	#var texture = load("res://assets/Sprites/UI/Targeting/TestAreaTiles.png")
	#area_tile_map.tile_set.add_source(texture, 0)
	if _zone.is_aura:
		var pos = _zone._get_pos()
		var arr = _zone.area_matrix.to_map_spots(MapPos.new(0,0,pos.z))
		area_tile_map.set_cells_terrain_connect(arr,0,0)
	else:
		area_tile_map.set_cells_terrain_connect(_zone.get_area(),0,0)
	
