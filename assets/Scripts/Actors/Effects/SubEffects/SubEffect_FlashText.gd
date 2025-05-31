class_name SubEffect_FlashText
extends BaseSubEffect

func get_required_props()->Dictionary:
	return {
		"PreFix": BaseSubEffect.SubEffectPropTypes.StringVal,
		"Triggers": BaseSubEffect.SubEffectPropTypes.Triggers
	}

func get_triggers(effect:BaseEffect, subeffect_data:Dictionary)->Array:
	var list = super(effect, subeffect_data)
	var optional_triggers_arr = subeffect_data['Triggers']
	for opt_trig in _array_to_trigger_list(optional_triggers_arr):
		list.append(opt_trig)
	return list

func on_effect_trigger(effect:BaseEffect, subeffect_data:Dictionary, trigger:BaseEffect.EffectTriggers, _game_state:GameStateData):
	var trig_text = BaseEffect.EffectTriggers.keys()[trigger]
	VfxHelper.create_flash_text(effect.get_effected_actor(), trig_text, VfxHelper.FlashTextType.Blocked_Dmg)
