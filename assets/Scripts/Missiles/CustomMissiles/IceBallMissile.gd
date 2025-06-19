class_name IceBallMissile
extends BaseMissile


func do_thing(game_state:GameStateData):
	if LOGGING: 
		print('Missile ' + str(Id) + " has done thing.")
	var source_actor = ActorLibrary.get_actor(_source_actor_id)
	if not source_actor:
		printerr("BaseMissile.do_thing: No Source Actor found with id '%s'." % [_source_actor_id])
		return
		
	var parent_action_key = _missle_data.get("ParentActionKey", "WaterBallSpell")
	var parent_action = ItemLibrary.get_item(parent_action_key) as PageItemAction
	
	var damage_data = _missle_data['DamageData']
	var damage_datas = {"MissileDamage": damage_data}
	
	
	var targets = game_state.get_actors_at_pos(TargetSpot)
		#if _target_params.is_valid_target_actor(source_actor, target_actor, game_state):
	if targets.size() > 0:
		AttackHandler.handle_attack(
			source_actor,
			targets,
			_missle_data.get("AttackDetails", {}),
			damage_datas, 
			_missle_data.get("EffectDatas", []),
			_source_target_chain,
			_target_params,
			CombatRootControl.Instance.GameState,
			MapPos.Vector2i(StartSpot)
		)
	
	var effect_area = [TargetSpot]
	if _target_params.has_area_of_effect():
		effect_area = _target_params.get_area_of_effect(MapPos.Vector2i(TargetSpot))
	var sub_missile_data = parent_action.get_missile_data("SubMissile")
	var sub_missile_damage = parent_action.get_damage_data_single(source_actor, "SubMissileDamage")
	
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
