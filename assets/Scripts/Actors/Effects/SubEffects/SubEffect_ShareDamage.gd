class_name SubEffect_ShareDamage
extends BaseSubEffect

func get_required_props()->Dictionary:
	return {
		"ShareWith": BaseSubEffect.SubEffectPropTypes.EnumVal,
	}

func get_prop_enum_values(key:String)->Array: 
	if key == "ShareWith":
		return ["Attacker", "EffectSource"]
	return []

func get_triggers(effect:BaseEffect, subeffect_data:Dictionary)->Array:
	return [BaseEffect.EffectTriggers.OnDamageTaken]
	
func on_damage_taken(effect:BaseEffect, subeffect_data:Dictionary,
					game_state:GameStateData, damage_event:DamageEvent):
	var victim = effect.get_effected_actor()
	var share_with = subeffect_data.get("ShareWith")
	if share_with == "Attacker":
		var attacker = damage_event.source as BaseActor
		if !attacker:
			printerr("SubEffect_ShareDamage.on_damage_taken: Damage source '%s' is not BaseActor.")
			return
		attacker.stats.apply_damage(damage_event.final_damage)
		CombatRootControl.Instance.create_flash_text_on_actor(attacker, str(damage_event.final_damage), FlashTextController.FlashTextType.DOT_Dmg)
		return
	if share_with == "EffectSource":
		var source_actor = effect.get_source_actor()
		if !source_actor:
			printerr("SubEffect_ShareDamage.on_damage_taken: Effect source '%s' is not BaseActor.")
			return
		source_actor.stats.apply_damage(damage_event.final_damage)
		CombatRootControl.Instance.create_flash_text_on_actor(source_actor, str(damage_event.final_damage), FlashTextController.FlashTextType.DOT_Dmg)
		return
	pass
