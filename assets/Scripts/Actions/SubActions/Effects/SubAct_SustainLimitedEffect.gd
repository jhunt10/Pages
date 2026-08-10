class_name SubAct_SustainLimitedEffect
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"LimitEftType": BaseSubAction.SubActionPropTypes.StringVal
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_parent_action:PageItemAction, _subaction_data:Dictionary)->Array:
	return ["Sustain"]

func do_thing(_parent_action:PageItemAction, subaction_data:Dictionary, _que_exe_data,
				_game_state:GameStateData, actor:BaseActor)->bool:
	var lmt_eft_type_str = subaction_data.get("LimitEftType", "")
	var limit_effect_type = EffectHelper.LimitedEffectTypes.keys().find(lmt_eft_type_str)
	if limit_effect_type <= 0:
		printerr("SubAct_SustainLimitedEffect: Invalid \"LimitEftType\" '%s'" % [lmt_eft_type_str])
		return BaseSubAction.Failed
	
	var que_controller = CombatRootControl.Instance.QueController
	var now = (que_controller.round_counter * 100000) + (que_controller.action_index * 100) + que_controller.sub_action_index

	var active_effect_ids = actor.effects.get_hosted_limited_effect_ids(limit_effect_type)
	for effect_id in active_effect_ids:
		var effect = EffectLibrary.get_effect(effect_id)
		if not effect:
			printerr("SubAct_SustainLimitedEffect: Failed to find effect '%s'" % [effect_id])
			continue
		effect.sustain(now)
	
	return BaseSubAction.Success
