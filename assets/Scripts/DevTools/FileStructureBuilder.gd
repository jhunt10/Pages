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



static func scan_def_props():
	var files = []
	files.append_array(BaseLoadObjectLibrary._search_for_files("res://ObjectDefs/", "Defs.def"))
	var objs_to_props = {}
	for file:String in files:
		var file_name = file.get_file()
		var obj_type = get_def_class_type(file_name, files)
		if obj_type != "Actor":
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

static func rename_test_files():
	var dir_path = "C:\\Users\\johnn\\Documents\\Repos\\Pages\\ObjectDefs\\Items\\Equipment\\Weapons\\Sprites"
	var  files = BaseLoadObjectLibrary._search_for_files(dir_path, ".png")
	var dir : DirAccess = DirAccess.open(dir_path)
	for file:String in files:
		if file.contains(".png_Icon.png"):
			print("Renaming: " + file)
			var file_name = file.get_file()
			#if not file_name.ends_with("_WeaponSprite.png"):
				#file_name += "_Icon.png"
			#file_name = "Base"+file_name
			file_name = file_name.replace(".png_Icon.png", "_Icon.png")
			dir.rename(file, dir_path.path_join(file_name))
	

static func parse_def_file(file_path)->Dictionary:
	var file = FileAccess.open(file_path, FileAccess.READ)
	var text:String = file.get_as_text()
	var data = JSON.parse_string(text)
	return data

static func get_common_props_in_files():
	var files = []
	files.append_array(BaseLoadObjectLibrary._search_for_files("res://ObjectDefs/", "PageDefs.def"))
	var common_def = {}
	var keys = []
	for file:String in files:
		var defs = parse_def_file(file)
		for def_key:String in defs.keys():
			keys.append(def_key)
			var def_props = _rec_dic_to_keys(defs[def_key])
			deep_merge_dicts(common_def, def_props)
	print(common_def)
	#print(keys)
			

static var known_keyed_dictionary_suffixes:Array:
	get:
		return [
			"SubActions",
			"Datas",
			"Mods",
			"Params"
		]

## Return a nested Dictionary of Key to Property Type 
static func _rec_dic_to_keys(dict:Dictionary):
	var out_dict = {}
	for key:String in dict.keys():
		var val = dict[key]
		if val is Dictionary:
			# Check if it's something with distinct keys like "StatMods":{"AtkMod":{}, "DefMod":{}}
			var is_sub_dict = false
			for sufix in known_keyed_dictionary_suffixes:
				if key.ends_with(sufix):
					is_sub_dict = true
				
			if is_sub_dict:
				var merged_sub_dict = {}
				for sub_key in val.keys():
					var sub_dict = val[sub_key]
					var sub_dict_props = _rec_dic_to_keys(sub_dict)
					deep_merge_dicts(merged_sub_dict, sub_dict_props)
				var false_key = "#"+key+"_KEY"
				var val_dict = {}
				val_dict[false_key] = merged_sub_dict
				out_dict[key] = val_dict
			else:
				out_dict[key] = _rec_dic_to_keys(val)
		else:
			out_dict[key] = type_string(typeof(val))
	return out_dict

static func deep_merge_dicts(main:Dictionary, other:Dictionary):
	for key:String in other.keys():
		var val = other[key]
		if not main.keys().has(key):
			main[key] = val
		else: # Main has Key
			if val is Dictionary:
				deep_merge_dicts(main[key], val)




static func DoThing():
	print("\nSanity Check")
	#update_def_files()
	#get_common_props_in_files()
	#create_class_def_files("Rogue")
	rename_test_files()







const DefVersion = "1"

# Throw stuff in here to be printed after the update (or while deving update)
static var print_data_cache:Dictionary = {}

# Dynamic Func for applying update_def(..)
static func update_def_files():
	var files = []
	
################### UPDATE ME ############################
	SAVE_DEF_UPDATE = true
	files.append_array(BaseLoadObjectLibrary._search_for_files("res://ObjectDefs/", "_PageDefs.def"))
##########################################################
	
	
	if SAVE_DEF_UPDATE:
		print("\n Updating Files:")
	else:
		print("\n (NOT) Updating Files:")
	print_data_cache.clear()
	for file:String in files:
		update_def_file(file)
	print(print_data_cache)

