class_name SubEffect_ApplyStatMod
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
	var stat_mod_key = subeffect_data['StatModKey']
	var mod = effect.StatModDatas.get(stat_mod_key, null)
	return [BaseStatMod.new(effect.Id, effect.StatModDatas[stat_mod_key])]

func on_effect_trigger(effect:BaseEffect, _subeffect_data:Dictionary, trigger:BaseEffect.EffectTriggers, _game_state:GameStateData):
	if trigger == BaseEffect.EffectTriggers.OnCreate:
		effect._actor.stats.dirty_stats()

func on_delete(effect:BaseEffect, _subeffect_data:Dictionary):
	effect._actor.stats.dirty_stats()
