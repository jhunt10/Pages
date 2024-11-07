class_name SubAct_ApplyEffect
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"TargetKey": BaseSubAction.SubActionPropTypes.TargetKey,
		"EffectKey": BaseSubAction.SubActionPropTypes.EffectKey
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return ["SpawnEffect"]

func do_thing(parent_action:BaseAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor):
	
	var turn_data = que_exe_data.get_current_turn_data()
	var target_key = subaction_data['TargetKey']
	var targets:Array = _find_target_effected_actors(parent_action, subaction_data, target_key, que_exe_data, game_state, actor)
	
	var effect_key = subaction_data['EffectKey']
	var effect_data = {}
	if subaction_data.has('EffectData'):
		effect_data = subaction_data['EffectData']
	for target:BaseActor in targets:
		target.effects.add_effect(effect_key, effect_data)
