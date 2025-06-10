class_name FileStructureBuilder


static func create_class_def_files(thing_name:String):
	var base_file_path = "res://ObjectDefs/ClassDefs/"
	var class_dir_path = base_file_path.path_join(thing_name)
	DirAccess.make_dir_absolute(class_dir_path)
	
	# Actors Dir
	if true:
		var main_dir_path = class_dir_path.path_join("Actors")
		DirAccess.make_dir_absolute(main_dir_path)
		var def_file_path = main_dir_path.path_join(thing_name + "Actors_ActorDefs.json")
		var def_file = FileAccess.open(def_file_path, FileAccess.WRITE)
		def_file.store_string("[\n\n]")
		def_file.close()
		var spites_dir_path = main_dir_path.path_join("Sprites")
		DirAccess.make_dir_absolute(spites_dir_path)
	
	# Pages Dir
	if true:
		var main_dir_path = class_dir_path.path_join("Pages")
		DirAccess.make_dir_absolute(main_dir_path)
		var def_file_path = main_dir_path.path_join(thing_name + "ActionPages_ActionDefs.json")
		var def_file = FileAccess.open(def_file_path, FileAccess.WRITE)
		def_file.store_string("[\n\n]")
		def_file.close()
		def_file_path = main_dir_path.path_join(thing_name + "ActionPages_ItemDefs.json")
		def_file = FileAccess.open(def_file_path, FileAccess.WRITE)
		def_file.store_string("[\n\n]")
		def_file.close()
		def_file_path = main_dir_path.path_join(thing_name + "PassivePages_ItemDefs.json")
		def_file = FileAccess.open(def_file_path, FileAccess.WRITE)
		def_file.store_string("[\n\n]")
		def_file.close()
		var spites_dir_path = main_dir_path.path_join("Sprites")
		DirAccess.make_dir_absolute(spites_dir_path)
	
	# Effects Dir (Under Pages so they can share Icons)
	if true:
		var main_dir_path = class_dir_path.path_join("Pages").path_join("Effects")
		DirAccess.make_dir_absolute(main_dir_path)
		var def_file_path = main_dir_path.path_join(thing_name + "PagesEffects_EffectDefs.json")
		var def_file = FileAccess.open(def_file_path, FileAccess.WRITE)
		def_file.store_string("[\n\n]")
		def_file.close()
		var spites_dir_path = main_dir_path.path_join("Sprites")
		DirAccess.make_dir_absolute(spites_dir_path)

	
	var items_dir_path = class_dir_path.path_join("Items")
	DirAccess.make_dir_absolute(items_dir_path)
	var supplies_dir_path = items_dir_path.path_join("Supplies")
	DirAccess.make_dir_absolute(supplies_dir_path)
	var equipment_dir_path = items_dir_path.path_join("Equipment")
	DirAccess.make_dir_absolute(equipment_dir_path)
	
	# Armor Dir
	if true:
		var main_dir_path = equipment_dir_path.path_join("Armor")
		DirAccess.make_dir_absolute(main_dir_path)
		var def_file_path = main_dir_path.path_join(thing_name + "Armor_ItemDefs.json")
		var def_file = FileAccess.open(def_file_path, FileAccess.WRITE)
		def_file.store_string("[\n\n]")
		def_file.close()
		var spites_dir_path = main_dir_path.path_join("Sprites")
		DirAccess.make_dir_absolute(spites_dir_path)
	
	# Weapons Dir
	if true:
		var main_dir_path = equipment_dir_path.path_join("Weapons")
		DirAccess.make_dir_absolute(main_dir_path)
		var def_file_path = main_dir_path.path_join(thing_name + "Weapons_ItemDefs.json")
		var def_file = FileAccess.open(def_file_path, FileAccess.WRITE)
		def_file.store_string("[\n\n]")
		def_file.close()
		var spites_dir_path = main_dir_path.path_join("Sprites")
		DirAccess.make_dir_absolute(spites_dir_path)
	
	# BooksBagsTrinkets Dir
	if true:
		var main_dir_path = equipment_dir_path.path_join("BooksBagsTrinkets")
		DirAccess.make_dir_absolute(main_dir_path)
		var def_file_path = main_dir_path.path_join(thing_name + "BooksBagsTrinkets_ItemDefs.json")
		var def_file = FileAccess.open(def_file_path, FileAccess.WRITE)
		def_file.store_string("[\n\n]")
		def_file.close()
		var spites_dir_path = main_dir_path.path_join("Sprites")
		DirAccess.make_dir_absolute(spites_dir_path)
		
