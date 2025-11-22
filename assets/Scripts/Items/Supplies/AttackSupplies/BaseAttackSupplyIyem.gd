class_name BaseAttackSupplyItem
extends BaseSupplyItem

func get_tags()->Array:
	var tags = super()
	if not tags.has("AtkItem"):
		tags.append("AtkItem")
	return tags

func use_in_combat(actor:BaseActor, target, game_state:GameStateData):
	var target_actors = []
	var center_pos = null
	if target is MapPos:
		center_pos = target
	elif target is BaseActor:
		target_actors = [target]
		center_pos = game_state.get_actor_pos(target)
	
	if center_pos == null or not center_pos is MapPos:
		printerr("AoeAttackItem.use_in_combat: Invalid or null target MapPos from target: %s" % [target])
		return
	
	var attack_data:Dictionary = supply_item_data.get("AttackData", {})
	if attack_data.size() == 0:
		printerr("AoeAttackItem.use_in_combat: No AttackData found on '%s'" % [self.Id])
		return
	
	var target_params = TargetParameters.new("AtkItemTargetParams", attack_data.get("TargetParams", {}))
	if target_params.has_area_of_effect():
		target_actors = TargetingHelper.get_targeted_actors(target_params, [center_pos], actor, game_state)
	
	if attack_data.has("OnUseVfxData"):
		var vfx_data = attack_data.get("OnUseVfxData").duplicate()
		vfx_data['LoadPath'] = self.get_load_path()
		var vfx_key = vfx_data.get("VfxKey", "AttackItemVfx_NoKey")
		var vfx_node = VfxHelper.create_vfx_at_pos(center_pos, vfx_key, vfx_data, actor)
	
	var source_tag_chain = SourceTagChain.new()\
			.append_source(SourceTagChain.SourceTypes.Actor, actor)\
			.append_source(SourceTagChain.SourceTypes.Item, self)
	var attack_details = attack_data.get("AttackDetails", {})
	var damage_datas = attack_data.get("DamageDatas", {})
	var effect_datas = attack_data.get("EffectDatas", {})
	var attack_event = AttackHandler.handle_attack(
		actor, 
		target_actors, 
		attack_details, 
		damage_datas, 
		effect_datas, 
		source_tag_chain,
		game_state, 
		target_params.has_area_of_effect(),
		center_pos
	)
	pass
