class_name SubAct_SpawnMissile
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"TargetKey": BaseSubAction.SubActionPropTypes.TargetKey,
		"DamageKey": BaseSubAction.SubActionPropTypes.DamageKey,
		"MissileKey": BaseSubAction.SubActionPropTypes.MissileKey
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return ["SpawnMissile"]


func do_thing(parent_action:BaseAction, subaction_data:Dictionary, metadata:QueExecutionData,
				game_state:GameStateData, actor:BaseActor):
	var target_key = subaction_data['TargetKey']
	var target_params = parent_action.TargetParams.get(target_key, null)
	if !target_params:
		printerr("SubAct_SpawnMissile.get_target_spt_of_missile: No TargetParams found for : ", target_key)
		return
	var damage_key = subaction_data['DamageKey']
	var missile_key = subaction_data['MissileKey']
	var turndata = metadata.get_current_turn_data()
	if !turndata.targets.has(target_key):
		printerr("SubAct_SpawnMissile.get_target_spt_of_missile: No TargetData found for : ", target_key)
		return
	if !parent_action.DamageDatas.has(damage_key):
		printerr("SubAct_SpawnMissile.get_target_spt_of_missile: No DamageData found for : ", damage_key)
		return
	if !parent_action.MissileDatas.has(missile_key):
		printerr("SubAct_SpawnMissile.get_target_spt_of_missile: No MissileData found for : ", missile_key)
		return
	
	var target_spot = get_target_spot_of_missile(target_key, metadata, game_state)
	if not target_spot:
		printerr("SubAct_SpawnMissile.get_target_spt_of_missile: No target found for : ", target_key)
		return
	
	var damage_data = (parent_action.DamageDatas[damage_key] as Dictionary).duplicate(true)
	var missile_data = (parent_action.MissileDatas[missile_key] as Dictionary).duplicate(true)
	var actor_pos = game_state.MapState.get_actor_pos(actor)
	var tag_chain = SourceTagChain.new()\
			.append_source(SourceTagChain.SourceTypes.Actor, actor)\
			.append_source(SourceTagChain.SourceTypes.Action, parent_action)
	missile_data['DamageData'] = damage_data
	var missile = BaseMissile.new(actor, missile_data, tag_chain, target_params,
									actor_pos, target_spot, parent_action.LoadPath)
	CombatRootControl.Instance.create_new_missile_node(missile)

func get_target_spot_of_missile(target_key:String, metadata:QueExecutionData, game_state:GameStateData)->MapPos:
	var turn_data = metadata.get_current_turn_data()
	
	if !turn_data.targets.has(target_key):
		print("No target with key '" + target_key + "' found.")
		return null
		
	var target = turn_data.targets[target_key]
	if target is Vector2i:
		return MapPos.Vector2i(target)
	if target is String:
		var actor = game_state.get_actor(target, true)
		if not actor:
			printerr("SubAct_SpawnMissile.get_target_spt_of_missile: No actor found with id '%s'." % [target])
			return null
		return game_state.MapState.get_actor_pos(actor)
	printerr("SubAct_SpawnMissile.get_target_spt_of_missile: Unknown target type: " + str(target))
	return null
