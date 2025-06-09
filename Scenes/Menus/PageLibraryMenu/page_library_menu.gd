extends Control

@export var close_button:Button
@export var reload_pages_button:Button
@export var scale_slider:Slider
@export var loading_patch:NinePatchRect
@export var scroll_ocntainer:ScrollContainer
@export var tag_filter:LoadedOptionButton
@export var page_entries_container:VBoxContainer
@export var premade_entry_group:EntryGroupContainer
@export var example_page_entry:PageDetailsEntryContainer

@export var load_time_label:Label



@export var action_check_box:CheckBox
@export var actor_check_box:CheckBox
@export var effect_check_box:CheckBox
@export var item_check_box:CheckBox
var _loading_entries_thread

var known_tags = []
var page_entries = {}
var entry_groups = {}
var group_to_entry_keys:Dictionary = {}
var loaded = false
var timer = 0
var starting_content_scale:float
static var set_content_scale:float = 0.5
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_button.pressed.connect(self.queue_free)
	tag_filter.get_options_func = get_tags
	tag_filter.item_selected.connect(on_tag_filter_selected)
	example_page_entry.queue_free()
	premade_entry_group.hide()
	scroll_ocntainer.hide()
	loading_patch.show()
	reload_pages_button.pressed.connect(_reload_pages)
	
	action_check_box.pressed.connect(_on_cat_button_pressed)
	actor_check_box.pressed.connect(_on_cat_button_pressed)
	effect_check_box.pressed.connect(_on_cat_button_pressed)
	item_check_box.pressed.connect(_on_cat_button_pressed)
	
	starting_content_scale = get_window().content_scale_factor
	get_window().content_scale_factor = set_content_scale
	#scale_slider.value_changed.connect(_on_scale_change)
	
#func _on_scale_change(val:float):
func _exit_tree() -> void:
	if starting_content_scale > 0:
		get_window().content_scale_factor = starting_content_scale

func _reload_pages():
	#SpriteCache._cached_sprites.clear()
	ActionLibrary.Instance.reload()
	ItemLibrary.Instance.reload()
	loaded = false
	build_page_entires()

func build_page_entires():
	if loaded:
		return
	for entry in page_entries.values():
		entry.queue_free()
	page_entries.clear()
	
	var page_item_keys= []
	for page:BaseItem in get_page_items():
		var def = page._def
		var inst = page
		var load_path = page.get_load_path()
		page_item_keys.append(page.ItemKey)
		_build_object_entry(def, inst, load_path)
	for effect_key in EffectLibrary.list_all_effects_keys():
		var def = EffectLibrary.get_effect_def(effect_key)
		var inst = null
		var load_path = EffectLibrary.Instance.get_object_def_load_path(effect_key)
		_build_object_entry(def, inst, load_path)
	for actor_key in ActorLibrary.list_all_actor_keys():
		var def = ActorLibrary.get_actor_def(actor_key)
		var inst = null
		var load_path = ActorLibrary.Instance.get_object_def_load_path(actor_key)
		_build_object_entry(def, inst, load_path)
	for item_key in ItemLibrary.list_all_item_keys():
		if page_item_keys.has(item_key):
			continue
		var def = ItemLibrary.get_item_def(item_key)
		var inst = null
		var load_path = ItemLibrary.Instance.get_object_def_load_path(item_key)
		_build_object_entry(def, inst, load_path)
	
	scroll_ocntainer.show()
	loading_patch.hide()
	loaded = true

var entry_scenes:Dictionary = {}
func _get_object_entry_scene(object_type):
	if entry_scenes.has(object_type):
		return entry_scenes[object_type]
	if object_type == "Page":
		var entry_scene = load("res://Scenes/Menus/PageLibraryMenu/PageDetails/page_details_entry_container.tscn")
		entry_scenes["Page"] = entry_scene
		return entry_scene
	if object_type == "Effect":
		var entry_scene = load("res://Scenes/Menus/PageLibraryMenu/EffectDetails/effect_details_entry_container.tscn")
		entry_scenes["Effect"] = entry_scene
		return entry_scene
	if object_type == "Actor":
		var entry_scene = load("res://Scenes/Menus/PageLibraryMenu/ActorDetails/actor_details_entry_container.tscn")
		entry_scenes["Actor"] = entry_scene
		return entry_scene
	if object_type == "Item":
		var entry_scene = load("res://Scenes/Menus/PageLibraryMenu/ActorDetails/actor_details_entry_container.tscn")
		entry_scenes["Item"] = entry_scene
		return entry_scene

