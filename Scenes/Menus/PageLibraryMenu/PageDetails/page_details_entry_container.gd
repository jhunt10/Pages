@tool
class_name PageDetailsEntryContainer
extends BaseObjectDetailsEntryContainer

@export var target_details_container:BoxContainer
@export var target_type_label:Label
@export var mini_range_display:MiniRangeDisplay

@export var acc_pot_container:BoxContainer
@export var accuracy_label:Label
@export var potency_label:Label
@export var effects_label:Label

@export var ammo_label:BoxContainer
@export var damage_entries_container:VBoxContainer

var page:BasePageItem:
	get:
		return thing_inst as BasePageItem

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	pass

## Load the top level details displayed while entry is minimized
func _load_mini_details():
	
	title_label.text = page.details.display_name
	if title_label.text == "":
		title_label.text = "["+page._key+"}"
	thing_tags = page.get_item_tags()
	tags_label.text = ", ".join(thing_tags)
	
	# Set Icon (validate rareaty
	var type_str = page.item_details.get("Rarity", null)
	if type_str and BaseItem.ItemRarity.keys().has(type_str):
		icon_background.texture = page.get_rarity_background()
	icon.texture = page.get_large_icon()
	
	if thing_tags.has("Title"):
		type_label.text = "Title"
	elif page.is_passive_page():
		type_label.text = "Passive"
	elif page.get_action() != null:
		type_label.text = "Action"
	else:
		type_label.text = "Unknown"

## Load full details displayed when entry is exspanded
func _load_full_details():
	var page_action = page.get_action()
	var page_effect_def = page.get_effect_def()
	description_box.set_page_item(page)
	# Ammo
	if page_action and page_action.has_ammo(null):
		ammo_label.set_data(page_action.get_ammo_data(null))
		ammo_label.show()
	else:
		ammo_label.hide()
	
	if page_action:
		var attack_details = page_action.get_load_val("AttackDetails", {})
		accuracy_label.text = str(attack_details.get("AccuracyMod", 1))
		potency_label.text = str(attack_details.get("PotencyMod", 1))
		var effects_datas = page_action.get_load_val("EffectDatas", {})
		if effects_datas.size() == 0:
			effects_label.text = ''
		else:
			var effects_string = ': '
			for effect_data in effects_datas.values():
				var effect_key = effect_data.get("EffectKey", "NO_KEY")
				effects_string += effect_key + ", "
			effects_label.text = effects_string.trim_suffix(", ")
		
		var target_params = page_action.get_preview_target_params(null)
		if target_params:
			target_type_label.text = TargetParameters.TargetTypes.keys()[target_params.target_type]
			mini_range_display.load_area_matrix(target_params.target_area)
			mini_range_display.show()
		else:
			target_details_container.hide()
	else:
		acc_pot_container.hide()
		target_details_container.hide()
	
	# Damage Data
	for child in damage_entries_container.get_children():
		if child is DamageLabelContainer:
			damage_font_size_override = child.font_size_override
		child.queue_free()
	var damage_datas = {}
	if page_action:
		damage_datas = page_action.get_load_val("DamageDatas", {})
	elif page_effect_def:
		damage_datas = page_effect_def.get("DamageDatas", {})
	for damage_data in damage_datas.values():
		var new_damage_label:DamageLabelContainer = load("res://Scenes/UiNodes/DamageLabelContainer/damage_label_container.tscn").instantiate()
		new_damage_label.set_damage_data(damage_data)
		damage_entries_container.add_child(new_damage_label)
		new_damage_label.font_size_override = damage_font_size_override
		
	# Stat Mods
	var stat_mods = page.get_passive_stat_mods()
	for child in stat_mods_container.get_children():
		child.queue_free()
	if page_effect_def:
		stat_mods = page_effect_def.get("StatMods", {})
	if stat_mods is Dictionary:
		stat_mods = stat_mods.values()
	for mod_data in stat_mods:
		var new_mod:StatModLabelContainer = premade_stat_mod_label.duplicate()
		new_mod.set_mod_data(mod_data)
		stat_mods_container.add_child(new_mod)
		new_mod.show()
	loaded_details = true
	
