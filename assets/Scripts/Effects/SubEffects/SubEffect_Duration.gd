class_name SubEffect_Duration
extends BaseSubEffect

enum DurationTypes {Turn, Round, Trigger}

func get_required_props()->Dictionary:
	return {
		"DurationType": BaseSubEffect.SubEffectPropTypes.EnumOptions,
		"DurationValue": BaseSubEffect.SubEffectPropTypes.IntVal
	}
func get_enum_option_values()->Dictionary: return {
	"DurationType": DurationTypes.keys()
}

func get_required_triggers(_effect:BaseEffect, _subeffect_data:Dictionary)->Array:
	return [BaseEffect.EffectTriggers.OnCreate]

func get_optional_triggers(effect:BaseEffect, subeffect_data:Dictionary)->Array:
	var list = super(effect, subeffect_data)
	var duration_type = DurationTypes.get(subeffect_data['DurationType'])
	if duration_type == DurationTypes.Turn:
		list.append(BaseEffect.EffectTriggers.OnTurnEnd)
	if duration_type == DurationTypes.Round:
		list.append(BaseEffect.EffectTriggers.OnRoundEnd)
	return list
	

func on_effect_trigger(effect:BaseEffect, subeffect_data:Dictionary, trigger:BaseEffect.EffectTriggers, _game_state:GameStateData):
	if trigger == BaseEffect.EffectTriggers.OnCreate:
		effect._duration_counter = subeffect_data.get('DurationValue', -1)
	var duration_type = DurationTypes.get(subeffect_data['DurationType'])
	if duration_type == DurationTypes.Turn and trigger == BaseEffect.EffectTriggers.OnTurnEnd:
		effect._duration_counter -= 1
	if duration_type == DurationTypes.Round and trigger == BaseEffect.EffectTriggers.OnRoundEnd:
		effect._duration_counter -= 1
