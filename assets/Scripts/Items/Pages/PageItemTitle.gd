class_name PageItemTitle
extends BasePageItem

var title_data:Dictionary:
	get:
		return _def.get("TitleData", {})

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


# -----------------------------------------------------------------
#					Title Level
# -----------------------------------------------------------------
func get_level()->int:
	return get_load_val("Level", 1)

func get_xp()->int:
	return get_load_val("Xp", 1)

func set_level_and_xp(level:int, xp:int):
	set_load_val(["Xp"], xp)
	set_load_val(["Level"], level)

func add_xp(value:int)->bool:
	var old_level = get_level()
	var new_level = old_level
	var new_total_xp = get_xp() + value
	var required_xp = get_xp_to_next_level(new_level)
	while new_total_xp >= required_xp:
		new_level += 1
		new_total_xp -= required_xp
		required_xp = get_xp_to_next_level(new_level)
	
	set_load_val(["Xp"], new_total_xp)
	if old_level != new_level:
		set_load_val(["Level"], new_level)
		return true
	return false

func get_xp_to_next_level(current_level:int=-1)->int:
	if current_level < 0:
		current_level = get_level()
	return (100 * current_level)

func get_skill_tree_data()->Array:
	return title_data.get("SkillTree", []).duplicate()
