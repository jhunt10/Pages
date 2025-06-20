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
		
		#def_file_path = main_dir_path.path_join(thing_name + "ActionPages_ItemDefs.json")
		#def_file = FileAccess.open(def_file_path, FileAccess.WRITE)
		#def_file.store_string("[\n\n]")
		#def_file.close()
		
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
	print("\nWait.")
	print("\nWait..")
	print("\nWait...")
	print("\nGo")
	update_def_files()
	#scan_def_props()
	#create_class_def_files("Rogue")

static func get_def_class_type(file_name, other_files)->String:
	var obj_type = ''
	if file_name.contains("_ActorDefs."):
		obj_type = "Actor"
	elif file_name.contains("_EffectDefs."):
		obj_type = "Effect"
	elif file_name.contains("_ActionDefs."):
		obj_type = "Action"
	elif file_name.contains("_ItemDefs."):
		var would_be_action_name = file_name.replace("ItemDefs", "ActionDefs")
		var match_actions =  ''
		for f:String in other_files:
			if f.get_file() == would_be_action_name:
				match_actions = f
				break
		if match_actions != '' or file_name.contains("PassivePages"):
			obj_type = 'Page'
		else: 
			obj_type = 'Item'
	return obj_type

static func update_def_files():
	var files = []
	print("\n Updating Files:")
	files.append_array(BaseLoadObjectLibrary._search_for_files("res://ObjectDefs/", "Defs.json"))
	#files.append_array(BaseLoadObjectLibrary._search_for_files("res://defs/", "Defs.json"))
	#files.append_array(BaseLoadObjectLibrary._search_for_files("res://data/", "Defs.json"))
	for file:String in files:
		var file_name = file.get_file()
		if file_name.contains("ActionPages_ItemDefs.json"):
			continue
		var obj_type = get_def_class_type(file_name, files)
		print("%s \t|\tFileName: %s" % [obj_type, file_name])
		update_def_file(obj_type, file)
		#break
static func scan_def_props():
	var files = []
	files.append_array(BaseLoadObjectLibrary._search_for_files("res://ObjectDefs/", "Defs.def"))
	var objs_to_props = {}
	for file:String in files:
		var file_name = file.get_file()
		var obj_type = get_def_class_type(file_name, files)
		if obj_type == "Actor":
			continue
		if not objs_to_props.has(obj_type):
			objs_to_props[obj_type] = {}
		for new_prop in scan_props(file):
			if not objs_to_props[obj_type].has(new_prop):
				objs_to_props[obj_type][new_prop] = []
			objs_to_props[obj_type][new_prop].append(file_name)
	for key in objs_to_props.keys():
		print("\n"+key)
		for val in objs_to_props[key].keys():
			print(val + ": " + str(objs_to_props[key][val].size()))
	print(objs_to_props)

const DefVersion = "1"

