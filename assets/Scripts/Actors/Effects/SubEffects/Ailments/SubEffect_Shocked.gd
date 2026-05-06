class_name SubEffect_ApplyDamage_Shocked
extends BaseSubEffect

func get_required_props()->Dictionary:
	return {
		"DamageKey": BaseSubEffect.SubEffectPropTypes.DamageKey,
		"OptionalTriggers": BaseSubEffect.SubEffectPropTypes.Triggers}

func on_effect_trigger(effect:BaseEffect, subeffect_data:Dictionary, _trigger:BaseEffect.EffectTriggers, game_state:GameStateData):
	var actor = effect.get_effected_actor()
	var damage_key = subeffect_data.get("DamageKey")
	var damage_data = effect.get_damage_data(damage_key, actor)
	var source_actor = effect.get_source_actor()
	var tag_chain = SourceTagChain.new()
	
	if source_actor:
		tag_chain.append_source(SourceTagChain.SourceTypes.Actor, source_actor)
	tag_chain.append_source(SourceTagChain.SourceTypes.Effect, effect)
	
	var damage_event = DamageHelper.roll_for_damage(damage_data, source_actor, actor, tag_chain, game_state, {})
	actor.apply_damage(damage_event.final_damage)
	damage_event.was_applied = true
	actor.effects.trigger_damage_taken(game_state, damage_event)
	
	# Create Damage VFX
	VfxHelper.create_vfx_for_damage_event(actor, damage_event, damage_data)
	
	 # Hit adjacent actors
	var adj_actors = MapHelper.get_adjacent_actors(game_state, actor)
	var shared_damage_data = damage_data.duplicate(true)
	shared_damage_data['AtkStat'] = "Fixed"
	shared_damage_data['BaseDamage'] = damage_event.damage_after_mods
	shared_damage_data['AtkPwrBase'] = 100
	shared_damage_data['AtkPwrRange'] = 0
	for adj_actor in adj_actors:
		var adj_damage_event = DamageHelper.roll_for_damage(shared_damage_data, source_actor, actor, tag_chain, game_state, {})
		adj_actor.apply_damage(adj_damage_event.final_damage)
		adj_damage_event.was_applied = true
		adj_actor.effects.trigger_damage_taken(game_state, adj_damage_event)
		var vfx_node = VfxHelper.create_vfx_on_actor(adj_actor, "LightningChain_AttackVfx", {"SourceActorId": actor.Id, "HostActorId": adj_actor.Id})
		
		VfxHelper.chain_vfx_for_damage_event(vfx_node, damage_event, shared_damage_data)
