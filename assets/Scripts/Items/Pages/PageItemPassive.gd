class_name PageItemPassive
extends BasePageItem

var passive_data:Dictionary:
	get:
		return _def.get("PassiveData", {})

func _init(key:String, def_load_path:String, def:Dictionary, id:String='', data:Dictionary={}) -> void:
	super(key, def_load_path, def, id, data)


func get_rarity_background()->Texture2D:
	return ItemHelper.get_rarity_background(self.get_item_rarity(), true)

func get_effect_def():
	var effect_data:Dictionary = passive_data.get("EffectDatas", {})
	var effect_key = effect_data.get("EffectKey", null)
	if !effect_key:
		var effect_datas = effect_data
	if effect_key:
		return EffectLibrary.get_merged_effect_def(effect_key, effect_data)
	return null

func get_item_tags()->Array:
	var tags = []
	tags = super()
	if not tags.has("Passive"):
		tags.append("Passive")
	return tags
