class_name BasePotionSupplyItem
extends BaseSupplyItem

func get_tags()->Array:
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
	var effect_datas = supply_item_data.get("EffectDatas", {})
	for target_actor:BaseActor in target_actors:
		for effect_data_key in effect_datas.keys():
			var effect_metadata = effect_datas[effect_data_key]
			var effect_key = effect_metadata.get("EffectKey", "")
			var effect_data = effect_metadata.get("EffectData", {})
			EffectHelper.create_effect(target_actor, self, effect_key, effect_data, game_state)
	
	pass
