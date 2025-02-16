class_name ActorLibrary
extends BaseLoadObjectLibrary

## All Libraries should be static, but static override methods can't be called by BaseLoadObjectLibrary.
## So this is the work around.
static var Instance:ActorLibrary

func get_object_name()->String:
	return 'Actor'
func get_object_key_name()->String:
	return "ActorKey"
func get_def_file_sufix()->String:
	return "_ActorDefs.json"
func get_data_file_sufix()->String:
	return "_ActorSave.json"
func get_object_script_path(object_def:Dictionary)->String:
	return "res://assets/Scripts/Actors/BaseActor.gd"

const _default_corpse_texture_path = "res://assets/Sprites/Actors/DefaultCorpse.png"

func _init() -> void:
	if Instance != null:
		printerr("Multiple ActorLibrarys created.")
		return
	Instance = self
	Instance.init_load()

# Get a static instance of the action
static func get_actor_def(key:String)->Dictionary:
	if !Instance: Instance = ActorLibrary.new()
	return Instance.get_object_def(key)
	
static func get_actor(actor_id:String)->BaseActor:
	if !Instance: Instance = ActorLibrary.new()
	var actor = Instance.get_object(actor_id)
	if !actor:
		printerr("ActorLibrary.get_actor: No actor found with id '%s'." % [actor_id])
	return actor

static func get_or_create_actor(key:String, id:String)->BaseActor:
	if !Instance: Instance = ActorLibrary.new()
	if  Instance._loaded_objects.keys().has(id):
		return get_actor(id)
	return create_actor(key, {}, id)

static func create_actor(key:String, data:Dictionary, premade_id:String = '')->BaseActor:
	if !Instance: Instance = ActorLibrary.new()
	if  Instance._loaded_objects.keys().has(premade_id):
		return get_actor(premade_id)
	var actor:BaseActor = Instance.create_object(key, premade_id, data)
	if !actor:
		printerr("ActorLibrary.create_actor: Failed to make actor '%s'." % [key])
		return null
	actor.suppress_equipment_changed = true
	actor.equipment._build_slots_list()
	var equipment_list = actor.get_load_val("SpawnEquipmentArr", [])
	for equip in equipment_list:
		if equip == null:
			continue
		var item = ItemLibrary.create_item(equip, {})
		if item:
			if !actor.equipment.try_equip_item(item, false):
				printerr("ActorLibrary.create_actor: Failed to equip item '%s'." % [equip])
	
	var page_list = actor.get_load_val("SpawnPageArr", [])
	for page_key in page_list:
		var page = ItemLibrary.create_item(page_key + "_PageItem", {})
		if page:
			if !actor.pages.add_item_to_first_valid_slot(page):
				printerr("ActorLibrary.create_actor: Failed add Page '%s'." % [page_key])
	
	var item_list = actor.get_load_val("SpawnItemArr", [])
	for item_key in item_list:
		var item = ItemLibrary.create_item(item_key, {})
		if item:
			if !actor.items.add_item_to_first_valid_slot(item):
				printerr("ActorLibrary.create_actor: Failed add Item '%s'." % [item_key])
	
	actor.suppress_equipment_changed = false
	actor.equipment_changed.emit()
	return actor

#static func save_actors():
	#if !Instance: Instance = ActorLibrary.new()
	#Instance.save_objects_data("res://saves/Actors/_TestActor_ActorSave.json")

static func load_actors(data:Dictionary):
	if !Instance: Instance = ActorLibrary.new()
	Instance._load_objects_saved_data(data)

static func delete_actor(actor:BaseActor):
	if !Instance: Instance = ActorLibrary.new()
	Instance.erase_object(actor.Id)
	

static func purge_actors():
	if !Instance: Instance = ActorLibrary.new()
	Instance.purge_objects()

#func _search_for_actors(path:String, list:Array):
	#var dir = DirAccess.open(path)
	#if dir:
		#dir.list_dir_begin()
		#var file_name:String = dir.get_next()
		#while file_name != "":
			#var full_path = path+"/"+file_name
			#if dir.current_is_dir():
				#_search_for_actors(full_path, list)
			#elif file_name.ends_with(".json"):
				#list.append(full_path)
			#file_name = dir.get_next()
	#else:
		#print("An error occurred when trying to access the path.")
#
#func _load_actor_file(path:String):
	#var file = FileAccess.open(path, FileAccess.READ)
	#var text:String = file.get_as_text()
	#
	## Wrap in brackets to support multiple actions in same file
	#if !text.begins_with("["):
		#text = "[" + text + "]" 
		#
	#var actor_datas = JSON.parse_string(text)
	#for data in actor_datas:
		#data['LoadPath'] = path.get_base_dir()
		##_actors_data[data['ActorKey']] = data
		#print("Loaded Actor: " + data['ActorKey'])

#func create_page(keyName : String) -> PageAction:
	#var script = action_scripts[keyName]
	#var newObj = script.new(action_data[keyName])
	#return newObj
#
#func create_gap_action():
	#var dic = {KeyName:GapActionKeyName}
	#var gap = PageAction.new(dic)
	#return gap
#
#func get_image(key_name) -> Texture2D:
	#if loaded_sprites.has(key_name):
		#return loaded_sprites[key_name]
	#return missing_image
	
func get_default_corpse_texture()->Texture2D:
	return load(_default_corpse_texture_path)
