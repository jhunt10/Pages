class_name SubAct_SpawnMissile_Disjointed
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"TargetParamKey": BaseSubAction.SubActionPropTypes.TargetParamKey,
		"SourcePoint_TargetKey": BaseSubAction.SubActionPropTypes.TargetKey,
		"DamageKey": BaseSubAction.SubActionPropTypes.DamageKey,
		"MissileKey": BaseSubAction.SubActionPropTypes.MissileKey
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return ["SpawnMissile"]

# Origon Point = Selected Tile
# Target Spot(s) = AOE Area - Selected Tile
func do_thing(parent_action:BaseAction, subaction_data:Dictionary, metadata:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	var target_params = _get_target_parameters(parent_action, actor, subaction_data)
	var target_key = subaction_data['TargetKey']
	var damage_key = subaction_data['DamageKey']
	var missile_key = subaction_data['MissileKey']
	var turn_data:TurnExecutionData = metadata.get_current_turn_data()
	if !target_params:
		printerr("SubAct_SpawnMissile.get_target_spt_of_missile: No TargetParams found for: %s " % [subaction_data.get("TargetParamKey")])
		return BaseSubAction.Failed
	if !turn_data.has_target(target_key):
		printerr("SubAct_SpawnMissile.get_target_spt_of_missile: No TargetData found for : ", target_key)
		return BaseSubAction.Failed
	if !parent_action.DamageDatas.has(damage_key):
		printerr("SubAct_SpawnMissile.get_target_spt_of_missile: No DamageData found for : ", damage_key)
		return BaseSubAction.Failed
	if !parent_action.MissileDatas.has(missile_key):
		printerr("SubAct_SpawnMissile.get_target_spt_of_missile: No MissileData found for : ", missile_key)
		return BaseSubAction.Failed
	
	var target_spot = get_target_spot_of_missile(target_key, metadata, game_state)
	if not target_spot:
		printerr("SubAct_SpawnMissile.get_target_spt_of_missile: No target found for : ", target_key)
		return BaseSubAction.Failed
	
	var damage_data = (parent_action.DamageDatas[damage_key] as Dictionary).duplicate(true)
	var missile_data = (parent_action.MissileDatas[missile_key] as Dictionary).duplicate(true)
	var actor_pos = game_state.get_actor_pos(actor)
	var tag_chain = SourceTagChain.new()\
			.append_source(SourceTagChain.SourceTypes.Actor, actor)\
			.append_source(SourceTagChain.SourceTypes.Action, parent_action)
	for spot in []:
		continue
	missile_data['DamageData'] = damage_data
	missile_data['AttackDetails'] = parent_action.get_load_val("AttackDetails", {})
	missile_data['EffectDatas'] = parent_action.get_load_val("EffectDatas", {})
	var missile = BaseMissile.new(actor, missile_data, tag_chain, target_params,
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
