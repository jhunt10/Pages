class_name IceBallMissile
extends BaseMissile


func do_thing(game_state:GameStateData):
	if LOGGING: 
		print('Missile ' + str(Id) + " has done thing.")
	var source_actor = ActorLibrary.get_actor(_source_actor_id)
	if not source_actor:
		printerr("BaseMissile.do_thing: No Source Actor found with id '%s'." % [_source_actor_id])
		return
		
	var parent_action_key = _missle_data.get("ParentActionKey", "IceBallSpell")
	var parent_action = ActionLibrary.get_action(parent_action_key)
	
	
	var sub_missile_damage_key = _missle_data.get("SubMissileDamageKey", "IceBallSpell")
	var sub_missile_damage = parent_action.get_damage_data_for_subaction(source_actor, {"DamageKey": sub_missile_damage_key})
	
	
	for target_actor in game_state.get_actors_at_pos(TargetSpot):
		#if _target_params.is_valid_target_actor(source_actor, target_actor, game_state):
		DamageHelper.handle_attack(source_actor, target_actor, 
								_missle_data.get("AttackDetails", {}), _missle_data['DamageData'], 
								_missle_data.get("EffectDatas", []),
								_source_target_chain, CombatRootControl.Instance.GameState,
								_target_params, MapPos.Vector2i(StartSpot))
	
	var effect_area = [TargetSpot]
	if _target_params.has_area_of_effect():
		effect_area = _target_params.get_area_of_effect(MapPos.Vector2i(TargetSpot))
	var sub_missile_key = _missle_data.get("SubMissileKey", "")
	var sub_missile_data = parent_action.MissileDatas.get(sub_missile_key, {})
	for spot in effect_area:
		if spot == TargetSpot:
			continue
		sub_missile_data['DamageData'] = sub_missile_damage
		sub_missile_data['AttackDetails'] = parent_action.get_load_val("AttackDetails", {})
		sub_missile_data['EffectDatas'] = parent_action.get_load_val("EffectDatas", {})
		var sub_missile = BaseMissile.new(source_actor, sub_missile_data, _source_target_chain, _target_params,
										MapPos.Vector2i(TargetSpot), MapPos.Vector2i(spot), parent_action.get_load_path())
		CombatRootControl.Instance.create_new_missile_node(sub_missile)
		
	
	node.on_missile_reach_target()
