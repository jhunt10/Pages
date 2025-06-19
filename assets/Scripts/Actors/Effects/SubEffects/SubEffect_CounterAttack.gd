#class_name SubEffect_CounterAttack
#extends BaseSubEffect
#
#func get_required_props()->Dictionary:
	#return {
		#
	#}
#
### Returns an array of EffectTriggers on which to call this SubEffect
#func get_triggers(_effect:BaseEffect, subeffect_data:Dictionary)->Array:
	#return [BaseEffect.EffectTriggers.OnDefending]
#
#func on_defending(effect:BaseEffect, _subeffect_data:Dictionary, game_state:GameStateData, attack_event:AttackEvent):
	#if attack_event.attack_stage != AttackEvent.AttackStage.Resolved:
		#return
	##var countering_actor = effect.get_effected_actor()
	##var counter_target_actor = attack_event.attacker
	##var primary_weapon = countering_actor.get_action_key_list()
	##var target_params = countering_actor.get_default_attack_target_params()
	### Check if in range
	##if not TargetingHelper.is_actor_targetable(target_params, countering_actor, counter_target_actor, game_state):
		##return
	##var damage_data = countering_actor.get_default_attack_damage_datas()
	##var source_tag_chain = attack_event.source_tag_chain.copy_and_append(SourceTagChain.SourceTypes.Effect, effect)
	##DamageHelper.handle_attack(effect.get_effected_actor(), attack_event.attacker, 
									##damage_data,source_tag_chain, game_state, target_params)
