class_name SubAct_DEV_ApplyAnyEffect
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"TargetKey": BaseSubAction.SubActionPropTypes.TargetKey,
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return ["SpawnEffect"]

## Return a of OnQueOptionsData to select the parent action is qued. 
func get_on_que_options(parent_action:BaseAction, _subaction_data:Dictionary, _actor:BaseActor, _game_state:GameStateData)->Array:
	return [OnQueOptionsData.new("SelectedEffectKey", "Select Effect:", EffectLibary._effects_data.keys())]

func do_thing(parent_action:BaseAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor):
	
	var turn_data = que_exe_data.get_current_turn_data()
	var target_key = subaction_data['TargetKey']
	var targets:Array = find_targeted_actors(parent_action, target_key, que_exe_data, game_state, actor)
	
	var effect_key = turn_data.on_que_data['SelectedEffectKey']
	var effect_data = {}
	if subaction_data.has('EffectData'):
		effect_data = subaction_data['EffectData']
	for target:BaseActor in targets:
		target.effects.add_effect(effect_key, effect_data)