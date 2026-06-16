class_name PageItemTitle
extends BasePageItem

#var title_data:Dictionary:
	#get:
		#return _def.get("TitleData", {})

func _init(key:String, def_load_path:String, def:Dictionary, id:String='', data:Dictionary={}) -> void:
	super(key, def_load_path, def, id, data)


func get_rarity_background()->Texture2D:
	return ItemHelper.get_rarity_background(BaseItem.ItemRarity.Unique, false)

func get_tags()->Array:
	var tags = []
	tags = super()
	if not tags.has("Title"):
		tags.append("Title")
	return tags

func get_title_key()->String:
	return page_data.get("SourceTitle", "")

func get_player_color():
	var color_code = page_data.get("TitleColor", "FFFFFF")
	return Color.from_string(color_code, Color.WHITE)

func get_base_stats()->Dictionary:
	var stats = page_data.get("Stats", {})
	return stats

func get_merged_carrier_stat_mods()->Array:
	var sub_data = get_data_containing_mods()
	var stat_mod_datas:Dictionary = sub_data.get("MergedStatMods", {})
	var out_list = []
	for mod_data in stat_mod_datas.values():
		if not mod_data.has("DisplayName"):
			mod_data['DisplayName'] = self.get_display_name()
			mod_data['SourceItemId'] = self.Id
		out_list.append(BaseStatMod.create_from_data(Id, mod_data))
	return out_list
