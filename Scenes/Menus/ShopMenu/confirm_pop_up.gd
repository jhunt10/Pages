class_name  ShopConfirmPopUp
extends NinePatchRect

signal trade_confirmed(accepted:bool)

@export var title_label:Label

@export var item_background:TextureRect
@export var item_icon:TextureRect
@export var item_label:Control

@export var price_label:Label
@export var count_label:Label
@export var total_label:Label
@export var money_label:Label
@export var after_label:Label

@export var cancel_button:PatchButton
@export var confirm_button:PatchButton

var _selling:bool
var _item_key
var _count
var _cost

func _ready() -> void:
	cancel_button.pressed.connect(_on_cancel)
	confirm_button.pressed.connect(_on_confirm)

func set_item(selling:bool, item:BaseItem, count:int):
	_selling = selling
	_count = count
	_item_key = item.ItemKey
	if selling:
		title_label.text = "Selling"
		confirm_button.text = "Sell"
	else:
		title_label.text = "Purchase"
		confirm_button.text = "Buy"
	item_label.text = item.details.display_name
	item_background.texture = item.get_rarity_background()
	item_icon.texture = item.get_small_icon()
	var cost = item.get_item_value()
	price_label.text = str(cost)
	count_label.text = str(count)
	_cost = cost * count
	total_label.text = str(_cost)
	var current_money = StoryState.get_current_money()
	money_label.text = str(current_money)
	if selling:
		after_label.text = str(current_money + _cost)
	else:
		after_label.text = str(current_money - _cost)
	self.show()

func _on_confirm():
	if not _selling:
		if StoryState.get_current_money() >= _cost:
			StoryState.spend_money(_cost)
			PlayerInventory.add_to_stack(_item_key, _count)
	else:
		if PlayerInventory.get_item_stack_count(_item_key) >= _count:
			PlayerInventory.reduce_stack_count(_item_key, _count)
			StoryState.spend_money(-_cost)
	trade_confirmed.emit(true)
	self.hide()

func _on_cancel():
	trade_confirmed.emit(false)
	self.hide()
