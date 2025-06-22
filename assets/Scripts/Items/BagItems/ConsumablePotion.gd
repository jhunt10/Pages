class_name ConsumablePotion
extends BaseSupplyItem


func use_in_combat(actor:BaseActor, target, game_state:GameStateData):
	if target is BaseActor:
		var target_actor = target as BaseActor
		var effect_key = get_load_val("EffectKey", null)
		if effect_key:
			EffectHelper.create_effect(target_actor, actor, effect_key, get_load_val("EffectData", {}), game_state)
	else:
		printerr("ConsumablePotion.use_in_combat: Target '%s' is not BaseActor")
