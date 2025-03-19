class_name BaseEffect
extends BaseLoadObject
# An "Effect" is any Buff, Debuff, or modifier on an actor. 

signal effect_ended

enum EffectTriggers { 
	OnCreate, OnDurationEnds,
	OnTurnStart, OnTurnEnd, 
	OnActionStart, OnActionEnd, 
	OnGapTurnStart, OnGapTurnEnd,
	OnRoundStart, OnRoundEnd,
	OnMove, OnDamageTaken, OnDamagDealt,
	OnAttacking, OnDefending, 
	OnDeath, OnKill,
	OnUseItem
}

## Triggers which require additional information. They have thier own methods and can not be called from trigger_effect()
const TRIGGERS_WITH_ADDITIONAL_DATA = [
	EffectTriggers.OnMove, 
	EffectTriggers.OnDamagDealt, 
	EffectTriggers.OnDamageTaken, 
	EffectTriggers.OnKill,
	EffectTriggers.OnAttacking,
	EffectTriggers.OnDefending
]

func get_tagable_id(): return Id
func get_tags(): return details.tags


var Id:String:
	get: return self._id
var EffectKey:String:
	get: return self._key

# Triggers added by the system an not config, like OnTurnEnds for TurnDuration
var system_triggers:Array = []

var _icon_sprite:String

var Triggers:Array:
	get: return _triggers_to_sub_effect_keys.keys()
var DamageDatas:Dictionary:
	get: return get_load_val("DamageDatas", {})
var StatModDatas:Dictionary:
	get: return get_load_val("StatMods", {})
var DamageModDatas:Dictionary:
	get: return get_load_val("DamageMods", {})
var SubEffectDatas:Dictionary:
	get: return get_load_val("SubEffects", {})
var RemainingDuration:int:
	get: return _duration_counter

var source_id:String:
	get: return get_load_val("SourceId")

var applied_potency:float:
	get:
		if applied_potency < 1:
			var pot = get_load_val("AppliedPotency", 1)
			applied_potency = pot
		return applied_potency

var _source
var _enabled:bool = true
var _deleted:bool = false
var _sub_effects_data:Dictionary={}
var _triggers_to_sub_effect_keys:Dictionary={}
var _duration_counter:int = -1

func _init(key:String, def_load_path:String, def:Dictionary, id:String='', data:Dictionary={}) -> void:
	super(key, def_load_path, def, id, data)
	_cache_triggers()

func get_source_actor()->BaseActor:
	var source_type = get_load_val('SourceType')
	if source_type == "Actor":
		return ActorLibrary.get_actor(source_id)
	else:
		printerr("BaseEffect.get_source_actor: TODO")
		return null

func get_effected_actor()->BaseActor:
	var actor_id = get_load_val("EffectedActorId", null)
	if actor_id == null:
		printerr("Effect '%' found with no EffectedActor")
		return null
	return ActorLibrary.get_actor(actor_id)

func show_in_hud()->bool:
	return get_load_val("ShowInHud", false)

func show_counter()->bool:
	return get_load_val("ShowCounter", false)

func is_instant()->bool:
	return get_load_val("IsInstant", false)

func get_small_icon():
	return SpriteCache.get_sprite(details.small_icon_path)
func get_large_icon():
	return SpriteCache.get_sprite(details.large_icon_path)

func get_tags_added_to_actor()->Array:
	return get_load_val("AddTagsToActor", [])

func get_active_stat_mods()->Array:
	var out_list = []
	for sub_effect_key in SubEffectDatas.keys():
		var sub_effect_data = SubEffectDatas[sub_effect_key]
		var sub_effect = _get_sub_effect_script(sub_effect_key)
		for mod in sub_effect.get_active_stat_mods(self, sub_effect_data):
			out_list.append(mod)
	return out_list

func get_active_damage_mods():
	var out_list = []
	for sub_effect_key in SubEffectDatas.keys():
		var sub_effect_data = SubEffectDatas[sub_effect_key]
		var sub_effect = _get_sub_effect_script(sub_effect_key)
		for mod in sub_effect.get_active_damage_mods(self, sub_effect_data):
			out_list.append(mod)
	return out_list

func get_limited_effect_type()->EffectHelper.LimitedEffectTypes:
	var limited_effect_str = get_load_val("LimitedEffectType", "None")
	var key_index = EffectHelper.LimitedEffectTypes.keys().find(limited_effect_str)
	if key_index >= 0:
		return key_index
	return EffectHelper.LimitedEffectTypes.None

func _get_sub_effect_script(sub_effect_key:String):
	var subeffects = SubEffectDatas
	if not subeffects.has(sub_effect_key):
		return null
	return EffectLibrary.get_sub_effect_script(SubEffectDatas[sub_effect_key]['SubEffectScript'])

