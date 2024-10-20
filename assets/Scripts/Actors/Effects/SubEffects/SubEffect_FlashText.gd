class_name SubEffect_FlashText
extends BaseSubEffect

enum DurationTypes {Turn, Round, Trigger}

func get_required_props()->Dictionary:
	return {
		"PreFix": BaseSubEffect.SubEffectPropTypes.StringVal,
		"OptionalTriggers": BaseSubEffect.SubEffectPropTypes.Triggers
	}

func on_effect_trigger(effect:BaseEffect, subeffect_data:Dictionary, trigger:BaseEffect.EffectTriggers, _game_state:GameStateData):
	var trig_text = BaseEffect.EffectTriggers.keys()[trigger]
	CombatRootControl.Instance.create_flash_text_on_actor(effect._actor, trig_text, Color.BLUE)
