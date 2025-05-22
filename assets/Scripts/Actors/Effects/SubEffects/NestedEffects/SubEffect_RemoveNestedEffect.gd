class_name SubEffect_RemoveNestedEffect
extends BaseSubEffect

func get_required_props()->Dictionary:
	return {
		"UniqueChildEffectId": BaseSubEffect.SubEffectPropTypes.StringVal,
		"OptionalTriggers": BaseSubEffect.SubEffectPropTypes.Triggers,
	}

func get_triggers(_effect:BaseEffect, _subeffect_data:Dictionary)->Array:
	return super(_effect, _subeffect_data)

func on_effect_trigger(effect:BaseEffect, _subeffect_data:Dictionary, trigger:BaseEffect.EffectTriggers, game_state:GameStateData):
	var effect_id = _subeffect_data.get("UniqueChildEffectId", "")
	var actor = effect.get_effected_actor()
		
	if effect_id == "":
		printerr("%s.SubEffect_AddNestedEffect.on_delete: No Unique Effect Id found." % [effect.EffectKey])
		return
		
	var other_effect:BaseEffect = actor.effects.get_effect(effect_id)
	if other_effect and other_effect.source_id == effect.Id:
		actor.effects.remove_effect(other_effect)
