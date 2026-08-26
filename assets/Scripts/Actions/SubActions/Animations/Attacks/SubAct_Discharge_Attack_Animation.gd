class_name SubAct_Discharge_Attack_Animation
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"TargetKey": BaseSubAction.SubActionPropTypes.TargetKey,
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_parent_action:PageItemAction, _subaction_data:Dictionary)->Array:
	return []

func do_thing(parent_action:PageItemAction, subaction_data:Dictionary, que_exe_data,
				game_state:GameStateData, actor:BaseActor)->bool:
	var turn_data = que_exe_data.get_current_turn_data()
	var target_key = subaction_data.get('TargetKey')
	var targets_selected = turn_data.get_targets(target_key)
	if targets_selected.size() == 0:
		printerr("SubAct_Discharge_Attack_Animation: No selected targets.")
		return BaseSubAction.Success
	
	if turn_data._attack_events.size() == 0:
		printerr("SubAct_Discharge_Attack_Animation: No AttackEvents.")
		return BaseSubAction.Success
	var center_actor_id = targets_selected[0]
	var center_actor = game_state.get_actor(center_actor_id, true)
	var attack_event = turn_data._attack_events[0]
	
	for sub_attack_event_key in attack_event.sub_events.keys():
		var sub_attack_event:AttackSubEvent = attack_event.sub_events.get(sub_attack_event_key)
		if sub_attack_event.defending_actor_id == center_actor_id:
			continue
		VfxHelper.create_vfx_for_sub_attack_event(attack_event, game_state, sub_attack_event, center_actor)
	
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
