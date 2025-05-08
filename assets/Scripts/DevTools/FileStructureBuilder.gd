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
