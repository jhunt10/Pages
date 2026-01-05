class_name BaseZone

const LOGGING = true

var ZoneKey:String
var Id:String = str(ResourceUID.create_id())
var node:ZoneNode

var is_aura:bool:
	get():
		return _aura_actor_id != ''
var _aura_actor_id:String = ''
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
	
	_aura_actor_id = _data.get("AuraActorId", "")
	
	_duration = _data.get("Duration")
	_duration_type = _data.get("DurationType")
	if _duration_type == "Turn":
		CombatRootControl.Instance.QueController.end_of_turn.connect(_on_duration_tick)
	elif _duration_type == "Round":
		CombatRootControl.Instance.QueController.end_of_round.connect(_on_duration_tick)

func get_source_actor()->BaseActor:
	return _source.get_source_actor()

func get_aura_actor()->BaseActor:
	if _aura_actor_id == "":
		return null
	var aura_actor = ActorLibrary.get_actor(_aura_actor_id)
	return aura_actor

func get_zone_scene_path()->String:
	return _data.get("ZoneScenePath", "res://Scenes/Combat/MapObjects/Zones/zone_node.tscn")

func get_zone_tile_set()->Texture2D:
	if not _data.has('TileSet'):
		return null
	var load_path = _data.get('LoadPath', '')
	var tile_set = _data.get('TileSet', '')
	var path = load_path.path_join(tile_set)
	return SpriteCache.get_sprite(path, true)

func get_zone_tile_sprite()->Texture2D:
	if not _data.has('TileSprite'):
		return null
	var load_path = _data.get('LoadPath', '')
	var tile_set = _data.get('TileSprite', '')
	var path = load_path.path_join(tile_set)
	return SpriteCache.get_sprite(path, false)

func get_pos()->MapPos:
	return _center_pos
	
func get_area()->Array:
	return _area_matrix.to_map_spots(get_pos())

func list_actors_in_zone(game_state:GameStateData)->Array:
	var out_list = []
	for spot in get_area():
		for actor in game_state.get_actors_at_pos(spot):
			if not out_list.has(actor):
				out_list.append(actor)
	return out_list
	

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

func on_actor_enter(actor:BaseActor, _game_state:GameStateData):
	print("Actor ", actor.ActorKey, " entered Zone ", ZoneKey)
	
func on_actor_exit(actor:BaseActor, _game_state:GameStateData):
	print("Actor ", actor.ActorKey, " exited Zone ", ZoneKey)
	pass
