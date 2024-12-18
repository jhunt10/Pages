class_name SaveLoadHandler

const SAVE_DAYA_PATH = "res://saves/"

static func read_saves_meta_data()->Dictionary:
	var meta_file_path = SAVE_DAYA_PATH.path_join("saves.json")
	var file = FileAccess.open(meta_file_path, FileAccess.READ)
	var text:String = file.get_as_text()
	
	var saves_dic:Dictionary = JSON.parse_string(text)
	if saves_dic:
		return saves_dic
	return {}

static func write_save_data(save_name:String, story_state):
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

static func _build_save_meta_data(save_name:String, story_state):
	return {
		"SaveDate": Time.get_datetime_string_from_system(false, true),
		"PlayTime": "00:00:00"
	}
