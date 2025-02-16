class_name ShopMenuController
extends Control

enum States {Greeting, Buy, Sell}
enum SpeakerSubjects {Greeting, Buying, Selling, ConfirmBuy, BuySuccess, BuyCancel, ConfirmSell, SellSuccess, SellCancel}

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
var _said_greeting = false

## Items created for shop keyed by ItemKey
var _loaded_items_by_key:Dictionary
## Lists of item ids mapped by catagory
var _item_ids_by_catagories:Dictionary

func _ready() -> void:
	confirm_popup.hide()
	item_menu_controller.hide()
	item_menu_controller.item_button_pressed.connect(_on_item_button_pressed)
	item_menu_controller.catagory_selected.connect(_on_catagory_selected)
	item_menu_controller.back_button_pressed.connect(load_greeting)
	close_button.pressed.connect(close_menu)
	sell_button.pressed.connect(load_items_to_sell)
	buy_button.pressed.connect(load_items_to_buy)
	LoadManager._load_screen.loading_screen_fully_gone.connect(_on_load_screen_gone)

func _on_load_screen_gone():
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
	_load_text(SpeakerSubjects.Greeting)
	

func load_items_to_buy():
	_state = States.Buy
	_load_text(SpeakerSubjects.Buying)
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
	_load_text(SpeakerSubjects.Selling)
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
		"Pages": ["UsePotionSelf_PageItem", "ReloadPage_PageItem","MoveForward_PageItem","TurnLeft_PageItem","TurnRight_PageItem", "Wait_PageItem", "MoveLeft_PageItem", "MoveRight_PageItem", "TurnAround_PageItem", "Dash_PageItem"],
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
	_current_details_card.shop_mode = true
	_current_details_card.is_selling = _state == States.Sell
	_current_details_card.set_item(null, item)
	_current_details_card.start_show()
	_current_details_card.buy_controller.buy_button_pressed.connect(_show_confirm_popup)

func _show_confirm_popup(item_key:String, count:int, cost:int):
	if not confirm_popup.trade_confirmed.is_connected(_on_trade_confirmed):
		confirm_popup.trade_confirmed.connect(_on_trade_confirmed)
	if _state == States.Buy:
		var item = _loaded_items_by_key[item_key]
		confirm_popup.set_item(false, item, count)
		_load_text(SpeakerSubjects.ConfirmBuy, item, count)
	else:
		var item = PlayerInventory.get_item_by_key(item_key)
		confirm_popup.set_item(true, item, count)
		_load_text(SpeakerSubjects.ConfirmSell, item, count)
	if _current_details_card:
		_current_details_card.start_hide()

func _on_trade_confirmed(accepted:bool):
	if _state == States.Buy:
		if accepted:
			_load_text(SpeakerSubjects.BuySuccess)
		else:
			_load_text(SpeakerSubjects.BuyCancel)
	else:
		if accepted:
			_load_text(SpeakerSubjects.SellSuccess)
		else:
			_load_text(SpeakerSubjects.SellCancel)