func _cache_triggers():
	_triggers_to_sub_effect_keys.clear()
	if is_instant():
		_triggers_to_sub_effect_keys[EffectTriggers.OnCreate] = []
		for sub_effect_key in SubEffectDatas.keys():
			_triggers_to_sub_effect_keys[EffectTriggers.OnCreate].append(sub_effect_key)
	else:
		for sub_effect_key in SubEffectDatas.keys():
			var sub_effect_data = SubEffectDatas[sub_effect_key]
			var sub_effect = _get_sub_effect_script(sub_effect_key)
			var trigger_list = sub_effect.get_triggers(self, sub_effect_data)
			for trig:EffectTriggers in trigger_list:
				if not _triggers_to_sub_effect_keys.keys().has(trig):
					_triggers_to_sub_effect_keys[trig] = []
				if not _triggers_to_sub_effect_keys[trig].has(sub_effect_key):
					_triggers_to_sub_effect_keys[trig].append(sub_effect_key)

func on_created(game_state:GameStateData=null):
	trigger_effect(EffectTriggers.OnCreate, game_state)
	pass

func on_delete():
	if _deleted:
		return
	for sub_effect_key in SubEffectDatas.keys():
		var sub_effect_data = SubEffectDatas[sub_effect_key]
		var sub_effect = _get_sub_effect_script(sub_effect_key)
		sub_effect.on_delete(self, sub_effect_data)
	_deleted = true
	var actor = get_effected_actor()
	if actor and actor.effects.has_effect(self.Id):
		actor.effects.remove_effect(self)
	effect_ended.emit()

func merge_new_duplicate_effect_data(source, data:Dictionary):
	var dup_subs_datas = data.get('SubEffects', {})
	for sub_effect_key in dup_subs_datas.keys():
		var dupl_sub_effect_data = dup_subs_datas[sub_effect_key]
		var sub_effect_data = SubEffectDatas[sub_effect_key]
		var sup_sub_effect_data = SubEffectDatas[sub_effect_key]
		var sub_effect = _get_sub_effect_script(sub_effect_key)
		sub_effect.merge_new_duplicate_sub_effect_data(self, sub_effect_data, dupl_sub_effect_data)

func trigger_effect(trigger:EffectTriggers, game_state:GameStateData):
	if TRIGGERS_WITH_ADDITIONAL_DATA.has(trigger):
		printerr("BaseEffect.trigger_effect: Called with trigger '%s' which requirers it's own method." % [trigger])
		return
	# Trigger each sub effect mapped to trigger
	for sub_effect_key in _triggers_to_sub_effect_keys.get(trigger, []):
		var sub_effect_data = SubEffectDatas[sub_effect_key]
		var sub_effect = _get_sub_effect_script(sub_effect_key)
		sub_effect.on_effect_trigger(self, sub_effect_data, trigger, game_state)
	# Check if durration has ended and remove self if so
	#printerr("trigger_effect:Check Duration: %s" % _duration_counter)
	if _enabled and _duration_counter == 0 and trigger != EffectTriggers.OnDurationEnds:
		trigger_effect(EffectTriggers.OnDurationEnds, game_state)
		_enabled = false
		var actor = get_effected_actor()
		if actor:
			actor.effects.remove_effect(self)

func trigger_on_move(game_state:GameStateData, old_pos:MapPos, new_pos:MapPos, move_type:String, moved_by_actor:BaseActor):
	for sub_effect_key in _triggers_to_sub_effect_keys.get(EffectTriggers.OnMove, []):
		var sub_effect_data = SubEffectDatas[sub_effect_key]
		var sub_effect = _get_sub_effect_script(sub_effect_key)
		sub_effect.on_move(self, sub_effect_data, game_state, old_pos, new_pos, move_type, moved_by_actor)

func trigger_on_damage_taken(game_state:GameStateData, damage_event:DamageEvent):
	for sub_effect_key in _triggers_to_sub_effect_keys.get(EffectTriggers.OnDamageTaken, []):
		var sub_effect_data = SubEffectDatas[sub_effect_key]
		var sub_effect = _get_sub_effect_script(sub_effect_key)
		sub_effect.on_damage_taken(self, sub_effect_data, game_state, damage_event)

func trigger_on_damage_dealt(game_state:GameStateData, damage_event:DamageEvent):
	for sub_effect_key in _triggers_to_sub_effect_keys.get(EffectTriggers.OnDamagDealt, []):
		var sub_effect_data = SubEffectDatas[sub_effect_key]
		var sub_effect = _get_sub_effect_script(sub_effect_key)
		sub_effect.on_damage_dealt(self, sub_effect_data, game_state, damage_event)

func trigger_on_attack(game_state:GameStateData, attack_event:AttackEvent):
	if attack_event.attacker.Id == get_load_val("EffectedActorId", null):
		for sub_effect_key in _triggers_to_sub_effect_keys.get(EffectTriggers.OnAttacking, []):
			var sub_effect_data = SubEffectDatas[sub_effect_key]
			var sub_effect = _get_sub_effect_script(sub_effect_key)
			sub_effect.on_attacking(self, sub_effect_data, game_state, attack_event)
	if attack_event.defender.Id == get_load_val("EffectedActorId", null):
		for sub_effect_key in _triggers_to_sub_effect_keys.get(EffectTriggers.OnDefending, []):
			var sub_effect_data = SubEffectDatas[sub_effect_key]
			var sub_effect = _get_sub_effect_script(sub_effect_key)
			sub_effect.on_defending(self, sub_effect_data, game_state, attack_event)
