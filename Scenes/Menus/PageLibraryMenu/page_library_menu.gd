extends Control

@export var close_button:Button
@export var scale_slider:Slider
@export var loading_patch:NinePatchRect
@export var scroll_ocntainer:ScrollContainer
@export var tag_filter:LoadedOptionButton
@export var page_entries_container:VBoxContainer
@export var premade_page_entry:PageDetailsEntryContainer
@export var premade_entry_group:EntryGroupContainer

@export var load_time_label:Label

var _loading_entries_thread

var known_tags = []
var page_entries = {}
var entry_groups = {}
var loaded = false
var timer = 0
var starting_content_scale:float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_button.pressed.connect(self.queue_free)
	tag_filter.get_options_func = get_tags
	tag_filter.item_selected.connect(on_tag_filter_selected)
	premade_page_entry.hide()
	premade_entry_group.hide()
	scroll_ocntainer.hide()
	loading_patch.show()
	starting_content_scale = get_window().content_scale_factor
	get_window().content_scale_factor = 0.5
	#scale_slider.value_changed.connect(_on_scale_change)
	
#func _on_scale_change(val:float):
func _exit_tree() -> void:
	if starting_content_scale > 0:
		get_window().content_scale_factor = starting_content_scale

func build_page_entires():
	if loaded:
		return
	var page_entry_scene = load("res://Scenes/Menus/PageLibraryMenu/page_details_entry_container.tscn")
	for page:BasePageItem in get_page_items():
		var load_path = page.get_load_path()
		if not entry_groups.keys().has(load_path):
			var new_group = premade_entry_group.duplicate()
			new_group.title_label.text = load_path
			new_group.show()
			page_entries_container.add_child(new_group)
			entry_groups[load_path] = new_group
		var new_entry:PageDetailsEntryContainer = page_entry_scene.instantiate()
		#var new_entry:PageDetailsEntryContainer = premade_page_entry.duplicate()
		new_entry.set_page(page)
		entry_groups[load_path].add_entry(new_entry)
		new_entry.show()
		page_entries[page.ItemKey] = new_entry
	
	scroll_ocntainer.show()
	loading_patch.hide()
	loaded = true
	


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
	return known_tags

func on_tag_filter_selected(index:int):
	var tag = tag_filter.get_current_option_text()
	for entry:PageDetailsEntryContainer in page_entries.values():
		if tag == "All" or entry.page.get_item_tags().has(tag):
			entry.show()
		else:
			entry.hide()

func get_page_items()->Array:
	var pages = [] 
	for item_key:String in ItemLibrary.list_all_item_keys():
		if item_key.ends_with("_PageItem"):
			var page = ItemLibrary.get_or_create_item(item_key+"_STATIC", item_key, {})
			pages.append(page)
			for tag in page.get_item_tags():
				if not known_tags.has(tag):
					known_tags.append(tag)
	printerr("\n\nFound %s Pages Items\n\n" % [pages.size()])
	return pages
