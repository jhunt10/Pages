class_name BuyController
extends Control

signal buy_button_pressed(item_key:String, count:int, cost:int)

@export var sell_mode:bool:
	set(val):
		sell_mode = val
		if buy_confirm_button:
			if sell_mode: #TODO: Translation
				buy_confirm_button.text = "Sell"
			else:
				buy_confirm_button.text = "Buy"
@export var total_value:int:
	set(val):
		total_value = val
		if cost_value_label:
			cost_value_label.text = str(total_value)
			var cur_money = StoryState.get_current_money()
			if not sell_mode and total_value > cur_money:
				cost_container.modulate = invalid_cost_color
				cost_value_label.text = "("+str(total_value)+")"
				cost_value_label.add_theme_color_override("font_color", invalid_cost_color)
				buy_confirm_button.disabled = true
			else:
				cost_container.modulate = default_cost_color
				cost_value_label.add_theme_color_override("font_color", default_cost_color)
				buy_confirm_button.disabled = false

@export var item_price:int:
	set(val):
		item_price = val
		if item_value_label:
			item_value_label.text = str(val)
		total_value = buying_count * item_price

@export var buying_count:int:
	set(val):
		buying_count = val
		if buying_count_label:
			buying_count_label.text = str(buying_count)
		total_value = buying_count * item_price

@export var owned_count:int


@export var plus_button:PatchButton
@export var minus_button:PatchButton

@export var buying_count_label:Label
@export var owned_count_label:Label
@export var item_value_label:Label
@export var cost_container:Control
@export var cost_value_label:Label

@export var buy_confirm_button:Button

@export var default_cost_color:Color
@export var invalid_cost_color:Color

var _item_key

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	plus_button.pressed.connect(_on_plus_pressed)
	minus_button.pressed.connect(_on_minus_pressed)
	if buy_confirm_button:
		buy_confirm_button.pressed.connect(_on_buy_pressed)
	sell_mode = sell_mode

func _on_plus_pressed():
	if sell_mode:
		buying_count = min(owned_count, buying_count + 1)
	else:
		buying_count = min(99, buying_count + 1)

func _on_minus_pressed():
	buying_count = max(1, buying_count - 1)

func _on_buy_pressed():
	buy_button_pressed.emit(_item_key, buying_count, total_value)
	owned_count = PlayerInventory.get_item_stack_count(_item_key)
	owned_count_label.text = str(owned_count)
	
	

func set_item(item:BaseItem, selling:bool):
	if _item_key != item.ItemKey or selling != sell_mode:
		buying_count = 1
	_item_key = item.ItemKey
	sell_mode = selling
	item_price = item.get_item_value()
	owned_count = PlayerInventory.get_item_stack_count(_item_key)
	owned_count_label.text = str(owned_count)
	item_value_label.text = str(item.get_item_value())