static var _said_lines:Array=[]
func _load_text(subject:SpeakerSubjects, item:BaseItem=null, count:int=0):
	if subject == SpeakerSubjects.Greeting:
		if _said_greeting:
			_build_dialog_entries([
				{"SpeakerPort":"Happy"},
				"Need anything else? "
			])
			return
		_said_greeting = true
		if not StoryState.get_story_flag("BeenToShop"):
			StoryState.set_story_flag("BeenToShop", true)
			_build_dialog_entries([
				{"SpeakerPort":"VeryHappy"},
				"Welcome to the @Color:Red@Shop@Clear@!",
				{"Delay":0.8},
				{"SpeakerPort":"Happy"},
				"It ain't what it used to be, ",
				"but we're still in business. ",
			])
		else:
			_build_dialog_entries([
				{"SpeakerPort":"VeryHappy"},
				"Welcome back!",
				{"Delay":0.8},
				{"SpeakerPort":"Happy"},
				"You lookin to @Color:Red@Buy@Clear@ or @Color:Red@Sell@Clear@? "
			])
	elif subject == SpeakerSubjects.Buying:
		if not _said_lines.has("BanditsTook"):
			_said_lines.append("BanditsTook")
			_build_dialog_entries([
				{"SpeakerPort":"Sad"},
				"@Color:Red@Bandits@Clear@ took most of it.",
				{"Delay":0.8},
				{"SpeakerPort":"Happy"},
				"But I still got some @Color:Red@Potions@Clear@ and @Color:Red@Ammo@Clear@ in stock. "
			])
			return
		else:
			_build_dialog_entries([
				{"SpeakerPort":"Happy"},
				"You lookin for @Color:Red@Potions@Clear@ or @Color:Red@Ammo@Clear@?"
			])
			return
	elif subject == SpeakerSubjects.Selling:
			_build_dialog_entries([
				{"SpeakerPort":"Happy"},
				"Got some @Color:Red@Loot@Clear@ to unload?",
			])
			return
	elif subject == SpeakerSubjects.ConfirmBuy:
		var item_name = "of these"
		if item:
			item_name = "@Color:Red@"+item.details.display_name+"@Clear@"
		_build_dialog_entries([
			{"SpeakerPort":"Happy"},
			"So you want " + str(count) + " " + item_name + "?",
		])
	elif subject == SpeakerSubjects.ConfirmSell:
		var item_name = "of these"
		if item:
			item_name = "@Color:Red@"+item.details.display_name+"@Clear@"
		_build_dialog_entries([
			{"SpeakerPort":"Happy"},
			"So you wanna sell " + str(count) + " " + item_name + "?",
		])
	elif subject == SpeakerSubjects.BuySuccess or subject == SpeakerSubjects.SellSuccess:
		var item_name = "of these"
		if item:
			item_name = "@Color:Red@"+item.details.display_name+"@Clear@"
		_build_dialog_entries([
			{"SpeakerPort":"Happy"},
			"Pleasure doing business with you.",
			"WaitToRead",
			"WaitToRead",
			"Clear",
			{"SpeakerPort":"Happy"},
			"Is there anything else you need?",
		])
	elif subject == SpeakerSubjects.BuyCancel or subject == SpeakerSubjects.SellCancel:
		var item_name = "of these"
		if item:
			item_name = "@Color:Red@"+item.details.display_name+"@Clear@"
		_build_dialog_entries([
			{"SpeakerPort":"Neutral"},
			"Too bad.",
			"WaitToRead",
			"WaitToRead",
			"Clear",
			{"SpeakerPort":"Happy"},
			"Is there anything else you need?",
		])
		

# Translates an array of simple strings and dicts to dialog box entries
func _build_dialog_entries(arr:Array):
	var new_entries = [
		{
			"EntryType": "Clear",
			"ClearSpeaker": false
		}
	]
	for line in arr:
		if line is Dictionary:
			if line.has("Delay"):
				new_entries.append(
				{
					"EntryType": "Delay",
					"Delay": line.get("Delay",0)
				})
			elif line.has("SpeakerPort"):
				var emotion = line['SpeakerPort']
				new_entries.append(
				{
					"EntryType": "Speaker",
					"SpeakerName": "FMrc",
					"SpeakerPort": "res://defs/Actors/NPCs/FishMerch/Portraits/FishMerch_" + emotion + ".png"
				})
		elif line is String:
			if line == "WaitToRead":
				new_entries.append(
				{
					"EntryType": "WaitToRead"
				})
			elif line == "Clear":
				new_entries.append(
				{
					"EntryType": "Clear",
					"ClearSpeaker": false
				})
			else:
				new_entries.append(
				{
					"EntryType": "Text",
					"Text": line,
					"NewLine": true
				})
	dialog_box.add_entries(new_entries)
			
