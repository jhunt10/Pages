class_name SaveLoadHandler

const SAVE_DAYA_PATH = "res://saves/"

static func read_saves_meta_data()->Dictionary:
	var meta_file_path = SAVE_DAYA_PATH.path_join("saves.json")
	var file = FileAccess.open(meta_file_path, FileAccess.READ)
	var text:String = file.get_as_text()
	var parsed_object = JSON.parse_string(text)
	if parsed_object and parsed_object is Dictionary:
		return parsed_object
	return {}

static func read_save_data(save_id:String)->Dictionary:
	var meta_file_path = SAVE_DAYA_PATH.path_join(save_id.replace(":", "_")+".json")
	var file = FileAccess.open(meta_file_path, FileAccess.READ)
	var text:String = file.get_as_text()
	var parsed_object = JSON.parse_string(text)
	if parsed_object and parsed_object is Dictionary:
		return parsed_object
	return {}

static func write_save_data(save_name:String, story_state:StoryState):
	var new_meta_data = _build_save_meta_data(save_name, story_state)
	var saves_dic = read_saves_meta_data()
	if saves_dic.keys().has(save_name):
		# TODO: Override
		saves_dic.erase(save_name)
	saves_dic[save_name] = new_meta_data
	
	# Save Meta Data
	var meta_file_path = SAVE_DAYA_PATH.path_join("saves.json")
	var meta_file = FileAccess.open(meta_file_path, FileAccess.WRITE)
	meta_file.store_string(JSON.stringify(saves_dic))
	
	var save_file_path = SAVE_DAYA_PATH.path_join(story_state.Instance.story_id.replace(":", "_")+".json")
	var save_file = FileAccess.open(save_file_path, FileAccess.WRITE)
	var save_data = story_state.Instance.build_save_data()
	save_file.store_string(JSON.stringify(save_data))

static func _build_save_meta_data(save_name:String, story_state:StoryState):
	return {
		"StoryId": story_state.Instance.story_id,
		"SaveName": save_name,
		"SaveDate": Time.get_datetime_string_from_system(false, true),
		"PlayTime": "00:00:00",
		"Location": "NEW SAVE"
	}

static func load_save_data(save_id:String):
	var data = read_save_data(save_id)
	
	
