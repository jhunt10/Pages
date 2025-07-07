class_name HealthPotionSupplyItem
extends BasePotionSupplyItem

func get_item_tags()->Array:
	var tags = super()
	if not tags.has("Drink"):
		tags.append("Drink")
	return tags

func use_in_combat(actor:BaseActor, target, game_state:GameStateData):
	var target_actors = []
	if target is BaseActor:
		target_actors = [target]
	if target is MapSpot:
		target_actors = game_state.get_actors_at_pos(target)
	var heal_data = supply_item_data.get("HealData", {})
	var base_heal_val = heal_data.get("HealValue", 0)
	var is_percent = heal_data.get("IsPercent", true)
	
	for target_actor:BaseActor in target_actors:
		print("Used HealthPotion: %s on %s" % [actor.get_display_name(), target_actor.Id])
		var heal_val = base_heal_val
		if is_percent:
			heal_val = target_actor.stats.max_health * base_heal_val
		if heal_val > 0:
			target_actor.stats.apply_healing(heal_val)
			VfxHelper.create_damage_effect(target_actor, "Heal_DamageEffect", {"DamageNumber": heal_val})
		elif heal_val < 0:
			target_actor.stats.apply_damage(heal_val)
			VfxHelper.create_damage_effect(target_actor, "Hurt_DamageEffect", {"DamageNumber": heal_val})
		var hp_after = target_actor.stats.current_health
		print("Hp After: " + str(hp_after))
	pass
