class_name SubAct_Attack
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"TargetKey": BaseSubAction.SubActionPropTypes.TargetKey,
		"DamageKey": BaseSubAction.SubActionPropTypes.DamageKey,
		"DamageKeys": BaseSubAction.SubActionPropTypes.StringVal,
		"EffectKeys": BaseSubAction.SubActionPropTypes.StringVal,
		# The target must still be within range at time of attack, or "Miss"
		"TargetMustBeInRange": BaseSubAction.SubActionPropTypes.BoolVal,
		# Ignore Aoe area and only attack directly selected targets
		"PrimaryTargetOnly": BaseSubAction.SubActionPropTypes.BoolVal,
		"FailOnNoTarget": BaseSubAction.SubActionPropTypes.BoolVal,
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return ["Attack"]

func do_thing(parent_action:BaseAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	
	var turn_data = que_exe_data.get_current_turn_data()
	var attack_details = parent_action.get_load_val("AttackDetails", {})
	attack_details['DisplayName'] = parent_action.details.display_name
	var tag_chain = SourceTagChain.new()\
			.append_source(SourceTagChain.SourceTypes.Actor, actor)\
			.append_source(SourceTagChain.SourceTypes.Action, parent_action)
	
	# Get Target info
	var target_key = subaction_data.get('TargetKey')
	if !target_key:
		printerr("SubAct_Attack: No 'TargetKey' on subaction in %s." % [parent_action.details.display_name])
		return Failed
	if not turn_data.has_target(target_key):
		if subaction_data.get("FailOnNoTarget", true):
			return BaseSubAction.Failed
		else:
			return BaseSubAction.Success
	var target_param_key = turn_data.get_param_key_for_target(target_key)
	var target_params = parent_action.get_targeting_params(target_param_key, actor)
	var targets_selected = turn_data.get_targets(target_key)
	var target_must_be_in_range = subaction_data.get("TargetMustBeInRange", true)
	var ignore_aoe = subaction_data.get("PrimaryTargetOnly", false)
	var targets = TargetingHelper.get_targeted_actors(
			target_params, 
			targets_selected, 
			actor, 
			game_state, 
			ignore_aoe
		)
	
	# Get Effect Datas
	var effect_datas = parent_action.get_load_val("EffectDatas", {})
	
	# Get Damage info
	var damage_datas = {}
	var damage_keys =  subaction_data.get("DamageKeys", [])
	if subaction_data.has("DamageKey"):
		var damage_key = subaction_data.get("DamageKey")
		if not damage_keys.has(damage_key):
			damage_keys.append(damage_key)
	damage_datas = parent_action.get_damage_datas(actor, damage_keys)
	var actor_pos = game_state.get_actor_pos(actor)
	
	# Handle special weapon logic 
	if "damage_key" == "Weapon":
		var weapon = actor.equipment.get_primary_weapon()
		# Create missile for ranged weapons
		var missile_data = (weapon as BaseWeaponEquipment).get_misile_data()
		if missile_data:
			_create_weapon_missile()
			return BaseSubAction.Success
	
	var missed_moved_actor = false
	var hit_any_actor = false
	var hittable_actors = []
	
	for target:BaseActor in targets:
		# Check if target is still in range since being selecting target
		if target_must_be_in_range:
			var target_pos = game_state.get_actor_pos(target)
			var still_in_range = target_params.is_point_in_area(actor_pos, target_pos)
			if not still_in_range:
				missed_moved_actor = true
				continue
		else:
			hit_any_actor = true
		hittable_actors.append(target)
			
	var attack_event = AttackHandler.handle_attack(
		actor, 
		hittable_actors,
		attack_details, 
		damage_datas, 
		effect_datas, 
		tag_chain, 
		target_params,
		game_state,
		null)
	
	if missed_moved_actor and not hit_any_actor:
		CombatRootControl.Instance.create_flash_text_on_actor(actor, "Miss", FlashTextController.FlashTextType.Miss)
	
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