func _build_object_entry(obj_def:Dictionary, obj_inst:BaseLoadObject, load_path:String)->BaseObjectDetailsEntryContainer:
	if not entry_groups.keys().has(load_path):
		var new_group = premade_entry_group.duplicate()
		new_group.title_label.text = load_path
		new_group.show()
		page_entries_container.add_child(new_group)
		entry_groups[load_path] = new_group
		group_to_entry_keys[load_path] = []
	
	var entry_scene = null
	var key = ""
	if obj_def.has("ActorKey"):
		key = obj_def.get("ActorKey")
		entry_scene = _get_object_entry_scene("Actor")
	elif obj_inst is BasePageItem:
		key = obj_def.get("ItemKey")
		entry_scene = _get_object_entry_scene("Page")
	elif obj_def.has("ItemKey"):
		key = obj_def.get("ItemKey")
		entry_scene = _get_object_entry_scene("Item")
	elif obj_def.has("EffectKey"):
		key = obj_def.get("EffectKey")
		entry_scene = _get_object_entry_scene("Effect")
	
	if not entry_scene:
		return null
	var new_entry:BaseObjectDetailsEntryContainer = entry_scene.instantiate()
	new_entry.set_thing(obj_def, obj_inst, load_path)
	entry_groups[load_path].add_entry(new_entry)
	page_entries[key] = new_entry
	group_to_entry_keys[load_path].append(key)
	
	for tag in new_entry.thing_tags:
		if not known_tags.has(tag):
			known_tags.append(tag)
	return new_entry


# Called every frame. 'delta' is the elapsed time since the previous frame.
var first_pass = true
func _process(delta: float) -> void:
	if first_pass:
		first_pass = false
		printerr(str(delta))
	elif not loaded:
		var start_time = Time.get_unix_time_from_system()
		build_page_entires()
		var end_time = Time.get_unix_time_from_system()
		load_time_label.text = str(end_time - start_time)
	#if timer < 5:
		#timer += delta
	#if not loaded:
		#build_page_entires()
	pass


func get_tags()->Array:
	known_tags.sort()
	return known_tags


func on_tag_filter_selected(index:int):
	var tag = tag_filter.get_current_option_text()
	for entry:BaseObjectDetailsEntryContainer in page_entries.values():
		if tag == "All" or entry.thing_tags.has(tag):
			entry.show()
		else:
			entry.hide()


func _on_cat_button_pressed():
	for load_path in group_to_entry_keys.keys():
		var any_showing = false
		var entry_keys = group_to_entry_keys[load_path]
		for entry_key in entry_keys:
			var entry:BaseObjectDetailsEntryContainer = page_entries.get(entry_key)
			if not entry:
				continue
				
			if entry.thing_def.has("ActorKey"):
				if not actor_check_box.button_pressed:
					entry.hide()
					continue
			if entry.thing_def.get("ItemKey", "").ends_with("_PageItem"):
				if not action_check_box.button_pressed:
					entry.hide()
					continue
			elif entry.thing_def.has("ItemKey"):
				if not item_check_box.button_pressed:
					entry.hide()
					continue
			elif entry.thing_def.has("EffectKey"):
				if not effect_check_box.button_pressed:
					entry.hide()
					continue
			entry.show()
			any_showing = true
		if any_showing:
			entry_groups[load_path].show()
		else:
			entry_groups[load_path].hide()

func get_page_items()->Array:
	var pages = [] 
	for item_key:String in ItemLibrary.list_all_item_keys():
		if item_key.ends_with("_PageItem"):
			var page = ItemLibrary.get_or_create_item(item_key+"_STATIC", item_key, {})
			pages.append(page)
	printerr("\n\nFound %s Pages Items\n\n" % [pages.size()])
	return pages
