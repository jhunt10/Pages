class_name GameVictoryScreen
extends Control


@export var rounds_label:Label
@export var enemies_label:Label
@export var exp_label:Label
@export var money_label:Label
@export var camp_button:Button
@export var camp_button_label:Label
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
	if CombatRootControl.is_story_map:
		camp_button_label.text = "Continue"
	self.show()
	

func _on_camp_button():
	CombatRootControl.Instance.cleanup_combat()
	if CombatRootControl.is_story_map:
		StoryState.load_next_story_scene()
	else:
		MainRootNode.Instance.open_camp_menu()

func collect_dropped_items():
	var items_datas = {}
	var total_money = 0
	for item:BaseItem in CombatRootControl.Instance.GameState.list_items():
		
		print("Collecting Item: " + item.Id)
		if item.get_item_type() == BaseItem.ItemTypes.Money:
			total_money += item.get_item_value()
			CombatRootControl.Instance.GameState.delete_item(item)
			ItemLibrary.delete_item(item)
			continue
		
		var item_type = "default"
		if item is BasePageItem:
			item_type = "Page"
		
		if not items_datas.has(item_type):
			items_datas[item_type] = {}
			
		var item_name = item.get_display_name()
		if not items_datas[item_type].has(item_name):
			items_datas[item_type][item_name] = {}
			items_datas[item_type][item_name]['Texture'] = item.get_small_icon()
			items_datas[item_type][item_name]['Background'] = item.get_rarity_background()
			items_datas[item_type][item_name]['Count'] = 1
		else:
			items_datas[item_type][item_name]['Count'] += 1
		PlayerInventory.add_item(item)
		CombatRootControl.Instance.GameState.delete_item(item)
	
	
	var enemy_count = 0
	var actors = CombatRootControl.Instance.GameState.list_actors(true)
	var total_exp = 0
	for actor:BaseActor in actors:
		if actor.is_dead and actor.FactionIndex != 0:
			enemy_count += 1
			var enemy_val = actor.actor_data.get("MoneyValue", 0)
			total_money += enemy_val
			var exp_val = actor.actor_data.get("ExpValue", 0)
			total_exp += exp_val
			
	enemies_label.text = str(enemy_count)
	rounds_label.text = str(CombatRootControl.QueController.round_counter)
	money_label.text = "$"+str(total_money)
	StoryState.add_money(total_money)
	
	exp_label.text = str(total_exp)
	for actor:BaseActor in CombatRootControl.list_player_actors():
		if actor:
			actor.stats.add_experiance(total_exp)
		
	if not items_datas.has("Page"):
		pickup_pages_container.hide()
	else:
		for item_name in items_datas["Page"].keys():
			var new_line = premade_pickup_page.duplicate()
			new_line.get_child(0).texture = items_datas['Page'][item_name]['Background']
			new_line.get_child(0).get_child(0).texture = items_datas['Page'][item_name]['Texture']
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
