class_name SubAct_SpawnMissile
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"TargetKey": BaseSubAction.SubActionPropType.TargetKey,
		"DamageKey": BaseSubAction.SubActionPropType.DamageKey,
		"MissileKey": BaseSubAction.SubActionPropType.MissileKey
	}


func do_thing(parent_action:BaseAction, subaction_data:Dictionary, metadata:QueExecutionData,
				game_state:GameStateData, actor:BaseActor):
	var actor_pos:MapPos = game_state.MapState.get_actor_pos(actor)
	
	var target_key = subaction_data['TargetKey']
	var damage_key = subaction_data['DamageKey']
	var missile_key = subaction_data['MissileKey']
	var turndata = metadata.get_current_turn_data()
	if !turndata.targets.has(target_key):
		print("No TargetData found for : ", target_key)
		return
	if !parent_action.DamageDatas.has(damage_key):
		print("No DamageData found for : ", damage_key)
		return
	if !parent_action.MissileDatas.has(missile_key):
		print("No MissileData found for : ", missile_key)
		return
		
	var target = get_target_of_missile(target_key, metadata, game_state)
	if not target:
		print("No target found for : ", target_key)
		return
		
		
	var damage_data = (parent_action.DamageDatas[damage_key] as Dictionary).duplicate(true)
	var missile_data = (parent_action.MissileDatas[missile_key] as Dictionary).duplicate(true)
	missile_data['DamageData'] = damage_data
	var missile = BaseMissile.new(actor, parent_action, missile_data, target)
	CombatRootControl.Instance.create_new_missile_node(missile)

func get_target_of_missile(target_key:String, metadata:QueExecutionData, game_state:GameStateData):
	var turn_data = metadata.get_current_turn_data()
	if !turn_data.targets.has(target_key):
		print("No target with key '" + target_key + "' found.")
		return null
	var target = turn_data.targets[target_key]
	if target is Vector2i:
		return game_state.MapState.get_actor_at_pos(target)
	if target is String:
		return target
	printerr("Unknown target type: " + str(target))
	return null
