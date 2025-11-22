class_name ZoneNode
extends Node2D

@onready var area_tile_map:TileMapLayer = $AreaTileMap
@onready var tile_sprite:Sprite2D = $Sprite2D
@onready var timer_label:Label = $Timer

var _zone:BaseZone
var _aura_actor_node:BaseActorNode

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if _zone == null:
		printerr("Zone Node created with no zone.")
		self.queue_free()
	else:
		_build_zone_area()

func _process(delta: float) -> void:
	if _aura_actor_node:
		self.global_position = _aura_actor_node.actor_motion_node.global_position
	else:
		if timer_label:
			timer_label.text = str(_zone._duration)

func _build_zone_area():
	self.visible = true
	var aura_actor = _zone.get_aura_actor()
	if aura_actor != null:
		_aura_actor_node = CombatRootControl.get_actor_node(aura_actor.Id)
		if timer_label:
			timer_label.hide()
	
	var tile_sprite_texture = _zone.get_zone_tile_sprite()
	if tile_sprite_texture:
		tile_sprite.texture = tile_sprite_texture
		tile_sprite.show()
		area_tile_map.hide()
	else:
		var pos = _zone.get_pos()
		var arr = _zone._area_matrix.to_map_spots(MapPos.new(0,0,pos.z))
		area_tile_map.clear()
		var tile_set = _zone.get_zone_tile_set()
		if tile_set:
			area_tile_map.tile_set.get_source(1).texture = tile_set
			area_tile_map.set_cells_terrain_connect(arr,0,0)
			tile_sprite.hide()
			area_tile_map.show()
	