# Dynamic Func for applying update_def(..)
static func update_def_file(file_path:String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var text:String = file.get_as_text()
	file.close()
	var new_defs = {}
	var old_defs:Dictionary = JSON.parse_string(text)
	
	if not should_update(file_path, old_defs):
		return
	var new_file_name = file_path.get_file()
	new_file_name = update_file_name(file_path, new_file_name, old_defs)
	#print(file_path)
	var path = file_path.get_base_dir()
	for old_def_key in old_defs.keys():
		var key_and_def = update_def(file_path, old_def_key, old_defs[old_def_key])
		var new_key = key_and_def[0]
		var new_def = key_and_def[1]
		if key_and_def.size() > 2:
			new_file_name = key_and_def[2]
		new_defs[new_key] = new_def
	var save_path = path.path_join(new_file_name)
	if SAVE_DEF_UPDATE:
		var save_file = FileAccess.open(save_path, FileAccess.WRITE)
		print("Saving File: " + save_path)
		save_file.store_string(JSON.stringify(new_defs))
		save_file.close()
		if save_path != file_path:
			print("Deleting File: " + file_path)
			DirAccess.remove_absolute(file_path)
	else:
		var old_file_name = file_path.get_file()
		if old_file_name != new_file_name:
			print(old_file_name + "\t>\t" +save_path)

static var SAVE_DEF_UPDATE = false


static func should_update(old_file_path:String, defs:Dictionary)->bool:
	var is_pages = false
	for def in defs.values():
		var object_script = def.get("!ObjectScript", "")
		if (object_script == "res://assets/Scripts/Items/Pages/PageItemAction.gd"
			or object_script == "res://assets/Scripts/Items/Pages/PageItemPassive.gd"):
				is_pages = true
	return is_pages

# Template
static func _update_def(file_path:String, def_key:String, def:Dictionary)->Array:
	var object_script = def.get("!ObjectScript", "")
	if not (object_script == "res://assets/Scripts/Items/Pages/PageItemAction.gd"
		or object_script == "res://assets/Scripts/Items/Pages/PageItemPassive.gd"):
			return [def_key, def]
	return [def_key, def]


static func update_file_name(old_file_path:String, old_file_name:String, defs:Dictionary)->String:
	return old_file_name
	#var base_file_name = old_file_name.replace("Pages", "").replace("_ItemDefs.def", "")
	#if old_file_path.contains("ClassDefs") and (base_file_name.ends_with("Passive") or base_file_name.ends_with("Action")):
		#base_file_name += "s"
	#return base_file_name + "_PageDefs.def"
		

# Rebasing Pages to BaseItem (not Equipment), moving EquipmentData under PageData
static func update_def(file_path:String, def_key:String, def:Dictionary)->Array:
	var object_script = def.get("!ObjectScript", "")
	if not (object_script == "res://assets/Scripts/Items/Pages/PageItemAction.gd"
		or object_script == "res://assets/Scripts/Items/Pages/PageItemPassive.gd"):
			print("Skipping " + def_key)
			return [def_key, def]
	
	var equipment_data = def.get("EquipmentData", {})
	if not print_data_cache.keys().has("EquipDataProps"):
		print_data_cache['EquipDataProps'] = []
	
	for key in equipment_data.keys():
		if not print_data_cache['EquipDataProps'].has(key):
			print_data_cache['EquipDataProps'].append(key)
	
	var page_data = def.get("PageData", {})
	if not print_data_cache.keys().has("PageDataProps"):
		print_data_cache['PageDataProps'] = []
	for key in page_data.keys():
		if not print_data_cache['PageDataProps'].has(key):
			print_data_cache['PageDataProps'].append(key)
	for prop_key in equipment_data.keys():
		page_data[prop_key] = equipment_data[prop_key]
	def.erase("EquipmentData")
	def.get("#ObjDetails", {}).get("Taxonomy", []).erase("Equipment")
	return [def_key, def]


static func update_def__old_taxonomy(file_path:String, def_key:String, def:Dictionary)->Array:
	var object_script = def.get("!ObjectScript", "")
	# [Actor, Effect, Item] 
	var object_type = ''
	var taxonomy = []
	match object_script:
		"res://assets/Scripts/Actors/BaseActor.gd":
			object_type = "Actor"
			taxonomy = ["Actor"]
			
		"res://assets/Scripts/Actors/Effects/BaseEffect.gd":
			object_type = "Effect"
			taxonomy = ["Effect"]
			
		"res://assets/Scripts/Items/BaseItem.gd":
			object_type = "Item"
			taxonomy = ["Item"]
			
		"res://assets/Scripts/Items/BagItems/BaseSupplyItem.gd":
			object_type = "Item"
			taxonomy = ["Item", "Supply"]
			
		"res://assets/Scripts/Items/BagItems/AmmoItem.gd":
			object_type = "Item"
			taxonomy = ["Item", "Supply", "Ammo"]
			
		"res://assets/Scripts/Items/BagItems/ConsumablePotion.gd":
			object_type = "Item"
			taxonomy = ["Item", "Supply", "Potion"]
			
		"res://assets/Scripts/Items/Equipment/BaseEquipmentItem.gd":
			object_type = "Item"
			taxonomy = ["Item", "Equipment"]
		"res://assets/Scripts/Items/Equipment/BaseArmorEquipment.gd":
			object_type = "Item"
			taxonomy = ["Item", "Equipment", "Armor"]
		"res://assets/Scripts/Items/Equipment/BaseBagEquipment.gd":
			object_type = "Item"
			taxonomy = ["Item", "Equipment", "Bag"]
		"res://assets/Scripts/Items/Equipment/BaseQueEquipment.gd":
			object_type = "Item"
			taxonomy = ["Item", "Equipment", "Book"]
		"res://assets/Scripts/Items/Equipment/Tools/BaseWeaponEquipment.gd":
			object_type = "Item"
			taxonomy = ["Item", "Equipment", "Weapon"]
		"res://assets/Scripts/Items/Pages/BasePageItem.gd":
			object_type = "Item"
			taxonomy = ["Item", "Equipment", "Page"]
		"res://assets/Scripts/Items/Pages/PageItemAction.gd":
			object_type = "Item"
			taxonomy = ["Item", "Equipment", "Page", "Action"]
		"res://assets/Scripts/Items/Pages/PageItemPassive.gd":
			object_type = "Item"
			taxonomy = ["Item", "Equipment", "Page", "Passive"]
			
	if file_path.ends_with("EffectDefs.def"):
		object_type = "Effect"
		taxonomy = ["Effect"]
		object_script = "res://assets/Scripts/Actors/Effects/BaseEffect.gd"
	if file_path.ends_with("ActorDefs.def"):
		object_type = "Actor"
		taxonomy = ["Actor"]
		object_script = "res://assets/Scripts/Actors/BaseActor.gd"
		
	if !object_script:
		printerr("Missing Object Srcipt on '%s'>'%s' : %s" % [def_key, file_path])
	if !object_type or taxonomy.size() == 0:
		printerr("Unknown Script Type for '%s'>'%s': %s : %s" % [def_key, object_script, file_path])
	var object_details = def.get("#ObjDetails", {})
	
	
	if object_details.get("Tags", []).has("Title"):
		taxonomy = ["Item", "Equipment", "Page", "Title"]
	
	
	object_details["ObjectType"] = object_type
	object_details["Taxonomy"] = taxonomy
	if not def.has("!ObjectScript"):
		def["!ObjectScript"] = object_script
	if def.has("ItemDetails"):
		def['ItemData'] = def['ItemDetails']
		def.erase("ItemDetails")
	def.erase('#ObjectDetails')
	
	if taxonomy.has("Page"):
		var title = ''
		if file_path.contains("ClassDefs/Mage/"):
			title = "Mage"
		elif file_path.contains("ClassDefs/Priest/"):
			title = "Priest"
		elif file_path.contains("ClassDefs/Rogue/"):
			title = "Rogue"
		elif file_path.contains("ClassDefs/Soldier/"):
			title = "Soldier"
		
		var title_req = 'None'
		if title:
			title_req = 'Match'
		
		if def_key.ends_with("TitlePage"):
			title = def_key.trim_suffix("TitlePage")
			title_req = "None"
		var page_data = {
			"SourceTitle": title,
			"Requirments": {
				# [ None | Same | Inherate | Shared ]
				"TitleReq": title_req,
				"IncompatiblePages": [],
				"ConflictingPages": []
			}
		}
		def['PageData'] = page_data
	
	#print(def_key)
	return [def_key, def]


# First update function
static func update_def_json_file(object_type:String, file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var text:String = file.get_as_text()
	file.close()
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
	#DirAccess.remove_absolute(file_path)
