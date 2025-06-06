class_name EffectHolder

const LOGGING = false

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
		self._trigger_effects(BaseEffect.EffectTriggers.OnCombatStart, CombatRootControl.Instance.GameState)
	else:
		printerr("EffectHolder.on_combat_start: No CombatRootControl found")

func on_combat_end(game_state):
	self._trigger_effects(BaseEffect.EffectTriggers.OnCombatEnd, game_state)

# Delete all temorary effects that only apply durring combat
func purge_combat_efffects():
	for effect_key in _effects.keys():
		var effect:BaseEffect = _effects.get(effect_key)
		if effect.RemainingDuration > 0 or effect.delete_after_combat():
			remove_effect(effect)

## Should only be called by EffectLibrary.create_effect
func __add_new_effect(effect:BaseEffect, suppress_signals:bool = false):
	if LOGGING: print("BaseActor.__add_new_effect: Added effect '%s' to actor '%s'." % [effect.Id, _actor.Id])
	
	#Should not happen. EffectHelper should check for this.
	if _effects.keys().has(effect.Id):
		printerr("BaseActor.__add_new_effect: Effect '%s' already exist on Actor '%s'." % [effect.Id, _actor.Id])
		
	_effects[effect.Id] = effect
	if not effect.is_instant():
		for trigger in effect.Triggers:
			_triggers_to_effect_ids[trigger].append(effect.Id)
	
	if not suppress_signals:
		_actor.effacts_changed.emit()

func trigger_new_effect_to_be_added(game_state:GameStateData, added_effect:BaseEffect, meta_data:Dictionary):
	for effect:BaseEffect in _effects.values():
		effect.trigger_other_effect_to_be_added(game_state, added_effect, meta_data)


func list_effects()->Array:
	return _effects.values()

func get_tags_added_to_actor()->Array:
	var out_list = []
	for effect:BaseEffect in _effects.values():
		out_list.append_array(effect.get_tags_added_to_actor())
	return out_list
		

func has_effect(effect_id:String)->bool:
	if not effect_id.ends_with(":"+_actor.Id):
		effect_id += ":"+_actor.Id
	return _effects.keys().has(effect_id)

func get_effect(effect_id:String)->BaseEffect:
	if not effect_id.ends_with(":"+_actor.Id):
		effect_id += ":"+_actor.Id
	if _effects.keys().has(effect_id):
		return _effects[effect_id]
	return null

func get_effects_with_key(effect_key:String)->Array:
	var out_arr = []
	for effect:BaseEffect in _effects.values():
		if effect.EffectKey == effect_key:
			out_arr.append(effect)
	return out_arr

var _removing_effect_id
var _remove_effect_queue = []
func remove_effect(effect:BaseEffect, supress_signal:bool=false):
	printerr("remove_effect(%s)" %[effect.Id])
	# Skip if already removing
	if _removing_effect_id == effect.Id:
		return
	# Add to que if removing another
	if _removing_effect_id != null:
		if not _remove_effect_queue.has(effect.Id):
			_remove_effect_queue.append(effect.Id)
		return
	_removing_effect_id = effect.Id
	if !_effects.has(_removing_effect_id):
		printerr("Unknown effect: " + _removing_effect_id)
	else:
		# Inform effect it's being deleted
		if !effect._deleted:
			effect.on_delete()
		# Clean from data
		_effects.erase(_removing_effect_id)
		print("EffectHolder.remove_effect: Deleted Effect '%s' from actor '%s'." % [_removing_effect_id, _actor.Id])
		for trigger in _triggers_to_effect_ids.keys():
			if _triggers_to_effect_ids[trigger].has(_removing_effect_id):
				_triggers_to_effect_ids[trigger].erase(_removing_effect_id)
		EffectLibrary.Instance.erase_object(_removing_effect_id)
	_removing_effect_id = null
	if _remove_effect_queue.size() > 0:
		while _remove_effect_queue.size() > 0:
			var qued_effect_id = _remove_effect_queue[0]
			_remove_effect_queue.erase(qued_effect_id)
			if _effects.has(qued_effect_id):
				var rm_effect = _effects[qued_effect_id]
				remove_effect(rm_effect, true)
	_actor.stats.dirty_stats()
	if not supress_signal:
		_actor.effacts_changed.emit()


