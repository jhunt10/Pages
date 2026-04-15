class_name PageItemPassive
extends BasePageItem

var passive_data:Dictionary:
	get:
		return _def.get("PassiveData", {})

func _init(key:String, def_load_path:String, def:Dictionary, id:String='', data:Dictionary={}) -> void:
	super(key, def_load_path, def, id, data)

func get_effect_def():
	var effect_data:Dictionary = passive_data.get("EffectDatas", {})
	var effect_key = effect_data.get("EffectKey", null)
	if effect_key:
		return EffectLibrary.get_merged_effect_def(effect_key, effect_data)
	return null

func _get_object_specific_tags()->Array:
	var tags = ["Passive"]
	#if page_data.get("ItemSlotsMods", {}).size() > 0:
		#tags.append("HandMod")
	if page_data.get("HandConditionMods", {}).size() > 0:
		tags.append("HandMod")
	if page_data.get("StatMods", {}).size() > 0:
		tags.append("StatMod")
	if page_data.get("TargetMods", {}).size() > 0:
		tags.append("TargetMod")
	if page_data.get("AmmoMods", {}).size() > 0:
		tags.append("AmmoMod")
	if page_data.get("AttackMods", {}).size() > 0:
		tags.append("AttackMod")
	if page_data.get("DamageMods", {}).size() > 0:
		tags.append("HandMod")
	if page_data.get("WeaponMods", {}).size() > 0:
		tags.append("WpnMod")
	return tags

func get_action_mods()->Dictionary:
	var mods = passive_data.get("ActionMods", {})
	for key in mods.keys():
		mods[key]["ModKey"] = key
		mods[key]["DisplayName"] = self.get_display_name()
		mods[key]["SourceItemId"] = self._id
	return mods

func get_hand_mods()->Array:
	var tdata = page_data.duplicate()
	var mods = tdata.get("HandConditionMods", [])
	return mods
	
	
