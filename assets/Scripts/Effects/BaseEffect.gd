class_name BaseEffect
# An "Effect" is any Buff, Debuff, or modifier on an actor. 

enum EffectTriggers { 
	OnCreate, OnDurationEnds,
	OnTurnStart, OnTurnEnd, 
	OnRoundStart, OnRoundEnd,
	OnMove, OnDamageTaken, OnDamagDealt,
	OnDeath, OnKill
	}

## Triggers which require additional information have thier own methods and do not use trigger_effect()
const TRIGGERS_WITH_ADDITIONAL_DATA = [EffectTriggers.OnMove, EffectTriggers.OnDamagDealt, EffectTriggers.OnDamageTaken, EffectTriggers.OnKill ]

var Id : String = str(ResourceUID.create_id())
var LoadPath:String
var EffectData:Dictionary
var EffectKey:String 
var DisplayName:String
var SnippetDesc:String
var Description:String
var Tags:Array = []
# Triggers added by the system an not config, like OnTurnEnds for TurnDuration
var system_triggers:Array = []

var _actor:BaseActor
var _icon_sprite:String

var Triggers:Array:
	get: return _triggers_to_sub_effect_keys.keys()
var StatModDatas:Dictionary:
	get: return EffectData.get("StatMods", {})
var DamageModDatas:Dictionary:
	get: return EffectData.get("DamageMods", {})
var SubEffectDatas:Dictionary:
	get: return EffectData.get("SubEffects", {})
var RemainingDuration:int:
	get: return _duration_counter

var _enabled:bool = true
var _deleted:bool = false
var _sub_effects_data:Dictionary={}
var _triggers_to_sub_effect_keys:Dictionary={}
var _duration_counter:int = -1

func _init(actor:BaseActor, data:Dictionary) -> void:
	_actor = actor
	LoadPath = data['LoadPath']
	EffectKey = data['EffectKey']
	EffectData = data.duplicate()
	
	#TODO: Translations
	DisplayName = EffectData['DisplayName']
	SnippetDesc = EffectData['SnippetDesc']
	Description = EffectData['Description']
	Tags = EffectData['Tags']
	_icon_sprite = EffectData['SmallSprite']
	_cache_triggers()

func get_sprite():
	return load(LoadPath + "/" +_icon_sprite)

func get_active_stat_mods():
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

func _get_sub_effect_script(sub_effect_key:String)->BaseSubEffect:
	return EffectLibary.get_sub_effect_script(SubEffectDatas[sub_effect_key]['SubEffectScript'])

func _cache_triggers():
	_triggers_to_sub_effect_keys.clear()
	for sub_effect_key in SubEffectDatas.keys():
		var sub_effect_data = SubEffectDatas[sub_effect_key]
		var sub_effect = _get_sub_effect_script(sub_effect_key)
		var trigger_list = sub_effect.get_required_triggers(self, sub_effect_data)
		trigger_list.append_array(sub_effect.get_optional_triggers(self, sub_effect_data))
		for trig:EffectTriggers in trigger_list:
			if not _triggers_to_sub_effect_keys.keys().has(trig):
				_triggers_to_sub_effect_keys[trig] = []
			if not _triggers_to_sub_effect_keys[trig].has(sub_effect_key):
				_triggers_to_sub_effect_keys[trig].append(sub_effect_key)

func on_created(game_state:GameStateData):
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
	_actor.effects.remove_effect(self)

func trigger_effect(trigger:EffectTriggers, game_state:GameStateData):
	if TRIGGERS_WITH_ADDITIONAL_DATA.has(trigger):
		printerr("BaseEffect.trigger_effect: Called with trigger '%s' which requirers it's own method." % [trigger])
		return
	for sub_effect_key in _triggers_to_sub_effect_keys.get(trigger, []):
		var sub_effect_data = SubEffectDatas[sub_effect_key]
		var sub_effect = _get_sub_effect_script(sub_effect_key)
		sub_effect.on_effect_trigger(self, sub_effect_data, trigger, game_state)
	if _enabled and _duration_counter == 0 and trigger != EffectTriggers.OnDurationEnds:
		trigger_effect(EffectTriggers.OnDurationEnds, game_state)
		_enabled = false
		_actor.effects.remove_effect(self)

func trigger_on_move(game_state:GameStateData, old_pos:MapPos, new_pos:MapPos, move_type:String, moved_by_actor:BaseActor):
	for sub_effect_key in _triggers_to_sub_effect_keys.get(EffectTriggers.OnMove, []):
		var sub_effect_data = SubEffectDatas[sub_effect_key]
		var sub_effect = _get_sub_effect_script(sub_effect_key)
		sub_effect.on_move(self, sub_effect_data, game_state, old_pos, new_pos, move_type, moved_by_actor)
