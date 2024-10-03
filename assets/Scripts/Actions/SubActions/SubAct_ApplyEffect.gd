class_name SubAct_ApplyEffect
extends BaseSubAction

func do_thing(parent_action:BaseAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor):
	print("Apply Effect SubAction")
	
	var turn_data = que_exe_data.get_current_turn_data()
	var target_key = subaction_data['TargetKey']
	var target:BaseActor = _get_target_actor(target_key, turn_data, game_state, actor)
	
	if !target:
		return
		
	var effect_key = subaction_data['EffectKey']
	var effect_data = {}
	if subaction_data.has('EffectData'):
		effect_data = subaction_data['EffectData']
	target.effects.add_effect(effect_key, effect_data)
	
func _get_target_actor(target_key:String, turn_data:TurnExecutionData,
				game_state:GameStateData, actor:BaseActor)->BaseActor:
	if target_key == "Self":
		return actor
	if !turn_data.targets.has(target_key):
		print("No target with key '" + target_key + "' found.")
		return null
	var target = turn_data.targets[target_key]
	if target is Vector2i:
		return game_state.MapState.get_actor_at_pos(target)
	if target is String:
		return game_state.Actors[target]
	printerr("Unknown target type: " + str(target))
	return null
