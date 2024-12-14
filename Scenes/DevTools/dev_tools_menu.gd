class_name  DevToolsMenu
extends Control

@export var close_button:Button
@export var create_page_items_button:Button
@export var items_to_inventory_button:Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_button.pressed.connect(close_menu)
	create_page_items_button.pressed.connect(create_page_items)
	items_to_inventory_button.pressed.connect(items_to_inventory)
	pass # Replace with function body.

func close_menu():
	self.queue_free()

func create_page_items():
	var file_dialog:FileDialog = FileDialog.new()
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.title = "Select Action Defs file"
	file_dialog.add_filter("*_ActionDefs.json")
	file_dialog.file_selected.connect(__create_page_items_actions_selected)
	self.add_child(file_dialog)
	file_dialog.popup_centered_ratio()
	file_dialog.show()
	pass

func __create_page_items_actions_selected(path:String):
	var action_keys = []
	
	var file = FileAccess.open(path, FileAccess.READ)
	var text:String = file.get_as_text()
	if !text.begins_with("["):
		text = "[" + text + "]" 
	var object_defs:Array = JSON.parse_string(text)
	for def:Dictionary in object_defs:
		var action_key = def.get("ActionKey")
		if not action_key:
			continue
		if not action_keys.has(action_key):
			action_keys.append(action_key)
	
	var new_data = []
	for action_key in action_keys:
		new_data.append({
			"ItemKey": action_key + "_Page",
			"_ObjectScript": "res://assets/Scripts/Items/Pages/BasePageItem.gd",
			"CanStack": true,
			"ActionKey": action_key,
			"Details":{
				"Tags": ["Tactic"]
			}
		})
	var new_path = path.replace("_ActionDefs.json", "_ItemDefs.json")
	var save_data_string = JSON.stringify(new_data)
	var file2 = FileAccess.open(new_path, FileAccess.WRITE)
	file2.store_string(save_data_string)
	file2.close()

func items_to_inventory():
	for item_key in ItemLibrary.list_all_item_keys():
		var new_item_id = item_key+"1"
		if not PlayerInventory.has_item_id(new_item_id):
			var new_item = ItemLibrary.get_or_create_item(new_item_id, item_key, {})
			if !new_item:
				printerr("DevTools.items_to_inventory: Failed to create item '%s'." % [new_item_id])
			else:
				PlayerInventory.add_item(new_item)
	ItemLibrary.save_items()
			
			