static func update_def_file(object_type:String, file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var text:String = file.get_as_text()
	
	#var backup_file_path = file_path.replace(".json", "_backup.json")
	#var backup_file = FileAccess.open(backup_file_path, FileAccess.WRITE)
	#backup_file.store_string(text)
	#backup_file.close()
	
	var object_key_name = ''
	if object_type == 'Action':
		object_key_name = 'ActionKey'
	elif object_type == 'Actor':
		object_key_name = 'ActorKey'
	elif object_type == 'Effect':
		object_key_name = 'EffectKey'
	elif object_type == 'Page':
		object_key_name = 'ItemKey'
	elif object_type == 'Item':
		object_key_name = 'ItemKey'
	else:
		printerr("Unknown Object Type: " + object_type)
	
	
	var old_defs = {}
	if text.begins_with("["):
		var index = 0
		var old_arr:Array = JSON.parse_string(text)
		for val:Dictionary in old_arr:
			var key = val.get(object_key_name, '')
			if key == '':
				printerr("Failed to find '%s' on a def in %s." % [key, file_path])
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
		if object_type == 'Action':
			new_def["ActionData"] = {}
			old_def["_ObjectScript"] = "res://assets/Scripts/Items/Pages/PageItemAction.gd"
		if object_type == 'Page':
			old_def["_ObjectScript"] = "res://assets/Scripts/Items/Pages/PageItemPassive.gd"
		for prop_key in old_def.keys():
			var new_prop_key = prop_key
			## Skip old "ActionKey"
			if prop_key == object_key_name:
				continue
			if prop_key == "CanStack":
				continue
			if prop_key == "CostData":
				continue
			
			if prop_key == "ParentKey":
				new_prop_key = "!ParentKey"
			if prop_key == "Details":
				new_prop_key = "#ObjDetails"
			if prop_key == "_ObjectScript":
				new_prop_key = "!ObjectScript"
			
			if prop_key == "WeaponDetails":
				new_prop_key = "WeaponData"
			if prop_key == "EquipmentDetails":
				new_prop_key = "EquipmentData"
			if prop_key == "PageDetails":
				new_prop_key = "PageData"
			
			if prop_key == "TargetParameters":
				old_def[prop_key].erase("EffectsAllies")
				old_def[prop_key].erase("EffectsEnemies")
				
			
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
						subact.erase("SubActionScript")
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
		
		if object_type == "Action":
			if new_def.keys().has("UseEquipmentIcon"):
				if not new_def.keys().has("Preview"):
					new_def['Preview'] = {}
				new_def['Preview']['UseEquipmentIcon'] = new_def['UseEquipmentIcon']
				new_def.erase("UseEquipmentIcon")
			if new_def.keys().has("UseDynamicIcons"):
				if not new_def.keys().has("Preview"):
					new_def['Preview'] = {}
				new_def['Preview']['UseDynamicIcons'] = new_def['UseDynamicIcons']
				new_def.erase("UseDynamicIcons")
			
			var move_props = ["AttackDetails", "AmmoData", "DamageDatas", "EffectDatas", "MissileDatas", "Preview", "SubActions", "TargetParams", "ZoneDatas"]
			var action_data = {}
			for prop in move_props:
				var val = new_def.get(prop, null)
				if val:
					action_data[prop] = val
				new_def.erase(prop)
			new_def['ActionData'] = action_data
		
			if not new_def.keys().has("ItemDetails"):
				new_def['ItemDetails'] = {
					"Rarity": "Common",
					"Value": 50
				}
			new_def['ItemDetails']['ItemType'] = "Page"
		
		elif object_type == "Page":
			if not new_def.keys().has("PassiveData"):
				new_def['PassiveData'] = {}
			if new_def.keys().has("EffectKey"):
				new_def['PassiveData']['EffectKey'] = new_def['EffectKey']
				new_def.erase("EffectKey")
			
			var move_props = ["Requirments", "StatMods", "TargetMods", "DamageMods", "AmmoMods", "AttackMods"]
			var page_data = new_def.get("PageData", {})
			for prop in move_props:
				var val = new_def.get(prop, null)
				if val and page_data.has(prop):
					print("Prop Match: %s -> %s | %s" % [prop, page_data[prop], val])
				if val:
					page_data[prop] = val
				new_def.erase(prop)
			new_def['EquipmentData'] = page_data
			if new_def.keys().has("PageData"):
				new_def.erase("PageData")
			new_def['ItemDetails']['ItemType'] = "Page"
		
		
		
		elif object_type == "Effect":
			var move_props = ["StatMods", "EffectDetails", "SubEffects", "AmmoMods", "AttackMods", "NestedEffectDatas", "ZoneDatas", "DamageDatas", "DamageMods"]
			var effect_data = {}
			for prop in move_props:
				var val = new_def.get(prop, null)
				if val:
					effect_data[prop] = val
				new_def.erase(prop)
			new_def['EffectData'] = effect_data
		elif new_def.has("BaseActionCount"):
			var move_props = ["BaseActionCount", "BasePassiveCount", "PagesPerRound"]
			var sub_data = {}
			for prop in move_props:
				var val = new_def.get(prop, null)
				if val:
					sub_data[prop] = val
				new_def.erase(prop)
			new_def['BookData'] = sub_data
		
		if new_def.keys().has("ItemSlotsData"):
			if not new_def.keys().has("EquipmentData"):
				new_def['EquipmentData'] = {}
			new_def['EquipmentData']['ItemSlotsData'] = new_def['ItemSlotsData']
			new_def.erase("ItemSlotsData")
		

		new_def['_DefVersion'] = DefVersion
		new_defs[key] = new_def
	var new_file_path = file_path.replace(".json", ".def")#.replace(".json", "_new.json")
	if object_type == "Action":
		new_file_path = new_file_path.replace("_ActionDefs", "_ItemDefs")
	#print("Writing to: " + new_file_path)
	var meta_file = FileAccess.open(new_file_path, FileAccess.WRITE)
	meta_file.store_string(JSON.stringify(new_defs))
	meta_file.close()

static func scan_props(file_path)->Array:
	var file = FileAccess.open(file_path, FileAccess.READ)
	var text:String = file.get_as_text()
	var data = JSON.parse_string(text)
	var out_list = []
	if data is Dictionary:
		data = data.values()
	for obj in data:
		if not obj is Dictionary:
			continue
		for key in obj.keys():
			if not out_list.has(key):
				out_list.append(key)
	return out_list
