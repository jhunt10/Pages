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
		printerr("SubAct_Attack: No 'TargetKey' on subaction in %s." % [parent_action.ItemKey])
		return BaseSubAction.Failed
	if not turn_data.has_target(target_key):
		if subaction_data.get("FailOnNoTarget", true):
			return BaseSubAction.Failed
		else:
			return BaseSubAction.Success
	var target_param_key = turn_data.get_param_key_for_target(target_key)
	var target_params = parent_action.get_targeting_params(target_param_key, actor)
	if !target_params:
		printerr("SubAct_Attack: Failed to find TargetParams for key %s on page %s." % [target_param_key, parent_action.ItemKey])
		return BaseSubAction.Failed
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
	
	var primary_target = null
	if targets_selected.size() > 0:
		primary_target = targets_selected[0]
	
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
	if damage_keys.size() > 0:
		damage_datas = parent_action.get_damage_datas(actor, damage_keys)
	
	var using_weapon = false
	for data in damage_datas.values():
		if data.get("IsWeaponDamage", false):
			using_weapon = true
			break
	# Handle special weapon logic 
	if using_weapon:
		var weapon = actor.equipment.get_primary_weapon()
		# Create missile for ranged weapons
		var missile_data = (weapon as BaseWeaponEquipment).get_misile_data()
		if missile_data:
			_create_weapon_missile()
			return BaseSubAction.Success
			
			
		var weapon_attack_details = (weapon as BaseWeaponEquipment).get_weapon_attack_details()
		attack_details = BaseLoadObjectLibrary._merge_defs(weapon_attack_details, attack_details)
	
	var actor_pos = game_state.get_actor_pos(actor)
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
	
	var override_origin_pos = null
	if subaction_data.get("UsePrimaryTargetAsOrigin", false):
		if primary_target is BaseActor or primary_target is String:
			override_origin_pos = game_state.get_actor_pos(primary_target)
		if primary_target is MapPos:
			override_origin_pos = primary_target
	
	var attack_event = AttackHandler.handle_attack(
		actor, 
		hittable_actors,
		attack_details, 
		damage_datas, 
		effect_datas, 
		tag_chain, 
		target_params,
		game_state,
		override_origin_pos)
	
	if missed_moved_actor and not hit_any_actor:
		VfxHelper.create_flash_text(actor, "Miss", VfxHelper.FlashTextType.Miss)
	
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