static func DoThing():
	update_def_files()

static func update_def_files():
	var files = []
	files.append_array(BaseLoadObjectLibrary._search_for_files("res://ObjectDefs/", "Defs.json"))
	#files.append_array(BaseLoadObjectLibrary._search_for_files("res://defs/", "Defs.json"))
	#files.append_array(BaseLoadObjectLibrary._search_for_files("res://data/", "Defs.json"))
	for file:String in files:
		var file_name = file.get_file()
		print("FileName: " + file_name)
		#update_def_file("ActionKey", file)
		#break


static func update_def_file(object_key_name, file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var text:String = file.get_as_text()
	
	var backup_file_path = file_path.replace(".json", "_backup.json")
	var backup_file = FileAccess.open(backup_file_path, FileAccess.WRITE)
	backup_file.store_string(text)
	backup_file.close()
	
	var old_defs = {}
	if text.begins_with("["):
		var index = 0
		var old_arr:Array = JSON.parse_string(text)
		for val:Dictionary in old_arr:
			var key = val.get(object_key_name, '')
			if key == '':
				printerr("Failed to find '%s' on a def.")
				old_defs['NoKey' + str(index)] = val
				index += 1
			else:
				old_defs[key] = val
	
	# Order of Chars for Json Keys  !  #  $  %  &  (  )  *  +  ,  -  .  /  <  =  >  ?  @  ObjectName  _  |
	
	var new_defs = {}
	for key in old_defs.keys():
		var object_key = ''
		var old_def = old_defs[key].duplicate(true)
		var new_def = {}
		if old_def.keys().has("SubActions"):
			new_def["ActionDetails"] = {}
			new_def["_ObjectScript"] = "res://assets/Scripts/Actions/BaseAction.gd"
		for prop_key in old_def.keys():
			var new_prop_key = prop_key
			## Skip old "ActionKey"
			if prop_key == object_key_name:
				continue
			if prop_key == "ParentKey":
				new_prop_key = "!ParentKey"
			if prop_key == "Details":
				new_prop_key = "#ObjDetails"
			
			
			if prop_key == "SubActions":
				var old_subacts = old_def[prop_key]
				var new_subacts = {}
				for frame_index in range(24):
					var arr = old_subacts.get(str(frame_index), [])
					var sub_index = 0
					for subact in arr:
						var sub_act_script = subact.get("SubActionScript", "????")
						var tokens = sub_act_script.split("/")
						var new_key:String = tokens[tokens.size()-1]
						new_key = new_key.trim_prefix("SubAct_").trim_suffix(".gd")
						if new_subacts.keys().has(new_key):
							new_key = new_key + str(frame_index) + str(sub_index)
						#subact.erase("SubActionScript")
						new_subacts[new_key] = subact
						new_subacts[new_key]["!SubActionScript"] = sub_act_script
						new_subacts[new_key]["#FrameIndex"] = frame_index
						new_subacts[new_key]["#SubIndex"] = sub_index
						sub_index += 1
				new_def[prop_key] = new_subacts
				#print("SubActs: %s" % [new_subacts])
			else:
				#print("Not Sub Acts: %s" % [new_prop_key])
				new_def[new_prop_key] = old_def[prop_key]
		new_defs[key] = new_def
	var new_file_path = file_path#.replace(".json", "_new.json")
	print("Writing to: " + new_file_path)
	var meta_file = FileAccess.open(new_file_path, FileAccess.WRITE)
	meta_file.store_string(JSON.stringify(new_defs))
	meta_file.close()
