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
	if !Instance: Instance = ItemLibrary.new()
	return Instance._object_defs.keys()

static func list_all_items()->Array:
	if !Instance: Instance = ItemLibrary.new()
	return Instance._loaded_objects.values()

static func get_item_def(key:String)->Dictionary:
	if !Instance: Instance = ItemLibrary.new()
	return Instance.get_object_def(key)
	
static func get_item(item_id:String, error_if_null:bool=true)->BaseItem:
	if !Instance: Instance = ItemLibrary.new()
	var item = Instance.get_object(item_id)
	if !item and error_if_null:
		printerr("ItemLibrary.get_item: No item found with id '%s'." % [item_id])
	return item

static func get_or_create_item(item_id:String, item_key:String, data:Dictionary)->BaseItem:
	if !Instance: Instance = ItemLibrary.new()
	var item = Instance.get_item(item_id, false)
	if item:
		return item
	return create_item(item_key, data, item_id)
	
static func create_item(key:String, data:Dictionary, force_id:String='')->BaseItem:
	if !Instance: Instance = ItemLibrary.new()
	var item = Instance.create_object(key, force_id, data)
	if !item:
		printerr("ItemLibrary.create_item: Failed to make item '%s'." % [key])
	return item


static func purge_items():
	if !Instance: Instance = ItemLibrary.new()
	Instance.purge_objects()
	
static func delete_item(item:BaseItem):
	if !Instance: Instance = ItemLibrary.new()
	if !item.is_deleted:
		item.on_delete()
	Instance.erase_object(item.Id)

static func load_items(data:Dictionary):
	if !Instance: Instance = ItemLibrary.new()
	Instance._load_objects_saved_data(data)


## Returns a string explaining why object is invalid, otherwise ''
static func validate_object(object:BaseLoadObject)->String:
	var reason = super(object)
	if object is BasePageItem:
		var action_key = object.get_action_key()
		if action_key:
			if not ActionLibrary.Instance._object_defs.has(action_key):
				reason = "No Action found with key '%s'." % [action_key]
	return reason
