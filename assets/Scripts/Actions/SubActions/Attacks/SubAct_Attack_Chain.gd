class_name SubAct_Attack_Chain
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"TargetKey": BaseSubAction.SubActionPropTypes.TargetKey,
		"DamageKey": BaseSubAction.SubActionPropTypes.DamageKey,
		"DamageKeys": BaseSubAction.SubActionPropTypes.StringVal,
		"EffectKeys": BaseSubAction.SubActionPropTypes.StringVal,
		"FailOnNoTarget": BaseSubAction.SubActionPropTypes.BoolVal,
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_parent_action:PageItemAction, _subaction_data:Dictionary)->Array:
	return ["Attack", "Chain"]

func do_thing(parent_action:PageItemAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	
	var turn_data = que_exe_data.get_current_turn_data()
	var attack_details = parent_action.action_data.get("AttackDetails", {})
	attack_details['DisplayName'] = parent_action.get_display_name()
	# TODO: This is redundant in many ways (get_attack_vfx_data to VfxLib stuff and AttackVfxData already on details)
	attack_details['AttackVfxData'] = parent_action.get_attack_vfx_data()
	var tag_chain = SourceTagChain.new()\
			.append_source(SourceTagChain.SourceTypes.Actor, actor)\
			.append_source(SourceTagChain.SourceTypes.Action, parent_action)
	
	# Get Target info
	var target_key = subaction_data.get('TargetKey')
	if !target_key:
		printerr("SubAct_Attack_Chain: No 'TargetKey' on subaction in %s." % [parent_action.ItemKey])
		return BaseSubAction.Failed
	
	# Check if no target
	if not turn_data.has_target(target_key):
		if subaction_data.get("FailOnNoTarget", true):
			return BaseSubAction.Failed
		else:
			return BaseSubAction.Success
	
	# Get Target Params
	var target_params = _get_target_parameters_for_target_key(target_key, parent_action, actor, turn_data)
	if !target_params:
		return BaseSubAction.Failed
	
	var targets_selected = turn_data.get_targets(target_key)
	var targets = TargetingHelper.get_targeted_actors(
			target_params, 
			targets_selected, 
			actor, 
			game_state, 
			true
		)
	
	if targets.size() == 0:
		printerr("SubAct_Attack_Chain: No Targets found (should have failed earlier)." )
		return BaseSubAction.Failed
		
	
	# Get Effect Datas
	var effect_keys = subaction_data.get("EffectKeys", [])
	var effect_datas = {}
	for key in effect_keys:
		var eff_data = parent_action.get_effect_data(key)
		if eff_data.size() > 0:
			effect_datas[key] = eff_data
	
	# Get Damage info
	var damage_datas = {}
	var damage_keys =  subaction_data.get("DamageKeys", [])
	if subaction_data.has("DamageKey"):
		var damage_key = subaction_data.get("DamageKey")
		if not damage_keys.has(damage_key):
			damage_keys.append(damage_key)
	damage_datas = parent_action.get_damage_datas(actor, damage_keys)
	
	var override_origin_pos = null
	var last_target = actor
	var target_mappings = turn_data.data_cache.get("TargetChainMaping", {})
	for target:BaseActor in targets:
		
		if target_mappings.keys().has(target.Id):
			var from_actor_id = target_mappings.get(target.Id)
			if from_actor_id:
				override_origin_pos = game_state.get_actor_pos(from_actor_id)
		
		var attack_event = AttackHandler.handle_attack(
			actor, 
			[target],
			attack_details, 
			damage_datas, 
			effect_datas, 
			tag_chain, 
			game_state,
			target_params.has_area_of_effect(),
			override_origin_pos, 
			false)
		
		for sub_attack_event_key in attack_event.sub_events.keys():
			var sub_attack_event:AttackSubEvent = attack_event.sub_events.get(sub_attack_event_key)
			VfxHelper.create_vfx_for_sub_attack_event(attack_event, game_state, sub_attack_event, last_target)
			last_target = target
	
		print("\n---------------------------")
		print(attack_event.serialize_self())
		print("---------------------------\n")
	
	return BaseSubAction.Success
	

func _create_weapon_missile():
	
		#var weapon = actor.equipment.get_primary_weapon()
		## Create missile for ranged weapons
		#var missile_data = (weapon as BaseWeaponEquipment).get_misile_data()
		#if missile_data:
			#var target_spots = _find_target_effected_spots(target_key, que_exe_data, game_state, actor)
			#if not target_spots:
				#printerr("SubAct_SpawnMissile.get_target_spt_of_missile: No target found for : ", target_key)
				#return BaseSubAction.Failed
			#if damage_datas.size() > 0:
				#missile_data['DamageData'] = damage_datas.values()[0]
			#for target_spot in target_spots:
				#var missile = BaseMissile.new(actor, missile_data, tag_chain, target_params,
												#actor_pos, target_spot, parent_action.get_load_path())
				#CombatRootControl.Instance.create_new_missile_node(missile)
	pass
