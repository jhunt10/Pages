class_name SubAct_ApplyEffect
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"TargetKey": BaseSubAction.SubActionPropType.TargetKey,
		"EffectKey": BaseSubAction.SubActionPropType.EffectKey
	}
	
func do_thing(parent_action:BaseAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor):
	print("Apply Effect SubAction")
	
	var turn_data = que_exe_data.get_current_turn_data()
	var target_key = subaction_data['TargetKey']
	var target:BaseActor = find_target_actor(target_key, que_exe_data, game_state, actor)
	
	if !target:
		return
		
	var effect_key = subaction_data['EffectKey']
	var effect_data = {}
	if subaction_data.has('EffectData'):
		effect_data = subaction_data['EffectData']
	target.effects.add_effect(effect_key, effect_data)
	
