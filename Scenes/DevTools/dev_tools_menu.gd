class_name  DevToolsMenu
extends Control

@export var close_button:Button
@export var reload_stuff_button:Button
@export var create_page_items_button:Button
@export var items_to_inventory_button:Button
@export var add_item_menu_button:Button

@export var add_item_menu:AddItemMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_button.pressed.connect(close_menu)
	create_page_items_button.pressed.connect(do_the_thing)
	items_to_inventory_button.pressed.connect(items_to_inventory)
	add_item_menu_button.pressed.connect(add_item_menu.show)
	reload_stuff_button.pressed.connect(reload_stuff)
	if CombatRootControl.Instance:
		CombatRootControl.Instance.camera.freeze = true
	pass # Replace with function body.

func close_menu():
	self.queue_free()
	if CombatRootControl.Instance:
		CombatRootControl.Instance.camera.freeze = false
	MainRootNode.Instance.dev_tools_menu = null

func reload_stuff():
	#SpriteCache._cached_sprites.clear()
	#ActionLibrary.Instance.reload()
	ActorLibrary.Instance.reload()
	if EffectLibrary.Instance:
		EffectLibrary.Instance.reload()
	ItemLibrary.Instance.reload()
	VfxLibrary.reload_vfxs()

func do_the_thing():
	# Create weapons in inventory
	var items = ["BigMalma", "OldSword", "OldDagger", "BlackJack", "OldShield"]
	var requested = 1
	for item_key in items:
		if PlayerInventory.get_item_stack_count(item_key) < requested:
			PlayerInventory.spawn_item(item_key, requested)

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
			"#ObjDetails":{
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
			
