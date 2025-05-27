class_name SubEffect_ApplyDotDamage
extends BaseSubEffect

func get_required_props()->Dictionary:
	return {
		"DamageKey": BaseSubEffect.SubEffectPropTypes.DamageKey,
		"DamageKeys": BaseSubEffect.SubEffectPropTypes.ListVal,
		"OptionalTriggers": BaseSubEffect.SubEffectPropTypes.Triggers}

func on_effect_trigger(effect:BaseEffect, subeffect_data:Dictionary, trigger:BaseEffect.EffectTriggers, game_state:GameStateData):
	var actor = effect.get_effected_actor()
	var source_tag_chain = SourceTagChain.new()
	
	var source_actor = effect.get_source_actor()
	if source_actor:
		source_tag_chain.append_source(SourceTagChain.SourceTypes.Actor, source_actor)
	source_tag_chain.append_source(SourceTagChain.SourceTypes.Effect, effect)
	
	var damage_keys = []
	if subeffect_data.has("DamageKey"):
		damage_keys.append(subeffect_data['DamageKey'])
	if subeffect_data.has("DamageKeys"):
		damage_keys.append_array(subeffect_data['DamageKeys'])
	
	for damage_key in damage_keys:
		var damage_data = effect.DamageDatas.get(damage_key, {})
		damage_data['DamageDataKey'] = damage_key
		var damage_event = DamageHelper.roll_for_damage(damage_data, source_actor, actor, source_tag_chain, {})
		actor.stats.apply_damage(damage_event.final_damage)
		damage_event.was_applied = true
		actor.effects.trigger_damage_taken(game_state, damage_event)
		
		# Create Damage VFX 
		var damage_effect = damage_data.get("DamageVfxKey", null)
		var damage_effect_data = damage_data.get("DamageVfxData", {}).duplicate(true)
		if damage_effect:
			if source_actor:
				damage_effect_data['SourceActorId'] = source_actor.Id
			damage_effect_data['ShakeActor'] = false
			damage_effect_data['DamageNumber'] = 0 - damage_event.final_damage
			damage_effect_data['DamageTextType'] = FlashTextController.FlashTextType.DOT_Dmg
			if damage_event.final_damage < 0:
				damage_effect_data['DamageTextType'] = FlashTextController.FlashTextType.Healing_Dmg
			VfxHelper.create_damage_effect(actor, damage_effect, damage_effect_data)
		if source_actor:
			source_actor.effects.trigger_damage_dealt(game_state, damage_event)
		if actor.is_dead:
			break
	