# --------------------------------------------------
#		Limited Effect (Cureses, Blessings, ...)
#		Host = Source of Effect
#		Holding = Target of effeect
# --------------------------------------------------

# Dictionary of LimitedEffectTypes to Array of applied Effect data
# _hosted_limited_effects:
#	Key - LimitedEffectTypes:
#		Value - Dictionary:
#			EffectId
#			EffectedActorId
var _hosted_limited_effects:Dictionary

func host_limited_effect(effect:BaseEffect):
	var limit_type = effect.get_limited_effect_type()
	if limit_type == EffectHelper.LimitedEffectTypes.None:
		return
	if not _hosted_limited_effects.has(limit_type):
		_hosted_limited_effects[limit_type] = []
	_hosted_limited_effects[limit_type].append({
		"EffectId": effect.Id,
		"EffectedActorId": effect.get_effected_actor().Id
	})
	effect.effect_ended.connect(_on_hosted_effect_ends.bind(limit_type, effect.Id))


func _on_hosted_effect_ends(limit_type:EffectHelper.LimitedEffectTypes, effect_id:String):
	var limited_effects_list:Array = _hosted_limited_effects.get(limit_type, [])
	var index = 0
	while index < limited_effects_list.size():
		if limited_effects_list[index]["EffectId"] == effect_id:
			limited_effects_list.remove_at(index)
		else:
			index += 1
	var t = true

func get_count_limit_for_limited_effect(type:EffectHelper.LimitedEffectTypes)->int:
	var str_type = EffectHelper.LimitedEffectTypes.keys()[type]
	var stat_name = "LmtEftCount" + ":" + str_type
	return _actor.stats.get_stat(stat_name, 1)
func get_per_actor_limit_for_limited_effect(type:EffectHelper.LimitedEffectTypes)->int:
	return 99
	#var str_type = EffectHelper.LimitedEffectTypes.keys()[type]
	#var stat_name = str_type + ":PerActorLimit"
	#return _actor.stats.get_stat(stat_name, 1)
func get_on_self_limit_for_limited_effect(type:EffectHelper.LimitedEffectTypes)->int:
	return 99
	#var str_type = EffectHelper.LimitedEffectTypes.keys()[type]
	#var stat_name = str_type + ":OnSelfLimit"
	#return _actor.stats.get_stat(stat_name, 1)

# Get total number of limited effects of type HOSTED by this actor
func get_count_of_hosted_limited_effect(type:EffectHelper.LimitedEffectTypes)->int:
	if not _hosted_limited_effects.keys().has(type):
		return 0
	return _hosted_limited_effects[type].size()

func get_oldest_hosted_limited_effect_id(type:EffectHelper.LimitedEffectTypes):
	if not _hosted_limited_effects.keys().has(type):
		return null
	var effect_list = _hosted_limited_effects[type]
	if effect_list.size() == 0:
		return null
	var last_effect_data = effect_list[0]
	return last_effect_data['EffectId']

# Get total number of limited effects of type HELD by this actor
func get_count_of_holding_limited_effect(type:EffectHelper.LimitedEffectTypes)->int:
	var list = list_holding_limited_effect(type)
	return list.size()
	
# Get limited effects of type HELD by this actor
func list_holding_limited_effect(type:EffectHelper.LimitedEffectTypes)->Array:
	var out_list = []
	for effect:BaseEffect in _effects.values():
		if effect.get_limited_effect_type() == type:
			out_list.append(effect)
	return out_list

func get_effect_immunities():
	var out_list = []
	for effect:BaseEffect in _effects.values():
		out_list.append_array(effect.get_effect_immunities())
	return out_list

func get_damage_mods()->Dictionary:
	var out_dict = {}
	for effect:BaseEffect in _effects.values():
		var mods = effect.get_active_damage_mods()
		for mod_key:String in mods.keys():
			out_dict[mod_key] = mods[mod_key]
	return out_dict

func get_ammo_mods()->Dictionary:
	var out_dict = {}
	for effect:BaseEffect in _effects.values():
		var mods = effect.get_active_ammo_mods()
		for mod_key:String in mods.keys():
			out_dict[mod_key] = mods[mod_key]
	return out_dict

