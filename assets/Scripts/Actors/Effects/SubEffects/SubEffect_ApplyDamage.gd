class_name SubEffect_ApplyDamage
extends BaseSubEffect

func get_required_props()->Dictionary:
	return {
		"DamageKey": BaseSubEffect.SubEffectPropTypes.DamageKey,
		"OptionalTriggers": BaseSubEffect.SubEffectPropTypes.Triggers}

func on_effect_trigger(effect:BaseEffect, _subeffect_data:Dictionary, trigger:BaseEffect.EffectTriggers, _game_state:GameStateData):
	var actor = effect.get_effected_actor()
	var damage_key = _subeffect_data.get("DamageKey")
	var damage_data = effect.DamageDatas.get(damage_key, {})
	var test_damage = damage_data.get("AtkPower", 0)
	actor.stats.apply_damage(test_damage, effect)
	
	var damage_effect = damage_data.get("DamageEffect", null)
	if damage_effect:
		CombatRootControl.Instance.create_damage_effect(actor, damage_effect, test_damage)
