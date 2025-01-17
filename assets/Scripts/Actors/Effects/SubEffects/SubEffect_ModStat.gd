class_name SubEffect_ModStat
extends BaseSubEffect

func get_required_props()->Dictionary:
	return {"StatModKey": BaseSubEffect.SubEffectPropTypes.StatModKey}

var _stat_mod:BaseStatMod

func get_triggers(_effect:BaseEffect, _subeffect_data:Dictionary)->Array:
	var list = super(_effect, _subeffect_data)
	if !list.has(BaseEffect.EffectTriggers.OnCreate):
		list.append(BaseEffect.EffectTriggers.OnCreate)
	return list

func get_active_stat_mods(effect:BaseEffect, subeffect_data:Dictionary)->Array:
	if subeffect_data.get("AllStatMods", false):
		var out_list = []
		for mod_data in effect.get_load_val("StatMods", {}).values():
			out_list.append(BaseStatMod.create_from_data(effect.Id, mod_data))
		return out_list
	else:
		var stat_mod_key = subeffect_data['StatModKey']
		var mod_data = effect.StatModDatas.get(stat_mod_key)
		if mod_data:
			return [BaseStatMod.create_from_data(effect.Id, mod_data)]
	return []

func on_effect_trigger(effect:BaseEffect, _subeffect_data:Dictionary, trigger:BaseEffect.EffectTriggers, _game_state:GameStateData):
	if trigger == BaseEffect.EffectTriggers.OnCreate:
		effect.get_effected_actor().stats.dirty_stats()

func on_delete(effect:BaseEffect, _subeffect_data:Dictionary):
	var actor = effect.get_effected_actor()
	if actor:
		actor.stats.dirty_stats()
