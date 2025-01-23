class_name ShopMenuController
extends Control

enum States {Greeting, Buy, Sell}

@export var dialog_box:DialogBox
@export var item_menu_controller:ShopItemMenuController
@export var scroll_bar:CustScrollBar
@export var details_card_spawn_point:Control
@export var confirm_popup:ShopConfirmPopUp
@export var buy_button:Button
@export var sell_button:Button
@export var close_button:Button

var _current_details_card
var _state:States

## Items created for shop keyed by ItemKey
var _loaded_items_by_key:Dictionary
## Lists of item ids mapped by catagory
var _item_ids_by_catagories:Dictionary

func _ready() -> void:
	confirm_popup.hide()
	item_menu_controller.item_button_pressed.connect(_on_item_button_pressed)
	item_menu_controller.catagory_selected.connect(_on_catagory_selected)
	item_menu_controller.back_button_pressed.connect(load_greeting)
	close_button.pressed.connect(close_menu)
	sell_button.pressed.connect(load_items_to_sell)
	buy_button.pressed.connect(load_items_to_buy)
	load_greeting()

func _process(delta: float) -> void:
	scroll_bar.calc_bar_size()

func close_menu():
	MainRootNode.Instance.open_camp_menu()

func load_greeting():
	_state = States.Buy
	item_menu_controller.hide()
	if _current_details_card:
		_current_details_card.start_hide()
	dialog_box.add_entries(
		[
			{
				"EntryType": "Clear",
				"ClearSpeaker": false
			},
			{
				"EntryType": "Speaker",
				"SpeakerName": "FMrc",
				"SpeakerPort": "res://defs/Actors/NPCs/FishMerch/FishMerch_Sleeping.png"
			},
			{
				"EntryType": "Text",
				"Text": "Buying or selling?!",
				"NewLine": true
			},
		]
	)
	

func load_items_to_buy():
	_state = States.Buy
	dialog_box.add_entries(
		[
			{
				"EntryType": "Clear",
				"ClearSpeaker": false
			},
			{
				"EntryType": "Speaker",
				"SpeakerName": "FMrc",
				"SpeakerPort": "res://defs/Actors/NPCs/FishMerch/FishMerch_Sleeping.png"
			},
			{
				"EntryType": "Text",
				"Text": "I've got some great stuff instock.",
				"NewLine": true
			},
		]
	)
	var shop_data = get_shop_data()
	for cat in shop_data.keys():
		if not _item_ids_by_catagories.has(cat):
			_item_ids_by_catagories[cat] = []
		for item_key in shop_data.get(cat):
			if _item_ids_by_catagories[cat].has(item_key + "_SHOP"):
				continue
			var new_item = ItemLibrary.get_or_create_item(item_key + "_SHOP", item_key,  {})
			if not new_item:
				printerr("Shop.load_items: Failed to find item: %s" % [item_key])
				continue
			_item_ids_by_catagories[cat].append(new_item.Id)
			_loaded_items_by_key[item_key] = new_item
	item_menu_controller.set_data(_item_ids_by_catagories)
	item_menu_controller.show()

func load_items_to_sell():
	_state = States.Sell
	dialog_box.add_entries(
		[
			{
				"EntryType": "Clear",
				"ClearSpeaker": false
			},
			{
				"EntryType": "Speaker",
				"SpeakerName": "FMrc",
				"SpeakerPort": "res://defs/Actors/NPCs/FishMerch/FishMerch_Sleeping.png"
			},
			{
				"EntryType": "Text",
				"Text": "Let me see what I can take off your hands.",
				"NewLine": true
			},
		]
	)
	var catagories = {}
	var selling_items_data = {}
	for item:BaseItem in PlayerInventory.list_all_held_items():
		var type = item.get_item_type()
		if not catagories.keys().has(type):
			catagories[type] = []
		catagories[type].append(item.Id)
	for cat in catagories:
		if cat == BaseItem.ItemTypes.KeyItem:
			continue
		var cat_name = BaseItem.ItemTypes.keys()[cat]
		if not selling_items_data.has(cat_name):
			selling_items_data[cat_name] = []
		for item_id in catagories.get(cat):
			var item = ItemLibrary.get_item(item_id)
			selling_items_data[cat_name].append(item.Id)
	item_menu_controller.set_data(selling_items_data)
	item_menu_controller.show()

func get_shop_data()->Dictionary:
	return {
		"Ammo": ["Phy_Ammo", "Mag_Ammo", "Gen_Ammo"],
		"Potions": ["HealthPotionS", "HealthPotionM", "HealthPotionL"],
		"Pages": ["MoveForward_PageItem","TurnLeft_PageItem","TurnRight_PageItem", "Wait_PageItem", "MoveLeft_PageItem", "MoveRight_PageItem", "TurnAround_PageItem", "Dash_PageItem"],
	}

func _on_catagory_selected(sub_list:ShopSubItemList):
	scroll_bar.scroll_container.ensure_control_visible(sub_list)

func _on_item_button_pressed(item_key):
	if _state == States.Buy:
		var item = _loaded_items_by_key[item_key]
		create_details_card(item)
	if _state == States.Sell:
		var item = PlayerInventory.get_item_by_key(item_key)
		create_details_card(item)
	printerr("Pressed " + item_key)

func on_details_card_freed():
	_current_details_card.queue_free()
	_current_details_card = null

func create_details_card(item:BaseItem):
	if not item:
		printerr("ShopMenu.create_details_card: Null Item")
		return
	if _current_details_card:
		if _current_details_card.item_id == item.Id:
			_current_details_card.show()
			return
		_current_details_card.hide_done.disconnect(on_details_card_freed)
		_current_details_card.start_hide()
	_current_details_card = load("res://Scenes/Menus/CharacterMenu/MenuPages/ItemDetailsCard/item_details_card.tscn").instantiate()
	_current_details_card.custom_minimum_size = details_card_spawn_point.size
	print(_current_details_card.custom_minimum_size)
	details_card_spawn_point.add_child(_current_details_card)
	_current_details_card.hide_done.connect(on_details_card_freed)
	_current_details_card.buy_mode = true
	_current_details_card.buy_controller.sell_mode = _state == States.Sell
	_current_details_card.set_item(null, item)
	_current_details_card.start_show()
	_current_details_card.buy_controller.buy_button_pressed.connect(_show_confirm_popup)

func _show_confirm_popup(item_key:String, count:int, cost:int):
	if _state == States.Buy:
		var item = _loaded_items_by_key[item_key]
		confirm_popup.set_item(false, item, count)
		dialog_box.add_entries(
			[
				{
					"EntryType": "Clear",
					"ClearSpeaker": false
				},
				{
					"EntryType": "Speaker",
					"SpeakerName": "FMrc",
					"SpeakerPort": "res://defs/Actors/NPCs/FishMerch/FishMerch_Sleeping.png"
				},
				{
					"EntryType": "Text",
					"Text": "This what you want?",
					"NewLine": true
				},
			]
		)
	else:
		var item = PlayerInventory.get_item_by_key(item_key)
		confirm_popup.set_item(true, item, count)
		dialog_box.add_entries(
			[
				{
					"EntryType": "Clear",
					"ClearSpeaker": false
				},
				{
					"EntryType": "Speaker",
					"SpeakerName": "FMrc",
					"SpeakerPort": "res://defs/Actors/NPCs/FishMerch/FishMerch_Sleeping.png"
				},
				{
					"EntryType": "Text",
					"Text": "I guess I could buy it.",
					"NewLine": true
				},
			]
		)
	if _current_details_card:
		_current_details_card.start_hide()
	
