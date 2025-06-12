class_name SubAct_ApplyEffect
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"TargetKey": BaseSubAction.SubActionPropTypes.TargetKey,
		"EffectKey": BaseSubAction.SubActionPropTypes.EffectKey
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return ["Apply"]

func do_thing(parent_action:PageItemAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	
	var turn_data = que_exe_data.get_current_turn_data()
	var target_key = subaction_data['TargetKey']
	var targets:Array = _find_target_effected_actors(parent_action, subaction_data, target_key, que_exe_data, game_state, actor)
	
	var effect_key = ''
	var effect_data = {}
	if subaction_data.has("EffectDataKey"):
		var effect_datas = parent_action.get_load_val("EffectDatas", {})
		effect_data = effect_datas.get(subaction_data['EffectDataKey'], {})
		effect_key = effect_data.get("EffectKey", '')
	if effect_key == '':
		effect_key = subaction_data.get('EffectKey')
	#TODO: Resist chance
	if subaction_data.has('EffectData'):
		effect_data = subaction_data['EffectData']
	for target:BaseActor in targets:
		EffectHelper.create_effect(target, actor, effect_key, effect_data, game_state)
	return BaseSubAction.Success
