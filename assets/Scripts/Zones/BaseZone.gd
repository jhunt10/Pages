class_name BaseZone

var ZoneKey:String
var Id : String = str(ResourceUID.create_id())
var EffectKey:String
var EffectData:Dictionary = {}

var is_aura:bool
var apply_to_source:bool
var area_matrix:AreaMatrix
var _source_actor:BaseActor
var _center_pos:MapPos

var _actors_to_effects:Dictionary = {}

func _init(args:Dictionary, center) -> void:
	ZoneKey = args['ZoneKey']
	var area = args['ZoneArea']
	area_matrix = AreaMatrix.new(area)
	EffectKey = args['EffectKey']
	var effect_def = EffectLibrary.get_effect_def(EffectKey)
	if effect_def.has("TurnDuration") or effect_def.has("RoundDuration"):
		push_error("Zone ", ZoneKey, " found with effect ", EffectKey, " which uses Durrations. Zone effects should not have a Duration.")
	
	if args['ZoneType'] == 'Aura':
		is_aura = true
		apply_to_source = args["ApplyToSelf"]
		_source_actor = center
		_center_pos = CombatRootControl.Instance.GameState.MapState.get_actor_pos(_source_actor)
		_source_actor.on_move.connect(_on_source_actor_move)
	elif args['ZoneType'] == 'Static':
		is_aura = false
		_center_pos = center
	
func _get_pos()->MapPos:
	#if is_aura:
		#return CombatRootControl.Instance.GameState.MapState.get_actor_pos(_source_actor)
	#else:
	return _center_pos
	
func get_area()->Array:
	return area_matrix.to_map_spots(_get_pos())
	
func _on_area_moved(new_pos:MapPos):
	var actors_in_new = {}
	# Get actors in new area
	for p in area_matrix.to_map_spots(new_pos):
		for act:BaseActor in CombatRootControl.Instance.GameState.MapState.get_actors_at_pos(p):
			actors_in_new[act.Id] = act
	# Remove actors no longer in area
	for old_act_id in _actors_to_effects.keys():
		if !actors_in_new.keys().has(old_act_id):
			var old_actor = CombatRootControl.Instance.GameState.get_actor(old_act_id)
			on_actor_exit(old_actor)
	# Add new actors
	for new_act_id in actors_in_new.keys():
		if !_actors_to_effects.keys().has(new_act_id):
			on_actor_enter(actors_in_new[new_act_id])
	_center_pos = new_pos
	
	
func _on_source_actor_move(_old_pos:MapPos, new_pos:MapPos, move_data:Dictionary):
	_on_area_moved(new_pos)
	
func _apply_effect(actor:BaseActor):
	if _actors_to_effects.has(actor.Id):
		push_warning("Actor ", actor.Id, " already has effect ", EffectKey, ".")
		return
	if not apply_to_source and _source_actor.Id == actor.Id:
		return
	var effect = actor.effects.add_effect(self, EffectKey, EffectData)
	_actors_to_effects[actor.Id] = effect.Id
	
func on_create(map_state:MapStateData):
	for p in self.get_area():
		for actor in map_state.get_actors_at_pos(p):
			_apply_effect(actor)
	
	
func on_actor_enter(actor:BaseActor):
	# Ignore source actor
	if _source_actor and _source_actor.Id == actor.Id:
		return
	print("Actor ", actor.ActorKey, " entered Zone ", ZoneKey)
	if _actors_to_effects.has(actor.Id):
		push_warning("Entering Actor ", actor.Id, " already has effect ", EffectKey, ".")
		return
	_apply_effect(actor)
	
func on_actor_exit(actor:BaseActor):
	# Ignore source actor
	if _source_actor and _source_actor.Id == actor.Id:
		return
	# Wasn't already registed in zone
	if !_actors_to_effects.has(actor.Id):
		push_warning("Exiting Actor ", actor.Id, " does not has effect ", EffectKey, ".")
		return
	var effect = actor.effects.get_effect(_actors_to_effects[actor.Id])
	if effect:
		actor.effects.remove_effect(effect)
	_actors_to_effects.erase(actor.Id)
	
func on_actor_start_turn(_actor:BaseActor):
	pass
	
func on_actor_end_turn(_actor:BaseActor):
	pass
	
func on_actor_start_round(_actor:BaseActor):
	pass
	
func on_actor_end_round(_actor:BaseActor):
	pass
