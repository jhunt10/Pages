class_name GameVictoryScreen
extends Control

@export var camp_button:Button
@export var premade_pickup_page:HBoxContainer
@export var pickup_pages_container:VBoxContainer
@export var premade_pickup_item:HBoxContainer
@export var pickup_items_container:VBoxContainer

func _ready() -> void:
	premade_pickup_page.hide()
	premade_pickup_item.hide()
	camp_button.pressed.connect(_on_camp_button)

func show_game_result():
	collect_dropped_items()
	self.show()
	

func _on_camp_button():
	CombatRootControl.Instance.cleanup_combat()
	MainRootNode.Instance.open_camp_menu()

func collect_dropped_items():
	var items_datas = {}
	for item:BaseItem in CombatRootControl.Instance.GameState.MapState.list_items():
		var item_type = "default"
		if item is BasePageItem:
			item_type = "Page"
		
		if not items_datas.has(item_type):
			items_datas[item_type] = {}
			
		var item_name = item.details.display_name
		if not items_datas[item_type].has(item_name):
			items_datas[item_type][item_name] = {}
			items_datas[item_type][item_name]['Texture'] = item.get_small_icon()
			items_datas[item_type][item_name]['Count'] = 1
		else:
			items_datas[item_type][item_name]['Count'] += 1
		PlayerInventory.add_item(item)
		CombatRootControl.Instance.GameState.MapState.remove_item(item)
	
	if not items_datas.has("Page"):
		pickup_pages_container.hide()
	else:
		for item_name in items_datas["Page"].keys():
			var new_line = premade_pickup_page.duplicate()
			new_line.get_child(0).texture = items_datas['Page'][item_name]['Texture']
			new_line.get_child(1).text = item_name
			new_line.get_child(4).text = str(items_datas['Page'][item_name]['Count'])
			pickup_pages_container.add_child(new_line)
			new_line.show()

	if not items_datas.has("default"):
		pickup_items_container.hide()
	else:
		for item_name in items_datas["default"].keys():
			var new_line = premade_pickup_item.duplicate()
			new_line.get_child(0).texture = items_datas['default'][item_name]['Texture']
			new_line.get_child(1).text = item_name
			new_line.get_child(4).text = str(items_datas['default'][item_name]['Count'])
			pickup_items_container.add_child(new_line)
			new_line.show()
