class_name ZoneNode
extends Node2D

@onready var area_tile_map:TileMapLayer = $AreaTileMap
@onready var tile_sprite:Sprite2D = $Sprite2D
@onready var timer_label:Label = $Timer

@export var spot_partical_emiter:GPUParticles2D

var _zone:BaseZone
var _aura_actor_node:BaseActorNode

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if _zone == null:
		printerr("Zone Node created with no zone.")
		self.queue_free()
	else:
		_build_zone_area()

func _process(_delta: float) -> void:
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
		var zone_area = _zone._area_matrix.to_map_spots(pos)
		var valid_area = []
		for spot in zone_area:
			if CombatRootControl.Instance.GameState.is_spot_traversable(spot):
				valid_area.append(Vector2i(spot.x - pos.x, spot.y - pos.y))
		area_tile_map.clear()
		var tile_set = _zone.get_zone_tile_set()
		if tile_set:
			area_tile_map.tile_set.get_source(1).texture = tile_set
			area_tile_map.set_cells_terrain_connect(valid_area,0,0)
			tile_sprite.hide()
			area_tile_map.show()
		
		if spot_partical_emiter:
			var offset = area_tile_map.tile_set.tile_size / 2.0
			for index in range(valid_area.size()):
				var spot = valid_area[index]
				if index == 0:
					spot_partical_emiter.position = area_tile_map.map_to_local(spot) - offset
				else:
					var new_spot = spot_partical_emiter.duplicate()
					self.add_child(new_spot)
					new_spot.position = area_tile_map.map_to_local(spot) - offset
	
