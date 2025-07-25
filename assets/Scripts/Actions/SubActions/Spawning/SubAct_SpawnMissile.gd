class_name SubAct_SpawnMissile
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"TargetParamKey": BaseSubAction.SubActionPropTypes.TargetParamKey,
		"TargetKey": BaseSubAction.SubActionPropTypes.TargetKey,
		"DamageKey": BaseSubAction.SubActionPropTypes.DamageKey,
		"MissileKey": BaseSubAction.SubActionPropTypes.MissileKey
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return ["SpawnMissile"]


func do_thing(parent_action:PageItemAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	var target_key = subaction_data['TargetKey']
	var damage_key = subaction_data['DamageKey']
	var missile_key = subaction_data['MissileKey']
	var turn_data:TurnExecutionData = que_exe_data.get_current_turn_data()
	if !turn_data.has_target(target_key):
		printerr("SubAct_SpawnMissile.get_target_spt_of_missile: No TargetData found for : ", target_key)
		return BaseSubAction.Failed
	
	var damage_data = parent_action.get_damage_data_single(actor, damage_key)
	if !damage_data or damage_data.size() == 0:
		printerr("SubAct_SpawnMissile.get_target_spt_of_missile: No DamageData found for : ", damage_key)
		return BaseSubAction.Failed
	
	var missile_data = parent_action.get_missile_data(missile_key)
	if !missile_data or missile_data.size() == 0:
		printerr("SubAct_SpawnMissile.get_target_spt_of_missile: No MissileData found for : ", missile_key)
		return BaseSubAction.Failed
	
	var target_spot = get_target_spot_of_missile(target_key, que_exe_data, game_state)
	if not target_spot:
		printerr("SubAct_SpawnMissile.get_target_spt_of_missile: No target found for : ", target_key)
		return BaseSubAction.Failed
	
	var target_param_key = turn_data.get_param_key_for_target(target_key)
	var target_params = parent_action.get_targeting_params(target_param_key, actor)
	if !target_params:
		printerr("SubAct_SpawnMissile.get_target_spt_of_missile: No TargetParams found for: %s " % [subaction_data.get("TargetParamKey")])
		return BaseSubAction.Failed
	
	var actor_pos = game_state.get_actor_pos(actor)
	var tag_chain = SourceTagChain.new()\
			.append_source(SourceTagChain.SourceTypes.Actor, actor)\
			.append_source(SourceTagChain.SourceTypes.Action, parent_action)
	missile_data['DamageData'] = damage_data
	missile_data['AttackDetails'] = parent_action.get_load_val("AttackDetails", {})
	missile_data['EffectDatas'] = parent_action.get_load_val("EffectDatas", {})
	missile_data['TargetParams'] = target_params
	var missile_script_path = missile_data.get("MissileScriptPath", "res://assets/Scripts/Missiles/AttackMissile.gd")
	var missile_script =  load(missile_script_path)
	if not missile_script:
		printerr("SubAct_SpawnMissile: Failed to load scene: %s" % [missile_script_path])
		return BaseSubAction.Failed
	var missile = missile_script.new(actor, missile_data, tag_chain,
									actor_pos, target_spot, parent_action.get_load_path())
	CombatRootControl.Instance.create_new_missile_node(missile)
	return BaseSubAction.Success

func get_target_spot_of_missile(target_key:String, metadata:QueExecutionData, game_state:GameStateData)->MapPos:
	var turn_data = metadata.get_current_turn_data()
	
	if !turn_data.has_target(target_key):
		print("No target with key '" + target_key + "' found.")
		return null
		
	var targets = turn_data.get_targets(target_key)
	if not targets or targets.size() == 0:
		printerr("SubAct_SpawnMissile.get_target_spt_of_missile: No targets found with id '%s'." % [target_key])
		return null
	var target = targets[0]
	if target is MapPos:
		return target
	elif target is Vector2i:
		return MapPos.Vector2i(target)
	elif target is String:
		var actor = game_state.get_actor(target, true)
		if not actor:
			printerr("SubAct_SpawnMissile.get_target_spt_of_missile: No actor found with id '%s'." % [target])
			return null
		return game_state.get_actor_pos(actor)
	else:
		printerr("SubAct_SpawnMissile.get_target_spt_of_missile: Unknown target type: " + str(target))
		return null
