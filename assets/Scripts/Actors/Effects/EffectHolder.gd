class_name EffectHolder

const LOGGING = true

#signal lost_effect(effect_id:String)
#signal gained_effect(effect:BaseEffect)

var _actor:BaseActor
var _effects:Dictionary = {}
var _triggers_to_effect_ids:Dictionary = {}

func _init(actor:BaseActor) -> void:
	_actor = actor
	_actor.on_death.connect(_on_actor_death)
	_actor.on_move.connect(_on_actor_moved)
	
	for t in BaseEffect.EffectTriggers.values():
		_triggers_to_effect_ids[t] = []
	
	# Connect signals
func on_combat_start():
	if CombatRootControl.Instance:
		CombatRootControl.Instance.QueController.start_of_turn_with_state.connect(_on_turn_start)
		CombatRootControl.Instance.QueController.end_of_turn_with_state.connect(_on_turn_end)
		CombatRootControl.Instance.QueController.start_of_round_with_state.connect(_on_round_start)
		CombatRootControl.Instance.QueController.end_of_round_with_state.connect(_on_round_end)
	else:
		printerr("EffectHolder.on_combat_start: No CombatRootControl found")
	
func add_effect(effect_key:String, effect_data:Dictionary)->BaseEffect:
	var effect = EffectLibrary.create_effect(effect_key, _actor, effect_data)
	if LOGGING: print("EffectHolder.add_effect: Added effect '%s' to actor '%s'." % [effect.Id, _actor.Id])
	_effects[effect.Id] = effect
	for trigger in effect.Triggers:
		_triggers_to_effect_ids[trigger].append(effect.Id)
	effect.on_created(CombatRootControl.Instance.GameState)
	return effect
		
func list_effects()->Array:
	return _effects.values()

func has_effect(effect_id:String)->bool:
	return _effects.keys().has(effect_id)

func get_effect(effect_id:String)->BaseEffect:
	if _effects.keys().has(effect_id):
		return _effects[effect_id]
	return null
		
func remove_effect(effect:BaseEffect):
	var deleting_effect_id = effect.Id
	if !_effects.has(deleting_effect_id):
		printerr("Unknown effect: " + deleting_effect_id)
		return
	_effects.erase(deleting_effect_id)
	if !effect._deleted:
		effect.on_delete()
	print("EffectHolder.remove_effect: Deleted Effect '%s' from actor '%s'." % [deleting_effect_id, _actor.Id])
	for trigger in BaseEffect.EffectTriggers:
		if _triggers_to_effect_ids.get(trigger, []).has(deleting_effect_id):
			_triggers_to_effect_ids[trigger].erase(deleting_effect_id)
	_actor.stats.dirty_stats()
	
func get_on_deal_damage_mods():
	var out_list = []
	for effect:BaseEffect in _effects.values():
		for mod:BaseDamageMod in effect.get_active_damage_mods():
			if mod.on_deal_damage:
				out_list.append(mod)
	return out_list
	
func get_on_take_damage_mods():
	var out_list = []
	for effect:BaseEffect in _effects.values():
		for mod:BaseDamageMod in effect.get_active_damage_mods():
			if mod.on_take_damage:
				out_list.append(mod)
	return out_list

func get_stat_mods():
	var out_list = []
	for effect:BaseEffect in _effects.values():
		for mod in effect.get_active_stat_mods():
			out_list.append(mod)
	return out_list
	
func _trigger_effects(trigger:BaseEffect.EffectTriggers, game_state:GameStateData):
	if LOGGING: print("Triggering Effect Trigger: " + BaseEffect.EffectTriggers.keys()[trigger])
	for id in _triggers_to_effect_ids[trigger]:
		var effect:BaseEffect = _effects.get(id, null)
		if not effect:
			printerr("Missing effect with id: '%s'." % [id])
			_effects.erase(id)
			_triggers_to_effect_ids.erase(id)
		else:
			if LOGGING: print("Trigger effect with id: '%s'." % [id])
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
	if LOGGING: print("EffectHolder: Actor Death")
	var game_state = CombatRootControl.Instance.GameState
	_trigger_effects(BaseEffect.EffectTriggers.OnDeath, game_state)
	# Delete all active effects
	for effect:BaseEffect in _effects.values():
		effect.on_delete()
