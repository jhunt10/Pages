class_name StatModLabelContainer
extends HBoxContainer

@export var modded_stat_icon:TextureRect
@export var modded_stat_name_label:Label
@export var mod_value_label:Label
@export var dep_stat_label:Label
@export var dep_stat_icon:TextureRect
@export var plus_label:Label
@export var times_label:Label

func set_mod_data(mod_data:Dictionary):
	var stat_name:String = mod_data.get("StatName", "")
	if stat_name.begins_with("Bar"):
		var display_stat_name = stat_name
		var tokens = stat_name.split(":") 
		display_stat_name = tokens[1]
		stat_name = tokens[1]
		if tokens[0] == "BarMax":
			display_stat_name = "Max " + display_stat_name
		elif tokens[0] == "BarRgen":
			display_stat_name = display_stat_name + "/" + tokens[2]
		modded_stat_name_label.text = display_stat_name
		modded_stat_icon.texture = StatHelper.get_stat_icon("BarStat")
		modded_stat_icon.modulate = StatHelper.StatBarColors.get(stat_name, Color.WHITE)
		modded_stat_icon.show()
	else:
		modded_stat_name_label.text = StatHelper.get_stat_abbr(stat_name)
		var icon = StatHelper.get_stat_icon(stat_name)
		if icon:
			modded_stat_icon.texture = icon
		else:
			modded_stat_icon.hide()
	mod_value_label.text = str(mod_data.get("Value", 0))
	var dep_stat = mod_data.get("DepStatName", "???")
	var dep_stat_abbr = StatHelper.get_stat_abbr(dep_stat)
	dep_stat_label.text =  dep_stat_abbr
	if (dep_stat_abbr == "STR" or dep_stat_abbr == "AGL" or dep_stat_abbr == "INT" or dep_stat_abbr == "WIS"):
		var dep_icon = StatHelper.get_stat_icon(dep_stat)
		if dep_icon:
			dep_stat_icon.texture = StatHelper.get_stat_icon(dep_stat)
			dep_stat_label.text =  dep_stat_abbr.substr(1,2)
	else:
		dep_stat_label.hide()
		dep_stat_icon.hide()
	var mod_type_str = mod_data.get("ModType")
	var mod_type = BaseStatMod.ModTypes.get(mod_type_str)
	if mod_type == BaseStatMod.ModTypes.Add:
		times_label.hide()
	elif mod_type == BaseStatMod.ModTypes.Scale:
		plus_label.hide()
	elif mod_type == BaseStatMod.ModTypes.Set:
		plus_label.hide()
		times_label.text = " = "
	elif mod_type == BaseStatMod.ModTypes.ScaleStat:
		plus_label.text = " = "
	#elif mod_type == BaseStatMod.ModTypes.AddStat:
