@tool
class_name BaseObjectDetailsEntryContainer
extends BackPatchContainer

@export var icon_background:TextureRect
@export var icon:TextureRect
@export var title_label:Label
@export var tags_label:Label
@export var type_label:Label


@export var details_container:BoxContainer
@export var description_box:DescriptionBox


@export var plus_minus_button:Button
@export var minus_icon:TextureRect
@export var plus_icon:TextureRect

@export var stat_mods_container:Container
@export var premade_stat_mod_label:HBoxContainer

@export var add_item_button:Button

var thing_inst
var thing_def:Dictionary
var thing_load_path:String
var thing_tags:Array
var damage_font_size_override:int
var loaded_details:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		return
	plus_icon.show()
	details_container.hide()
	premade_stat_mod_label.hide()
	plus_minus_button.pressed.connect(toggle_details)
	if not plus_minus_button.visible:
		plus_minus_button.show()
	if add_item_button:
		add_item_button.pressed.connect(_on_add_pressed)
	pass # Replace with function body.

func toggle_details():
	if details_container.visible:
		details_container.hide()
		plus_icon.show()
	else:
		#if not loaded_details:
		_load_full_details()
		details_container.show()
		plus_icon.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	pass

func set_thing(def:Dictionary, inst:BaseLoadObject, load_path:String):
	thing_def = def
	thing_inst = inst
	thing_load_path = load_path
	var details = thing_def.get("#ObjDetails", {"DisplayName": "#No Details#"})
	title_label.text = details.get("DisplayName", "["+def.get("EffectKey", "")+"]")
	thing_tags = details.get("Tags", [])
	tags_label.text = ", ".join(thing_tags)
	if def.has("ItemKey"):
		type_label.text = "Item"
	if def.has("ActorKey"):
		type_label.text = "Actor"
	
	if not _should_show_add_button():
		if add_item_button:
			add_item_button.hide()
	_load_mini_details()

func _should_show_add_button()->bool:
	return thing_def.has("ItemKey")

func _on_add_pressed():
	if thing_def.has("ItemKey"):
		var item_key = thing_def.get("ItemKey", "")
		var new_item = ItemLibrary.create_item(item_key, {})
		if not new_item:
			printerr("Failed to make new item: " + item_key)
			return
		PlayerInventory.add_item(new_item)

func _get_thing_key()->String:
	return ''

## Load the top level details displayed while entry is minimized
func _load_mini_details():
	var icon_path = thing_def.get("#ObjDetails", {}).get("LargeIcon", "")
	var icon_sprite = SpriteCache.get_sprite(thing_load_path.path_join(icon_path), false)
	icon.texture = icon_sprite
	
	var type_str = thing_def.get("ItemData", {}).get("Rarity", null)
	if type_str and BaseItem.ItemRarity.keys().has(type_str):
		icon_background.texture = ItemHelper.get_rarity_background(type_str)

## Load full details displayed when entry is exspanded
func _load_full_details():
	description_box.set_object(thing_def, thing_inst, null)
	loaded_details = true
	