func get_attack_mods()->Dictionary:
	var out_dict = {}
	for effect:BaseEffect in _effects.values():
		var mods = effect.get_active_attack_mods()
		for mod_key:String in mods.keys():
			# Effects already cleaned up keys
			# And actor will add SourceActor info
			out_dict[mod_key] = mods[mod_key]
	return out_dict

func get_stat_mods()->Array:
	var out_list = []
	for effect:BaseEffect in _effects.values():
		for mod in effect.get_active_stat_mods():
			out_list.append(mod)
	return out_list

func get_aura_effect()->Array:
	var out_list = []
	for effect:BaseEffect in _effects.values():
		if effect.has_aura_zone():
			out_list.append(effect)
	return out_list

func trigger_damage_dealt(game_state:GameStateData, damage_event:DamageEvent):
	for effect:BaseEffect in _effects.values():
		effect.trigger_on_damage_dealt(game_state, damage_event)

func trigger_damage_taken(game_state:GameStateData, damage_event:DamageEvent):
	for effect:BaseEffect in _effects.values():
		effect.trigger_on_damage_taken(game_state, damage_event)

func trigger_attack(attack_event:AttackEvent, game_state:GameStateData):
	for effect:BaseEffect in _effects.values():
		effect.trigger_on_attack(attack_event, game_state)

func _trigger_effects(trigger:BaseEffect.EffectTriggers, game_state:GameStateData):
	if LOGGING: print("Triggering Effect Trigger '%s' for actor:%s." % [BaseEffect.EffectTriggers.keys()[trigger], _actor.Id])
	for id in _triggers_to_effect_ids[trigger]:
		var effect:BaseEffect = _effects.get(id, null)
		if not effect:
			printerr("Missing effect with id: '%s'." % [id])
			_effects.erase(id)
			_triggers_to_effect_ids.erase(id)
		else:
			if LOGGING: print("Trigger effect with id: '%s'." % [ id])
			effect.trigger_effect(trigger, game_state)
	pass

func _on_turn_start(game_state:GameStateData):
	_trigger_effects(BaseEffect.EffectTriggers.OnTurnStart, game_state)
	if _actor.Que.is_turn_gap(game_state.current_turn_index):
		_trigger_effects(BaseEffect.EffectTriggers.OnGapTurnStart, game_state)
	else:
		_trigger_effects(BaseEffect.EffectTriggers.OnActionStart, game_state)

func _on_turn_end(game_state:GameStateData):
	_trigger_effects(BaseEffect.EffectTriggers.OnTurnEnd, game_state)
	if _actor.Que.is_turn_gap(game_state.current_turn_index):
		_trigger_effects(BaseEffect.EffectTriggers.OnGapTurnEnd, game_state)
	else:
		_trigger_effects(BaseEffect.EffectTriggers.OnActionEnd, game_state)

func _on_round_start(game_state:GameStateData):
	_trigger_effects(BaseEffect.EffectTriggers.OnRoundStart, game_state)

func _on_round_end(game_state:GameStateData):
	_trigger_effects(BaseEffect.EffectTriggers.OnRoundEnd, game_state)
		
func trigger_before_actor_moved(old_pos:MapPos, new_pos:MapPos, move_data:Dictionary, game_stat:GameStateData):
	for id in _triggers_to_effect_ids[BaseEffect.EffectTriggers.PreMove]:
		_effects[id].trigger_pre_move(game_stat, old_pos, new_pos, move_data.get("MoveType"), move_data.get("MovedBy"))
	
func _on_actor_moved(old_pos:MapPos, new_pos:MapPos, move_data:Dictionary):
	for id in _triggers_to_effect_ids[BaseEffect.EffectTriggers.PostMove]:
		_effects[id].trigger_post_move(CombatRootControl.Instance.GameState, old_pos, new_pos, move_data.get("MoveType"), move_data.get("MovedBy"))

func trigger_on_collision(collision_event:CollisionEvent, game_state:GameStateData):
	for id in _triggers_to_effect_ids[BaseEffect.EffectTriggers.PostMove]:
		_effects[id].trigger_collision(game_state, collision_event)

	

func _on_actor_death():
	if LOGGING: print("EffectHolder: Actor Death")
	var game_state = CombatRootControl.Instance.GameState
	_trigger_effects(BaseEffect.EffectTriggers.OnDeath, game_state)
	# Delete all active effects
	for effect:BaseEffect in _effects.values():
		effect.on_delete()
