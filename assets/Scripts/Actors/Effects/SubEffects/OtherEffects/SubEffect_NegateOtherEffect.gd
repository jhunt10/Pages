class_name SubEffect_NegateOtherEffect
extends BaseSubEffect

func get_required_props()->Dictionary:
	return {}

func get_triggers(_effect:BaseEffect, subeffect_data:Dictionary)->Array:
	return [BaseEffect.EffectTriggers.OnOtherEffectToBeAdded]

## Prevent another effect from being added
func other_effect_to_be_added(parent_effect:BaseEffect, subeffect_data:Dictionary,
					_game_state:GameStateData, other_effect:BaseEffect, meta_data:Dictionary):
	var actor = parent_effect.get_effected_actor()
	var remove_effect = false
	
	var other_effect_keys = subeffect_data.get("OtherEffectKeys", [])
	if other_effect_keys.has(other_effect.EffectKey):
		remove_effect = true
	
	var tag_filters = subeffect_data.get("OtherEffectTagFilters", [])
	for tag_filter in tag_filters:
		if SourceTagChain.filters_accept_tags(tag_filter, other_effect.get_tags()):
			remove_effect = true
	
	if remove_effect:
		meta_data['WasNegated'] = true
	
	if subeffect_data.get("EndOnTrigged", true):
		actor.effects.remove_effect(parent_effect)
