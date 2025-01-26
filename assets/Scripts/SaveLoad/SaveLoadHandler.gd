class_name SaveLoadHandler

const SAVE_DATA_PATH = "user://saves/"

static var last_save_id:String

static func read_saves_meta_data()->Dictionary:
	var meta_file_path = SAVE_DATA_PATH.path_join("saves.json")
	var file = FileAccess.open(meta_file_path, FileAccess.READ)
	if !file:
		return {}
	var text:String = file.get_as_text()
	var parsed_object = JSON.parse_string(text)
	if parsed_object and parsed_object is Dictionary:
		return parsed_object
	return {}

static func read_save_data(save_id:String)->Dictionary:
	var meta_file_path = SAVE_DATA_PATH.path_join(save_id.replace(":", "_")+".json")
	var file = FileAccess.open(meta_file_path, FileAccess.READ)
	var text:String = file.get_as_text()
	var parsed_object = JSON.parse_string(text)
	if parsed_object and parsed_object is Dictionary:
		return parsed_object
	return {}

## Write save data keyed off Save Name. If a save with the same name exists. it will be overwritten.
static func write_save_data(save_name:String):
	var save_id = str(ResourceUID.create_id())
	var new_meta_data = _build_save_meta_data(save_name)
	var saves_dic = read_saves_meta_data()
	if saves_dic.keys().has(save_name):
		save_id = saves_dic[save_name]['SaveId']
		
	if !FileAccess.file_exists(SAVE_DATA_PATH):
		DirAccess.make_dir_recursive_absolute(SAVE_DATA_PATH)
		
	new_meta_data['SaveId'] = save_id
	saves_dic[save_name] = new_meta_data
	
	var save_file_path = SAVE_DATA_PATH.path_join(save_id+".json")
	var save_file = FileAccess.open(save_file_path, FileAccess.WRITE)
	var save_data = StoryState.build_save_data()
	save_file.store_string(JSON.stringify(save_data))
	
	# Save Meta Data
	var meta_file_path = SAVE_DATA_PATH.path_join("saves.json")
	var meta_file = FileAccess.open(meta_file_path, FileAccess.WRITE)
	meta_file.store_string(JSON.stringify(saves_dic))
	StoryState.save_id = save_id

static func _build_save_meta_data(save_name:String):
	var player_actor:BaseActor = StoryState.get_player_actor()
	return {
		"StoryId": StoryState.story_id,
		"SaveName": save_name,
		"SaveDate": Time.get_datetime_string_from_system(false, true),
		"RunTime": Time.get_time_string_from_unix_time(StoryState.get_runtime_untix_time()),
		"Location": "NEW SAVE",
		"Party":{player_actor.details.display_name: player_actor.stats.level}
	}

static func load_save_data(save_id:String, go_to_camp:bool=true):
	var data = read_save_data(save_id)
	StoryState.load_save_data(data)
	if go_to_camp:
		MainRootNode.Instance.open_camp_menu()
	
