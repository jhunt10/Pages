class_name SubEffect_ApplyDamage_Shocked
extends BaseSubEffect

func get_required_props()->Dictionary:
	return {
		"DamageKey": BaseSubEffect.SubEffectPropTypes.DamageKey,
		"OptionalTriggers": BaseSubEffect.SubEffectPropTypes.Triggers}

func on_effect_trigger(effect:BaseEffect, subeffect_data:Dictionary, trigger:BaseEffect.EffectTriggers, game_state:GameStateData):
	var actor = effect.get_effected_actor()
	var damage_key = subeffect_data.get("DamageKey")
	var damage_data = effect.get_damage_data(damage_key, actor)
	var test_damage = damage_data.get("FixedBaseDamage", 0)
	var source_actor = effect.get_source_actor()
	var tag_chain = SourceTagChain.new()
	
	if source_actor:
		tag_chain.append_source(SourceTagChain.SourceTypes.Actor, source_actor)
	tag_chain.append_source(SourceTagChain.SourceTypes.Effect, effect)
	
	#var main_damage_event = DamageHelper.handle_damage(effect, actor, damage_data, tag_chain, game_state)
	var damage_event = DamageHelper.roll_for_damage(damage_data, source_actor, actor, tag_chain, game_state, {})
	actor.apply_damage(damage_event.final_damage)
	damage_event.was_applied = true
	actor.effects.trigger_damage_taken(game_state, damage_event)
	
	# Create Damage VFX 
	var main_damage_effect = damage_data.get("DamageVfxKey", null)
	var main_damage_effect_data = damage_data.get("DamageVfxData", {}).duplicate(true)
	if main_damage_effect:
		if source_actor:
			main_damage_effect_data['SourceActorId'] = source_actor.Id
		main_damage_effect_data['ShakeActor'] = false
		main_damage_effect_data['DamageNumber'] = 0 - damage_event.final_damage
		main_damage_effect_data['DamageTextType'] = VfxHelper.FlashTextType.DOT_Dmg
		VfxHelper.create_damage_effect(actor, main_damage_effect, main_damage_effect_data)
		
	
	var adj_actors = MapHelper.get_adjacent_actors(game_state, actor)
	var shared_damage_data = damage_data.duplicate(true)
	shared_damage_data['AtkStat'] = "Fixed"
	shared_damage_data['BaseDamage'] = damage_event.damage_after_mods
	shared_damage_data['AtkPwrBase'] = 100
	shared_damage_data['AtkPwrRange'] = 0
	shared_damage_data['DamageEffect'] = null
	for adj_actor in adj_actors:
		var adj_damage_event = DamageHelper.roll_for_damage(shared_damage_data, source_actor, actor, tag_chain, game_state, {})
		adj_actor.apply_damage(adj_damage_event.final_damage)
		adj_damage_event.was_applied = true
		adj_actor.effects.trigger_damage_taken(game_state, adj_damage_event)
		#var adj_damage_event = DamageHelper.handle_damage(effect, adj_actor, shared_damage_data, tag_chain, game_state, null, false)
		var vfx_node = VfxHelper.create_vfx_on_actor(adj_actor, "LightningChainVfx", {"SourceActorId": actor.Id, "HostActorId": adj_actor.Id})
		var adj_damage_effect_data = VfxLibrary.get_vfx_def("SmallLightning_DamageEffect")
		adj_damage_effect_data['ShakeActor'] = false
		adj_damage_effect_data['DamageTextType'] = VfxHelper.FlashTextType.DOT_Dmg
		adj_damage_effect_data['DamageNumber'] = 0 - adj_damage_event.final_damage
		vfx_node.add_damage_effect(adj_damage_effect_data)
