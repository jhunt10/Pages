class_name SubEffect_AddedDamage
extends BaseSubEffect

func get_required_props()->Dictionary:
	return {
		"DamageModCondition": BaseSubEffect.SubEffectPropTypes.DamageKey,
		"AddForEachDamageEvent": BaseSubEffect.SubEffectPropTypes.BoolVal,
		"AddedDamageType": BaseSubEffect.SubEffectPropTypes.StringVal,
		"AddedDamageScale": BaseSubEffect.SubEffectPropTypes.FloatVal
	}

## Returns an array of EffectTriggers on which to call this SubEffect
func get_triggers(_effect:BaseEffect, subeffect_data:Dictionary)->Array:
	return [BaseEffect.EffectTriggers.OnAttacking_PostDamageRoll]

## After damage has been rolled for, but before it's been applied
func on_attacking_post_damage_roll(_effect:BaseEffect, subeffect_data:Dictionary, game_state:GameStateData, attack_event:AttackEvent):
	var mod_condition = subeffect_data.get("DamageModCondition", {})
	var attacker = game_state.get_actor(attack_event.attacker_id)
	for sub_event:AttackSubEvent in attack_event.sub_events.values():
		var defender = game_state.get_actor(sub_event.defending_actor_id)
		for damage_key:String in sub_event.damage_events.keys():
			var damage_data = attack_event.damage_datas[damage_key]
			var fake_mod = {"Conditions":mod_condition}
			if DamageHelper.does_damage_mod_apply(fake_mod, attacker, defender, damage_data, attack_event.source_tag_chain):
				var org_damage_event:DamageEvent = sub_event.damage_events[damage_key]
				var new_event = org_damage_event.duplicate()
	
	pass

func on_effect_trigger(effect:BaseEffect, subeffect_data:Dictionary, trigger:BaseEffect.EffectTriggers, game_state:GameStateData):
	pass
