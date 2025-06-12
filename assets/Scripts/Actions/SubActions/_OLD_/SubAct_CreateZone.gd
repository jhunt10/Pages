class_name SubAct_CreateZone
extends BaseSubAction

func do_thing(parent_action:PageItemAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	var zone_data_key = subaction_data.get("ZoneDataKey")
	var zone_data = parent_action.get_zone_data(zone_data_key)
	if not zone_data:
		printerr("SubAct_CreateZone: Failed to find Zone Data with key '%s'." % [zone_data_key])
		return BaseSubAction.Failed
	
	var turn_data:TurnExecutionData = que_exe_data.get_current_turn_data()
	var target_key = subaction_data.get('TargetKey')
	if !turn_data.has_target(target_key):
		printerr("SubAct_CreateZone: No TargetData found for : ", target_key)
		return BaseSubAction.Failed
	
	var target_spot = get_target_spot_of_zone(target_key, que_exe_data, game_state)
	if not target_spot:
		printerr("SubAct_CreateZone: No target found for : ", target_key)
		return BaseSubAction.Failed
	
	var area_effect:AreaMatrix = null
	if subaction_data.has("AreaTargetParamKey"):
		var area_params_key = subaction_data.get("AreaTargetParamKey")
		var target_area_params = parent_action.get_targeting_params(area_params_key, actor)
		area_effect = target_area_params.effect_area
		
	if !area_effect:
		printerr("SubAct_CreateZone: No Area of Effect Found")
		return BaseSubAction.Failed
	
	var inzone_effect_data_key = zone_data.get("InZoneEffectDataKey")
	if inzone_effect_data_key:
		var inzone_effect_data = parent_action.get_effect_data(inzone_effect_data_key)
		zone_data['InZoneEffectData'] = inzone_effect_data
	var source_chain = SourceTagChain.new()\
		.append_source(SourceTagChain.SourceTypes.Actor, actor)\
		.append_source(SourceTagChain.SourceTypes.Action, parent_action)
	
	var damage_data_key = subaction_data.get("DamageKey")
	if damage_data_key:
		zone_data['DamageDatas'] =  [parent_action.get_damage_data_for_subaction(actor, subaction_data)]
	
	zone_data['AttackDetails'] = parent_action.get_load_val("AttackDetails", {})
	zone_data['EffectDatas'] = parent_action.get_load_val("EffectDatas", {})
	zone_data['LoadPath'] = parent_action.get_load_path()
	var zone_script_path = zone_data.get("ZoneScript")
	if !zone_script_path:
		printerr("SubAct_CreateZone: No Zone Script provied.")
		return BaseSubAction.Failed
	var zone_script = load(zone_script_path)
	var zone = zone_script.new(source_chain, zone_data, target_spot, area_effect)
	if not zone.is_active:
		printerr("SubAct_CreateZone: Zone failed to 'new'.")
		return BaseSubAction.Failed
		
	CombatRootControl.Instance.add_zone(zone)
	return BaseSubAction.Success
	

func get_target_spot_of_zone(target_key:String, metadata:QueExecutionData, game_state:GameStateData)->MapPos:
	var turn_data = metadata.get_current_turn_data()
	
	if !turn_data.has_target(target_key):
		print("No target with key '" + target_key + "' found.")
		return null
		
	var targets = turn_data.get_targets(target_key)
	if not targets or targets.size() == 0:
		printerr("SubAct_CreateZone.get_target_spot_of_zone: No targets found with id '%s'." % [target_key])
		return null
	var target = targets[0]
	if target is MapPos:
		return target
	elif target is Vector2i:
		return MapPos.Vector2i(target)
	elif target is String:
		var actor = game_state.get_actor(target, true)
		if not actor:
			printerr("SubAct_CreateZone.get_target_spot_of_zone: No actor found with id '%s'." % [target])
			return null
		return game_state.get_actor_pos(actor)
	else:
		printerr("SubAct_CreateZone.get_target_spot_of_zone: Unknown target type: " + str(target))
		return null
