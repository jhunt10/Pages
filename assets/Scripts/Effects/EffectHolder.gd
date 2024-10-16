class_name EffectHolder

#signal lost_effect(effect_id:String)
#signal gained_effect(effect:BaseEffect)

var _actor:BaseActor
var _effects:Dictionary = {}
var _triggers_to_effect_ids:Dictionary = {}

func _init(actor:BaseActor) -> void:
	_actor = actor
	actor.on_death.connect(_on_actor_death)
	
	for t in BaseEffect.EffectTriggers.values():
		_triggers_to_effect_ids[t] = []
	
	# Connect signals
	if CombatRootControl.Instance:
		CombatRootControl.Instance.QueController.start_of_turn_with_state.connect(_on_turn_start)
		CombatRootControl.Instance.QueController.end_of_turn_with_state.connect(_on_turn_end)
		CombatRootControl.Instance.QueController.start_of_round_with_state.connect(_on_round_start)
		CombatRootControl.Instance.QueController.end_of_round_with_state.connect(_on_round_end)
		actor.on_move.connect(_on_actor_moved)
	
func add_effect(effect_key:String, effect_data:Dictionary)->BaseEffect:
	var effect = MainRootNode.effect_libary.create_new_effect(effect_key, _actor, effect_data)
	
	_effects[effect.Id] = effect
	for trigger in effect.Triggers:
		_triggers_to_effect_ids[trigger].append(effect.Id)
	effect.on_created(CombatRootControl.Instance.GameState)
	return effect
		
func list_effects()->Array:
	return _effects.values()
	
func get_effect(effect_id:String)->BaseEffect:
	if _effects.keys().has(effect_id):
		return _effects[effect_id]
	return null
		
func remove_effect(effect:BaseEffect):
	var effect_id = effect.Id
	if !_effects.has(effect_id):
		printerr("Unknown effect: " + effect_id)
		return
	effect.on_delete()
	_effects.erase(effect_id)
	for trigger in BaseEffect.EffectTriggers:
		if _triggers_to_effect_ids.get(trigger, []).has(effect_id):
			_triggers_to_effect_ids[trigger].erase(effect_id)
	_actor.stats.dirty_stats()
	
func get_damage_mods():
	var out_list = []
	for effect:BaseEffect in _effects.values():
		for mod in effect.get_active_damage_mods():
			out_list.append(mod)
	return out_list
	
func get_stat_mods():
	var out_list = []
	for effect:BaseEffect in _effects.values():
		for mod in effect.get_active_stat_mods():
			out_list.append(mod)
	return out_list
	
func _trigger_effects(trigger:BaseEffect.EffectTriggers, game_state:GameStateData):
	#printerr("Triggering Effect Trigger: " + BaseEffect.EffectTriggers.keys()[trigger])
	for id in _triggers_to_effect_ids[trigger]:
		var effect:BaseEffect = _effects.get(id, null)
		if not effect:
			printerr("Missing effect with id: '%s'." % [id])
			_effects.erase(id)
			_triggers_to_effect_ids.erase(id)
		else:
			printerr("Trigger effect with id: '%s'." % [id])
			effect.trigger_effect(trigger, game_state)
	pass

func _on_turn_start(game_state:GameStateData):
	_trigger_effects(BaseEffect.EffectTriggers.OnTurnStart, game_state)

func _on_turn_end(game_state:GameStateData):
	_trigger_effects(BaseEffect.EffectTriggers.OnTurnEnd, game_state)

func _on_round_start(game_state:GameStateData):
	_trigger_effects(BaseEffect.EffectTriggers.OnRoundStart, game_state)

func _on_round_end(game_state:GameStateData):
	_trigger_effects(BaseEffect.EffectTriggers.OnRoundEnd, game_state)
		
func _on_actor_moved(old_pos:MapPos, new_pos:MapPos, move_type:String, moved_by:BaseActor):
	for id in _triggers_to_effect_ids[BaseEffect.EffectTriggers.OnMove]:
		_effects[id].trigger_on_move(old_pos, new_pos, move_type, moved_by)
	
func _on_actor_death():
	var game_state = CombatRootControl.Instance.GameState
	_trigger_effects(BaseEffect.EffectTriggers.OnDeath, game_state)
	# Delete all active effects
	for effect:BaseEffect in _effects.values():
		effect.on_delete()
