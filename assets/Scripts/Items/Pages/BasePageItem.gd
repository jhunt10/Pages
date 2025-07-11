class_name BasePageItem
extends BaseItem

var page_data:Dictionary:
	get:
		return get_load_val("PageData", {})

func get_item_type()->ItemTypes:
	return ItemTypes.Page

func _init(key:String, def_load_path:String, def:Dictionary, id:String='', data:Dictionary={}) -> void:
	super(key, def_load_path, def, id, data)

## Returns what sub data has Mods
func get_data_containing_mods()->Dictionary:
	return page_data

func get_tags()->Array:
	var tags = []
	tags = super()
	if not tags.has("Page"):
		tags.append("Page")
	var source_title = page_data.get("SourceTitle", '')
	if source_title and not tags.has(source_title+"Page"):
		tags.append(source_title+"Page")
	return tags

func has_spite_sheet()->bool:
	return page_data.get("SpriteData", {}).has('SpriteSheet')
func get_sprite_sheet_file_path():
	var file_name = page_data.get("SpriteData", {}).get('SpriteSheet', null)
	if !file_name:
		return null
	return _def_load_path.path_join(file_name)

func get_source_title()->String:
	return page_data.get("SourceTitle", '')

func is_shareble()->bool:
	var requirment_data = page_data.get("PageRequirements", {})
	var title_req = requirment_data.get("TitleReq", '')
	return title_req == "Shared"

func get_tags_added_to_actor()->Array:
	return page_data.get("AddTags", [])

func get_extra_page_slots()->Dictionary:
	return page_data.get("ExtraPageSlots", {})

## Returns a diction of failed requirements, mapped by requirment type 
func get_cant_use_reasons(actor:BaseActor):
	var requirment_data = page_data.get("PageRequirements", {})
	var missing_requirements = super(actor)
	
	var title_req = requirment_data.get("TitleReq", '')
	var source_title = page_data.get("SourceTitle", '')
	if source_title != '' and title_req != 'None':
		match title_req:
			"Match":
				if actor.get_title() != source_title:
					if not missing_requirements.has("Title"):
						missing_requirements['Title'] = []
					missing_requirements['Title'].append("Match:"+source_title)
			"Inherit":
				if !actor.get_tags().has(source_title):
					if not missing_requirements.has("Title"):
						missing_requirements['Title'] = []
					missing_requirements['Title'].append("Inherit:"+source_title)
			"Shared":
				if actor.get_title() == source_title:
					if not missing_requirements.has("Title"):
						missing_requirements['Title'] = []
					missing_requirements['Title'].append("Shared:"+source_title)
				
		
	
	# Conflicting pages are not allowed to be used together
	for other_page_key in requirment_data.get("ConflictingPages", []):
		if actor.pages.has_item(other_page_key):
			if not missing_requirements.has("Conflict"):
				missing_requirements['Conflict'] = []
			missing_requirements['Conflict'].append(other_page_key)
	
	# Incompatible pages will break if both used together
	for other_page_key in requirment_data.get("IncompatiblePages", []):
		if actor.pages.has_item(other_page_key):
			if not missing_requirements.has("Conflict"):
				missing_requirements['Conflict'] = []
			missing_requirements['Conflict'].append(other_page_key)
	
	return missing_requirements
			
