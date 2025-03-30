class_name BaseZone

const LOGGING = true

var ZoneKey:String
var Id:String = str(ResourceUID.create_id())
var _actor_ids_to_inzone_effect_ids:Dictionary = {}
var _inzone_effect_key:String

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
	var inzone_effect_data = _data.get("InZoneEffectData", {})
	_inzone_effect_key = inzone_effect_data.get("EffectKey")
	if not _inzone_effect_key:
		printerr("BaseZone: Created without InZone Effect")
		is_active = false
	
	_duration = _data.get("Duration")
	_duration_type = _data.get("DurationType")
	if _duration_type == "Turn":
		CombatRootControl.Instance.QueController.end_of_turn.connect(_on_duration_tick)
	elif _duration_type == "Round":
		CombatRootControl.Instance.QueController.end_of_round.connect(_on_duration_tick)
	else:
		printerr("BaseZone: Created without DurationType.")
		is_active = false

func get_source_actor()->BaseActor:
	return _source.get_source_actor()
	

func get_pos()->MapPos:
	return _center_pos
	
func get_area()->Array:
	return _area_matrix.to_map_spots(get_pos())

func _on_duration_tick():
	self._duration -= 1
	if _duration <= 0:
		_on_duration_end()

func _on_duration_end():
	for actor_id in _actor_ids_to_inzone_effect_ids.keys():
		var actor = ActorLibrary.get_actor(actor_id)
		on_actor_exit(actor)
	_actor_ids_to_inzone_effect_ids.clear()
	#if is_active:
	CombatRootControl.Instance.remove_zone(self)
	
	if CombatRootControl.Instance.QueController.end_of_turn.is_connected(_on_duration_tick):
		CombatRootControl.Instance.QueController.end_of_turn.disconnect(_on_duration_tick)
	elif CombatRootControl.Instance.QueController.end_of_round.is_connected(_on_duration_tick):
		CombatRootControl.Instance.QueController.end_of_round.disconnect(_on_duration_tick)
	is_active = false
	self.is_queued_for_deletion()

func _apply_inzone_effect(actor:BaseActor):
	if _actor_ids_to_inzone_effect_ids.has(actor.Id):
		push_warning("Actor ", actor.Id, " already has effect")
		return
	var inzone_effect_data = _data.get("InZoneEffectData", {})
	#TODO: Sourcing
	var effect = actor.effects.add_effect(get_source_actor(), _inzone_effect_key, inzone_effect_data)
	if effect:
		_actor_ids_to_inzone_effect_ids[actor.Id] = effect.Id
	else:
		printerr("BaseZone._apply_inzone_effect: Failed to create Effect")
	
func on_actor_enter(actor:BaseActor):
	print("Actor ", actor.ActorKey, " entered Zone ", ZoneKey)
	if _actor_ids_to_inzone_effect_ids.has(actor.Id):
		push_warning("Entering Actor ", actor.Id, " already has effect ", _inzone_effect_key, ".")
		return
	_apply_inzone_effect(actor)
	
func on_actor_exit(actor:BaseActor):
	# Wasn't already registed in zone
	if !_actor_ids_to_inzone_effect_ids.has(actor.Id):
		push_warning("Exiting Actor ", actor.Id, " does not has effect ", _inzone_effect_key, ".")
		return
	var effect = actor.effects.get_effect(_actor_ids_to_inzone_effect_ids[actor.Id])
	if effect:
		actor.effects.remove_effect(effect)
	_actor_ids_to_inzone_effect_ids.erase(actor.Id)
