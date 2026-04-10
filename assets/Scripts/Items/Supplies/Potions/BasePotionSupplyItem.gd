class_name BasePotionSupplyItem
extends BaseSupplyItem

func _get_object_specific_tags()->Array:
	var tags = [ "Potion", "Drinkable"]
	var effect_datas = supply_item_data.get("EffectDatas", {})
	for effect_data_key in effect_datas.keys():
		var effect_metadata = effect_datas[effect_data_key]
		var effect_key = effect_metadata.get("EffectKey", "")
		var effect_data = effect_metadata.get("EffectDataDef", {})
		var effect_tags = EffectLibrary._get_tags_for_effect_def(effect_key)
		effect_tags.erase("Effect")
		TagHelper.merge_lists(tags, effect_tags)
	TagHelper.merge_lists(tags, super())
	return tags

func use_in_combat(_actor:BaseActor, target, game_state:GameStateData):
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
			var effect_data = effect_metadata.get("EffectDataDef", {})
			EffectHelper.create_effect(target_actor, self, effect_key, effect_data, game_state)
	
	pass
