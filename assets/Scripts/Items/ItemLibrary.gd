class_name ItemLibrary
extends BaseLoadObjectLibrary

## All Libraries should be static, but static override methods can't be called by BaseLoadObjectLibrary.
## So this is the work around.
static var Instance:ItemLibrary

func get_object_name()->String:
	return 'Item'
func get_object_key_name()->String:
	return "ItemKey"
func get_def_file_sufix()->String:
	return "_ItemDefs.json"
func get_data_file_sufix()->String:
	return "_ItemSave.json"
func get_object_script_path(object_def:Dictionary)->String:
	var script = super(object_def)
	if script != '':
		return script
	return "res://assets/Scripts/Items/BaseItem.gd"

func _init() -> void:
	if Instance != null:
		printerr("Multiple ItemLibrarys created.")
		return
	Instance = self
	Instance.init_load()

static func list_all_item_keys()->Array:
	return Instance._object_defs.keys()

static func list_all_items()->Array:
	return Instance._loaded_objects.values()

static func get_item_def(key:String)->Dictionary:
	return Instance.get_object_def(key)
	
static func get_item(item_id:String)->BaseItem:
	var item = Instance.get_object(item_id)
	if !item:
		printerr("ItemLibrary.get_item: No item found with id '%s'." % [item_id])
	return item

static func create_item(key:String, data:Dictionary)->BaseItem:
	var item = Instance.create_object(key, '', data)
	if !item:
		printerr("ItemLibrary.create_item: Failed to make item '%s'." % [key])
	return item

static func save_items():
	var data = {}
	data["PlayerInventory"] = PlayerInventory.list_all_held_item_ids()
	Instance.save_objects_data("res://saves/Items/_TestItem_ItemSave.json", data)

func _after_loading_saved_objects(saved_data:Dictionary):
	var player_invetory = saved_data.get("PlayerInventory", [])
	for id in player_invetory:
		var item = get_item(id)
		if item:
			PlayerInventory.add_item(item)
