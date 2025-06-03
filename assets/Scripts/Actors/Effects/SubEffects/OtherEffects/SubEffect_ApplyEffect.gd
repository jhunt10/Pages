class_name SubEffect_ApplyEffect
extends BaseSubEffect

func get_required_props()->Dictionary:
	return {
		"UniqueEffectId": BaseSubEffect.SubEffectPropTypes.StringVal,
		"ApplyEffectKey": BaseSubEffect.SubEffectPropTypes.StringVal,
		"OptionalTriggers": BaseSubEffect.SubEffectPropTypes.Triggers
	}

func get_triggers(_effect:BaseEffect, _subeffect_data:Dictionary)->Array:
	return super(_effect, _subeffect_data)

func on_effect_trigger(effect:BaseEffect, _subeffect_data:Dictionary, trigger:BaseEffect.EffectTriggers, game_state:GameStateData):
	var effect_id = _subeffect_data.get("UniqueEffectId", "")
	var actor = effect.get_effected_actor()
	if actor.effects.has_effect(effect_id):
		return
	var effect_key = _subeffect_data['ApplyEffectKey']
	var new_effect = EffectHelper.create_effect(actor, effect, effect_key, {}, game_state, effect_id)

func on_delete(effect:BaseEffect, _subeffect_data:Dictionary):
	if _subeffect_data.get("DeleteOtherEffectOnDelete", false):
		var actor = effect.get_effected_actor()
		for other_effect:BaseEffect in actor.effects.list_effects():
			if other_effect.source_id == effect.Id:
				actor.effects.remove_effect(other_effect)
