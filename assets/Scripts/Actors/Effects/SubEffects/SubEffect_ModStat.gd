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
	var stat_mod_keys = []
	if subeffect_data.has('StatModKey'):
		stat_mod_keys.append(subeffect_data['StatModKey'])
	if subeffect_data.has('StatModKeys'):
		stat_mod_keys.append_array(subeffect_data['StatModKeys'])
	if subeffect_data.get("AllStatMods", false):
		stat_mod_keys = effect.get_load_val("StatMods", {}).keys()
	var stat_mods_datas = effect.get_load_val("StatMods", {})
	var out_list = []
	for mod_key in stat_mod_keys:
		if stat_mods_datas.has(mod_key):
			var mod_data = stat_mods_datas[mod_key]
			if not mod_data.has("DisplayName"):
				mod_data['DisplayName'] = effect.details.display_name
			out_list.append(BaseStatMod.create_from_data(effect.Id, mod_data))
	return out_list

func on_effect_trigger(effect:BaseEffect, _subeffect_data:Dictionary, trigger:BaseEffect.EffectTriggers, _game_state:GameStateData):
	if trigger == BaseEffect.EffectTriggers.OnCreate:
		effect.get_effected_actor().stats.dirty_stats()

func on_delete(effect:BaseEffect, _subeffect_data:Dictionary):
	var actor = effect.get_effected_actor()
	if actor:
		actor.stats.dirty_stats()
