class_name SubEffect_RemoveOtherEffect
extends BaseSubEffect

func get_required_props()->Dictionary:
	return {}

func get_triggers(_effect:BaseEffect, subeffect_data:Dictionary)->Array:
	return [BaseEffect.EffectTriggers.OnCreate]

## Remove an existing Effect when this one is created
func on_effect_trigger(effect:BaseEffect, subeffect_data:Dictionary, trigger:BaseEffect.EffectTriggers, game_state:GameStateData):
	var actor = effect.get_effected_actor()
	var other_effect_keys = subeffect_data.get("RemoveEffectKeys", [])
	for other_effect_key in other_effect_keys:
		var other_effects = actor.effects.get_effects_with_key(other_effect_key)
		for other_effect in other_effects:
			actor.effects.remove_effect(other_effect)
