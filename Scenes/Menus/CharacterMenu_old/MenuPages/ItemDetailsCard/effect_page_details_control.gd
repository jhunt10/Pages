class_name EffectPageDetailsControl
extends BoxContainer

@export var parent_card_control:ItemDetailsCard
@export var description_box:DescriptionBox
@export var stat_mods_container:Container
@export var premade_stat_mod_label:StatModLabelContainer

var _item:BasePageItem
var _actor:BaseActor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	premade_stat_mod_label.hide()

func set_action(actor:BaseActor, page:BasePageItem):
	_actor = actor
	_item = page
	for child in stat_mods_container.get_children():
		if child == premade_stat_mod_label:
			continue
		child.queue_free()
	var stat_mods = page.page_data.get("StatMods", {})
	for mod_data in stat_mods.values():
		var stat = mod_data.get("StatName")
		if not StatHelper.stat_icon_paths.keys().has(stat):
			continue
		if mod_data.get("DisplayName", "") == "Base Stats":
			continue
		var new_mod:StatModLabelContainer = premade_stat_mod_label.duplicate()
		new_mod.set_mod_data(mod_data)
		stat_mods_container.add_child(new_mod)
		new_mod.show()
	
	description_box.set_page_item(page)
	
