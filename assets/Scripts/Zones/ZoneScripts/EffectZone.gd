class_name EffectZone
extends BaseZone

# Applies Effect to any Actor that enters, removes effect on exit

var _actor_ids_to_inzone_effect_ids:Dictionary = {}
var _inzone_effect_key:String


func _init(source:SourceTagChain, data:Dictionary, center:MapPos, area:AreaMatrix) -> void:
	super(source, data, center, area)
	var inzone_effect_data = _data.get("InZoneEffectData", {})
	_inzone_effect_key = inzone_effect_data.get("EffectKey")
	if not _inzone_effect_key:
		printerr("BaseZone: Created without InZone Effect")
		is_active = false

func _on_duration_end():
	for actor_id in _actor_ids_to_inzone_effect_ids.keys():
		var actor = ActorLibrary.get_actor(actor_id)
		on_actor_exit(actor, null)
	_actor_ids_to_inzone_effect_ids.clear()
	super()

func _apply_inzone_effect(actor:BaseActor, game_state:GameStateData):
	if _actor_ids_to_inzone_effect_ids.has(actor.Id):
		push_warning("Actor ", actor.Id, " already has effect")
		return
	var inzone_effect_data = _data.get("InZoneEffectData", {})
	var effect = EffectHelper.create_effect(actor, _source, _inzone_effect_key, inzone_effect_data, game_state)
	if effect:
		_actor_ids_to_inzone_effect_ids[actor.Id] = effect.Id
	else:
		printerr("BaseZone._apply_inzone_effect: Failed to create Effect")


func on_actor_enter(actor:BaseActor, game_state:GameStateData):
	print("Actor ", actor.ActorKey, " entered Zone ", ZoneKey)
	if _actor_ids_to_inzone_effect_ids.has(actor.Id):
		push_warning("Entering Actor ", actor.Id, " already has effect ", _inzone_effect_key, ".")
		return
	_apply_inzone_effect(actor, game_state)

func on_actor_exit(actor:BaseActor, _game_state:GameStateData):
	# Wasn't already registed in zone
	if !_actor_ids_to_inzone_effect_ids.has(actor.Id):
		push_warning("EffectZone: Exiting Actor ", actor.Id, " does not has effect ", _inzone_effect_key, ".")
		return
	var effect = actor.effects.get_effect(_actor_ids_to_inzone_effect_ids[actor.Id])
	if effect:
		actor.effects.remove_effect(effect)
	_actor_ids_to_inzone_effect_ids.erase(actor.Id)
