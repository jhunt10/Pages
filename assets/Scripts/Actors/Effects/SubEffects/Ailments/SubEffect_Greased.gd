class_name SubEffect_Greased
extends BaseSubEffect

func get_required_props()->Dictionary:
	return {}

func get_triggers(_effect:BaseEffect, subeffect_data:Dictionary)->Array:
	return [BaseEffect.EffectTriggers.OnDamageTaken]

func on_damage_taken(effect:BaseEffect, subeffect_data:Dictionary,
					game_state:GameStateData, damage_event:DamageEvent):
	var effected_actor = effect.get_effected_actor()
	var ailment_duration = max(effect.RemainingDuration, 2)
	if damage_event.damage_type == DamageEvent.DamageTypes.Fire:
		var ailment_key = "AilmentBurned"
		var ailment_data = {
			"DurationData":{
				"BaseDuration":ailment_duration
		}}
		var ailment_effect = EffectHelper.create_effect(effected_actor, damage_event.source, ailment_key, ailment_data, game_state, '', true)
		if ailment_effect:
			effected_actor.effects.remove_effect(effect, false)
	
	elif damage_event.damage_type == DamageEvent.DamageTypes.Cold:
		var ailment_key = "AilmentChilled"
		var ailment_data = {
			"DurationData":{
				"BaseDuration":ailment_duration
		}}
		var ailment_effect = EffectHelper.create_effect(effected_actor, damage_event.source, ailment_key, ailment_data, game_state, '', true)
		if ailment_effect:
			effected_actor.effects.remove_effect(effect, false)
	
	elif damage_event.damage_type == DamageEvent.DamageTypes.Shock:
		var ailment_key = "AilmentShocked"
		var ailment_data = {
			"DurationData":{
				"BaseDuration":ailment_duration
		}}
		var ailment_effect = EffectHelper.create_effect(effected_actor, damage_event.source, ailment_key, ailment_data, game_state, '', true)
		if ailment_effect:
			effected_actor.effects.remove_effect(effect, false)
