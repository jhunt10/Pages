class_name SubEffect_AddNestedEffect
extends BaseSubEffect

func get_required_props()->Dictionary:
	return {
		"UniqueChildEffectId": BaseSubEffect.SubEffectPropTypes.StringVal,
		"ChildEffectKey": BaseSubEffect.SubEffectPropTypes.StringVal,
		"ChildEffectData": BaseSubEffect.SubEffectPropTypes.DictVal,
		"OptionalTriggers": BaseSubEffect.SubEffectPropTypes.Triggers,
		# (Default true) Delete any other effect that has this one as "SourceId" 
		"DeleteChildOnDelete": BaseSubEffect.SubEffectPropTypes.BoolVal
	}

func get_triggers(_effect:BaseEffect, _subeffect_data:Dictionary)->Array:
	return super(_effect, _subeffect_data)

func on_effect_trigger(effect:BaseEffect, _subeffect_data:Dictionary, trigger:BaseEffect.EffectTriggers, game_state:GameStateData):
	var effect_id = _subeffect_data.get("UniqueChildEffectId", "")
	var actor = effect.get_effected_actor()
	if actor.effects.has_effect(effect_id):
		return
	var effect_key = _subeffect_data.get("ChildEffectKey", "")
	var effect_data = _subeffect_data.get("ChildEffectData", {})
	var new_effect = EffectHelper.create_effect(actor, effect, effect_key, effect_data, game_state, effect_id)

func on_delete(effect:BaseEffect, subeffect_data:Dictionary):
	if subeffect_data.get("DeleteChildOnDelete", true):
		var actor = effect.get_effected_actor()
		var effect_id = subeffect_data.get("UniqueChildEffectId", "")
		if effect_id == "":
			printerr("%s.SubEffect_AddNestedEffect.on_delete: No Unique Effect Id found." % [effect.EffectKey])
			return
		var other_effect:BaseEffect = actor.effects.get_effect(effect_id)
		if other_effect.source_id == effect.Id:
			actor.effects.remove_effect(other_effect)
