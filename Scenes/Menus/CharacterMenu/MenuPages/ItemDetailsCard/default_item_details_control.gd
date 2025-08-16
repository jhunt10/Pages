class_name DefaultItemDetailsControl
extends Control

@export var description_box:DescriptionBox
@export var stat_mods_container:Container
@export var premade_stat_mod_label:StatModLabelContainer

func set_item(item:BaseItem):
	if item:
		description_box.set_object(item._def, item, null)
	var stat_mods = item.get_stat_mod_datas()
	for mod_data in stat_mods.values():
		if mod_data.get("DisplayName", "") == "Base Stats":
			continue
		var new_mod:StatModLabelContainer = premade_stat_mod_label.duplicate()
		new_mod.set_mod_data(mod_data)
		stat_mods_container.add_child(new_mod)
	premade_stat_mod_label.hide()
	
