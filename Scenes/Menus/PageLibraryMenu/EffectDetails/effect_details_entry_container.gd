@tool
class_name EffectDetailsEntryContainer
extends BaseObjectDetailsEntryContainer

@export var good_effect_icon:Texture2D
@export var bad_effect_icon:Texture2D

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
	var effect_details = thing_def.get("EffectDetails", {})
	if effect_details.get("IsGood", false):
		icon_background.texture = good_effect_icon
	elif effect_details.get("IsBad", false):
		icon_background.texture = bad_effect_icon
	
	var icon_path = thing_def.get("#ObjDetails", {}).get("LargeIcon", "")
	var icon_sprite = SpriteCache.get_sprite(thing_load_path.path_join(icon_path), false)
	icon.texture = icon_sprite
	
	if not thing_tags.has("Effect"):
		thing_tags.append("Effect-NotTagged")
	if effect_details.has("LimitedEffectType"):
		type_label = thing_def.get("LimitedEffectType")
	elif thing_tags.has("Ailment"):
		type_label.text = "Ailment"
	else:
		type_label.text = "Effect"

## Load full details displayed when entry is exspanded
func _load_full_details():
	super()
	
	## Stat Mods
	#var stat_mods = page.get_passive_stat_mods()
	#if page_effect_def:
		#stat_mods = page_effect_def.get("StatMods", {})
	#for mod_data in stat_mods.values():
		#var new_mod:StatModLabelContainer = premade_stat_mod_label.duplicate()
		#new_mod.set_mod_data(mod_data)
		#stat_mods_container.add_child(new_mod)
		#new_mod.show()
	#loaded_details = true
	
