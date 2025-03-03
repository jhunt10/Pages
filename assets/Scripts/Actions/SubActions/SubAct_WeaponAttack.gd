class_name SubAct_WeaponAttack
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"TargetKey": BaseSubAction.SubActionPropTypes.TargetKey,
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return ["Attack"]

func do_thing(parent_action:BaseAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	
	var turn_data = que_exe_data.get_current_turn_data()
	var target_key = subaction_data['TargetKey']
	var target_param_key = turn_data.get_param_key_for_target(target_key)
	var target_params = parent_action.get_targeting_params(target_param_key, actor)
	
	var weapon = actor.equipment.get_primary_weapon()
	if !weapon:
		printerr("No Weapon")
		return BaseSubAction.Failed
	var damage_datas = actor.get_default_attack_damage_datas()
	var missile_data = (weapon as BaseWeaponEquipment).get_misile_data()
	
	var tag_chain = SourceTagChain.new()\
			.append_source(SourceTagChain.SourceTypes.Actor, actor)\
			.append_source(SourceTagChain.SourceTypes.Action, parent_action)
	
	if missile_data:
		var target_spots = _find_target_effected_spots(target_key, que_exe_data, game_state, actor)
		if not target_spots:
			printerr("SubAct_SpawnMissile.get_target_spt_of_missile: No target found for : ", target_key)
			return BaseSubAction.Failed
		
		var actor_pos = game_state.get_actor_pos(actor)
		if damage_datas.size() > 0:
			missile_data['DamageData'] = damage_datas.values()[0]
		for target_spot in target_spots:
			var missile = BaseMissile.new(actor, missile_data, tag_chain, target_params,
											actor_pos, target_spot, parent_action.get_load_path())
			CombatRootControl.Instance.create_new_missile_node(missile)
	else:
		var targets:Array = _find_target_effected_actors(parent_action, subaction_data, target_key, que_exe_data, game_state, actor)
		for target:BaseActor in targets:
			for damage_data in damage_datas.values():
				DamageHelper.handle_attack(actor, target, {}, damage_data, [], tag_chain, game_state,target_params)
	
	#var offhand_weapon = actor.equipment.get_offhand_weapon()
	#if offhand_weapon:
		#var offhand_damage_data = (offhand_weapon as BaseWeaponEquipment).get_damage_data()
		#for target:BaseActor in targets:
			#DamageHelper.handle_attack(actor, target, offhand_damage_data, tag_chain, game_state)
	
	return BaseSubAction.Success
	
