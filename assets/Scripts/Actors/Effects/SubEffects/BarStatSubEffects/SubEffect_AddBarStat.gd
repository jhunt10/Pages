class_name SubEffect_AddBarStat
extends BaseSubEffect

func get_required_props()->Dictionary:
	return {
		"BarStatName": BaseSubEffect.SubEffectPropTypes.StringVal,
		"MaxValue": BaseSubEffect.SubEffectPropTypes.IntVal,
		"RegenPerRound": BaseSubEffect.SubEffectPropTypes.IntVal
	}

func get_triggers(_effect:BaseEffect, _subeffect_data:Dictionary)->Array:
	return [BaseEffect.EffectTriggers.OnCreate]

func get_active_stat_mods(effect:BaseEffect, subeffect_data:Dictionary)->Array:
	var bar_stat_name = subeffect_data['BarStatName']
	var max_value = subeffect_data['MaxValue']
	var regen_value = subeffect_data['RegenPerRound']
	var max_bar_mod = BaseStatMod.new(effect.Id, "BarMax:"+bar_stat_name, effect.details.display_name, BaseStatMod.ModTypes.Add, max_value)
	var regen_bar_mod = BaseStatMod.new(effect.Id, "BarRegen:"+bar_stat_name+":Round", effect.details.display_name, BaseStatMod.ModTypes.Add, regen_value)
	return [max_bar_mod, regen_bar_mod]

func on_effect_trigger(effect:BaseEffect, _subeffect_data:Dictionary, trigger:BaseEffect.EffectTriggers, _game_state:GameStateData):
	if trigger == BaseEffect.EffectTriggers.OnCreate:
		effect.get_effected_actor().stats.dirty_stats()

func on_delete(effect:BaseEffect, _subeffect_data:Dictionary):
	effect.get_effected_actor().stats.dirty_stats()
