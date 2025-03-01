extends Control

@export var tag_filter:LoadedOptionButton
@export var page_entries_container:VBoxContainer
@export var premade_page_entry:PageDetailsEntryContainer
@export var premade_entry_group:EntryGroupContainer

var known_tags = []
var page_entries = {}
var entry_groups = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tag_filter.get_options_func = get_tags
	tag_filter.item_selected.connect(on_tag_filter_selected)
	premade_page_entry.hide()
	premade_entry_group.hide()
	
	
	for page:BasePageItem in get_page_items():
		var load_path = page.get_load_path()
		if not entry_groups.keys().has(load_path):
			var new_group = premade_entry_group.duplicate()
			new_group.title_label.text = load_path
			new_group.show()
			page_entries_container.add_child(new_group)
			entry_groups[load_path] = new_group
		var new_entry:PageDetailsEntryContainer = premade_page_entry.duplicate()
		new_entry.set_page(page)
		entry_groups[load_path].add_entry(new_entry)
		new_entry.show()
		page_entries[page.ItemKey] = new_entry

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
	return pages
