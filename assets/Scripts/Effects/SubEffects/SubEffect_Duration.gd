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

var _stat_mod:BaseStatMod

func get_required_triggers(_effect:BaseEffect, _subeffect_data:Dictionary)->Array:
	return [BaseEffect.EffectTriggers.OnCreate]
