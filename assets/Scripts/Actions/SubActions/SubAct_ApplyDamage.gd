class_name SubAct_ApplyDamage
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"TargetKey": BaseSubAction.SubActionPropType.TargetKey,
		"DamageKey": BaseSubAction.SubActionPropType.DamageKey
	}

func do_thing(parent_action:BaseAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor):
	print("Apply Damage SubAction")
	
	var turn_data = que_exe_data.get_current_turn_data()
	var target_key = subaction_data['TargetKey']
	var target:BaseActor = _get_target_actor(target_key, turn_data, game_state, actor)
	var damage_data = parent_action.get_damage_data(subaction_data)
	if target:
		DamageHelper.handle_damage(actor, target, damage_data)
	

func _get_target_actor(target_key:String, turn_data:TurnExecutionData,
				game_state:GameStateData, actor:BaseActor)->BaseActor:
	if target_key == "Self":
		return actor
	if !turn_data.targets.has(target_key):
		print("No target with key '" + target_key + "' found.")
		return null
	var target = turn_data.targets[target_key]
	if target is Vector2i:
		var targs = game_state.MapState.get_actors_at_pos(target)
		if targs.size() > 0:
			return targs[0]
	if target is String:
		return game_state.Actors[target]
	printerr("Unknown target type: " + str(target))
	return null
	
