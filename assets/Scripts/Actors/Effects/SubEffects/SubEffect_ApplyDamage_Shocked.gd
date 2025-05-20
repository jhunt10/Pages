class_name SubEffect_ApplyDamage_Shocked
extends BaseSubEffect

func get_required_props()->Dictionary:
	return {
		"DamageKey": BaseSubEffect.SubEffectPropTypes.DamageKey,
		"OptionalTriggers": BaseSubEffect.SubEffectPropTypes.Triggers}

func on_effect_trigger(effect:BaseEffect, subeffect_data:Dictionary, trigger:BaseEffect.EffectTriggers, game_state:GameStateData):
	var actor = effect.get_effected_actor()
	var damage_key = subeffect_data.get("DamageKey")
	var damage_data = effect.DamageDatas.get(damage_key, {})
	var test_damage = damage_data.get("FixedBaseDamage", 0)
	var source_actor = effect.get_source_actor()
	var tag_chain = SourceTagChain.new()
	
	if source_actor:
		tag_chain.append_source(SourceTagChain.SourceTypes.Actor, source_actor)
	tag_chain.append_source(SourceTagChain.SourceTypes.Effect, effect)
	
	var main_damage_event = DamageHelper.handle_damage(effect, actor, damage_data, tag_chain, game_state)
	
	var adj_actors = MapHelper.get_adjacent_actors(game_state, actor)
	var shared_damage_data = damage_data.duplicate(true)
	shared_damage_data['AtkStat'] = "Fixed"
	shared_damage_data['BaseDamage'] = main_damage_event.raw_damage
	shared_damage_data['AtkPwrBase'] = 100
	shared_damage_data['AtkPwrRange'] = 0
	#shared_damage_data['DamageEffect'] = null
	for adj_actor in adj_actors:
		var damage_event = DamageHelper.handle_damage(effect, adj_actor, shared_damage_data, tag_chain, game_state, null, false)
		var vfx_node = VfxHelper.create_vfx_on_actor(adj_actor, "LightningChainVfx", {"SourceActorId": actor.Id, "HostActorId": adj_actor.Id})
		var damage_effect_data = VfxLibrary.get_vfx_def("SmallLightning_DamageEffect")
		damage_effect_data['DamageTextType'] = FlashTextController.FlashTextType.DOT_Dmg
		damage_effect_data['DamageNumber'] = 0 - damage_event.final_damage
		vfx_node.add_damage_effect(damage_effect_data)
