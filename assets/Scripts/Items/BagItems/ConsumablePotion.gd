class_name ConsumablePotion
extends BaseConsumableItem


func use_in_combat(actor:BaseActor, target, game_state:GameStateData):
	if target is BaseActor:
		var target_actor = target as BaseActor
		var effect_key = get_load_val("EffectKey", null)
		if effect_key:
			target_actor.effects.add_effect(actor, effect_key, get_load_val("EffectData", {}), game_state)
	else:
		printerr("ConsumablePotion.use_in_combat: Target '%s' is not BaseActor")
