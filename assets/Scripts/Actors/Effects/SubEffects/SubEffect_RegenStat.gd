class_name SubEffect_RegenStat
extends BaseSubEffect

enum RegenTypes {Turn, Round, Trigger}

func get_required_props()->Dictionary:
	return {
		"Triggers": BaseSubEffect.SubEffectPropTypes.Triggers,
		"StatName": BaseSubEffect.SubEffectPropTypes.StringVal,
		"Value": BaseSubEffect.SubEffectPropTypes.IntVal
	}

func get_triggers(effect:BaseEffect, subeffect_data:Dictionary)->Array:
	var list = super(effect, subeffect_data)
	var optional_triggers_arr = subeffect_data['Triggers']
	for opt_trig in _array_to_trigger_list(optional_triggers_arr):
		list.append(opt_trig)
	return list

func on_effect_trigger(effect:BaseEffect, subeffect_data:Dictionary, trigger:BaseEffect.EffectTriggers, _game_state:GameStateData):
	var actor:BaseActor = effect.get_effected_actor()
	var stat_name = subeffect_data['StatName']
	var val = subeffect_data['Value']
	actor.stats.add_to_bar_stat(stat_name, val)
