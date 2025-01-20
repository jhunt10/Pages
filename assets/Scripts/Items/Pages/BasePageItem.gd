class_name BasePageItem
extends BaseItem


func get_item_type()->ItemTypes:
	return ItemTypes.Equipment

func get_item_tags()->Array:
	var tags = super()
	if !tags.has("Page"):
		tags.append("Page")
	return tags

func _init(key:String, def_load_path:String, def:Dictionary, id:String='', data:Dictionary={}) -> void:
	super(key, def_load_path, def, id, data)
	var details_data = def.get("Details", {})
	var action_key = def.get("ActionKey")
	var effect_key = def.get("EffectKey")
	if action_key and not effect_key:
		var action_def = ActionLibrary.get_action_def(action_key)
		var org_detail_data =  action_def.get("Details", {"Tags":[]})
		if not org_detail_data['Tags'].has("Action"):
			org_detail_data['Tags'].append("Action")
		details_data = BaseLoadObjectLibrary._merge_defs(details_data,org_detail_data)
		if ActionLibrary.Instance._defs_to_load_paths.has(action_key):
			details = ObjectDetailsData.new(ActionLibrary.Instance._defs_to_load_paths[action_key], details_data)
	if effect_key and not action_key:
		var effect_def = EffectLibrary.get_effect_def(effect_key)
		var org_detail_data =  effect_def.get("Details", {"Tags":[]})
		if not org_detail_data['Tags'].has("Passive"):
			org_detail_data['Tags'].append("Passive")
		details_data = BaseLoadObjectLibrary._merge_defs(details_data,org_detail_data)
		details = ObjectDetailsData.new(EffectLibrary.Instance._defs_to_load_paths[effect_key], details_data)

func get_action_key():
	return get_load_val("ActionKey")

func get_action()->BaseAction:
	var action_key = get_load_val("ActionKey")
	if action_key:
		return ActionLibrary.get_action(action_key)
	return null

func get_effect_def():
	var effect_key = get_load_val("EffectKey")
	if effect_key:
		return EffectLibrary.get_effect_def(effect_key)
	return null

func get_tags_added_to_actor()->Array:
	return get_load_val("AddTags", [])


func get_rarity_background()->Texture2D:
	if get_load_val("EffectKey"):
		var rarity = get_item_rarity()
		
		if rarity == BaseItem.ItemRarity.Mundane:
			return SpriteCache.get_sprite("res://assets/Sprites/Paper/Mundane_Background.png")
		if rarity == BaseItem.ItemRarity.Common:
			return SpriteCache.get_sprite("res://assets/Sprites/Paper/Common_Clipped_Background.png")
		if rarity == BaseItem.ItemRarity.Rare:
			return SpriteCache.get_sprite("res://assets/Sprites/Paper/Rare_Clipped_Background.png")
		if rarity == BaseItem.ItemRarity.Legendary:
			return SpriteCache.get_sprite("res://assets/Sprites/Paper/Legend_Clipped_Background.png")
		if rarity == BaseItem.ItemRarity.Unique:
			return SpriteCache.get_sprite("res://assets/Sprites/Paper/Unique_Background.png")
	return ItemHelper.get_rarity_background(self.get_item_rarity())
