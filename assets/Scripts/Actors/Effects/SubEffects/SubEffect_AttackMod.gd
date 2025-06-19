#class_name SubEffect_AttackMod
#extends BaseSubEffect
#
#func get_required_props()->Dictionary:
	#return {
		#
	#}
#
### Returns an array of EffectTriggers on which to call this SubEffect
#func get_triggers(_effect:BaseEffect, subeffect_data:Dictionary)->Array:
	#return [BaseEffect.EffectTriggers.OnAttacking]
#
#func on_attacking(_effect:BaseEffect, _subeffect_data:Dictionary, _game_state:GameStateData, attack_event:AttackEvent):
	#on_effect_trigger(_effect, _subeffect_data, BaseEffect.EffectTriggers.OnAttacking, _game_state)
	#if attack_event.attack_stage == AttackEvent.AttackStage.PreAttackRoll:
		#if ( _subeffect_data.keys().has("CritMod:Back") 
			#and attack_event.attack_direction == attack_event.AttackDirection.Back):
			#attack_event.attacker_crit_chance = _subeffect_data.get(("CritMod:Back"))
	#pass
#
#func on_defending(_effect:BaseEffect, _subeffect_data:Dictionary, _game_state:GameStateData, _attack_event:AttackEvent):
	#on_effect_trigger(_effect, _subeffect_data, BaseEffect.EffectTriggers.OnDefending, _game_state)
	#pass
