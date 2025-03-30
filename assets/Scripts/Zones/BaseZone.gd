class_name BaseZone

const LOGGING = true

var ZoneKey:String
var Id:String = str(ResourceUID.create_id())
var node:ZoneNode

var is_aura:bool
var apply_to_source:bool
var is_active:bool

var _source:SourceTagChain
var _data:Dictionary = {}
var _center_pos:MapPos
var _area_matrix:AreaMatrix

var _duration:int = 0
var _duration_type:String

func _init(source:SourceTagChain, data:Dictionary, center:MapPos, area:AreaMatrix) -> void:
	_source = source
	_data = data
	_center_pos = center
	_area_matrix = area
	is_active = true
	
	_duration = _data.get("Duration")
	_duration_type = _data.get("DurationType")
	if _duration_type == "Turn":
		CombatRootControl.Instance.QueController.end_of_turn.connect(_on_duration_tick)
	elif _duration_type == "Round":
		CombatRootControl.Instance.QueController.end_of_round.connect(_on_duration_tick)
	elif _duration_type == "Trigger":
		var t = true
	else:
		printerr("BaseZone: Created without DurationType.")
		is_active = false

func get_source_actor()->BaseActor:
	return _source.get_source_actor()

func get_zone_scene_path()->String:
	return _data.get("ZoneScenePath", "res://Scenes/Combat/MapObjects/Zones/zone_node.tscn")

func get_zone_texture()->Texture2D:
	var load_path = _data.get('LoadPath', '')
	var tile_set = _data.get('TileSprite', '')
	var path = load_path.path_join(tile_set)
	return SpriteCache.get_sprite(path, true)

func get_pos()->MapPos:
	return _center_pos
	
func get_area()->Array:
	return _area_matrix.to_map_spots(get_pos())

func _on_duration_tick():
	self._duration -= 1
	if _duration <= 0:
		_on_duration_end()

func _on_duration_end():
	#if is_active:
	CombatRootControl.Instance.remove_zone(self)

	if CombatRootControl.Instance.QueController.end_of_turn.is_connected(_on_duration_tick):
		CombatRootControl.Instance.QueController.end_of_turn.disconnect(_on_duration_tick)
	elif CombatRootControl.Instance.QueController.end_of_round.is_connected(_on_duration_tick):
		CombatRootControl.Instance.QueController.end_of_round.disconnect(_on_duration_tick)
	is_active = false

func on_actor_enter(actor:BaseActor, game_state:GameStateData):
	print("Actor ", actor.ActorKey, " entered Zone ", ZoneKey)
	
func on_actor_exit(actor:BaseActor, game_state:GameStateData):
	print("Actor ", actor.ActorKey, " exited Zone ", ZoneKey)
	pass
