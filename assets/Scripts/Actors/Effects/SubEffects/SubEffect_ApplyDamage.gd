#class_name SubEffect_ApplyDamage
#extends BaseSubEffect
#
#func get_required_props()->Dictionary:
	#return {
		#"DamageKey": BaseSubEffect.SubEffectPropTypes.DamageKey,
		#"OptionalTriggers": BaseSubEffect.SubEffectPropTypes.Triggers}
#
#func on_effect_trigger(effect:BaseEffect, subeffect_data:Dictionary, trigger:BaseEffect.EffectTriggers, game_state:GameStateData):
	#var actor = effect.get_effected_actor()
	#var damage_key = subeffect_data.get("DamageKey")
	#var damage_data = effect.DamageDatas.get(damage_key, {})
	#var test_damage = damage_data.get("FixedBaseDamage", 0)
	#var source_actor = effect.get_source_actor()
	#var tag_chain = SourceTagChain.new()
	#
	#if source_actor:
		#tag_chain.append_source(SourceTagChain.SourceTypes.Actor, source_actor)
	#tag_chain.append_source(SourceTagChain.SourceTypes.Effect, effect)
	#
	#
	#DamageHelper.handle_damage(effect, actor, damage_data,tag_chain, game_state)
