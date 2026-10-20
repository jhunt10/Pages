class_name BuyPanelContainer
extends PanelContainer

signal trade_confirmed(item_key:String, count:int, cost:int, selling:bool)

@export var close_button:TextureButton
@export var item_details_container:ItemDetailsContainer
@export var buy_controller:BuyController

var _item_key:String = ""
var sell_mode:bool=false

func _ready() -> void:
	close_button.pressed.connect(close_panel)
	buy_controller.buy_button_pressed.connect(_on_confirm)

func set_item(item:BaseItem, selling:bool=false):
	sell_mode = selling
	item_details_container.set_detail_container_item(null, item)
	item_details_container.exit_button_texture.hide()
	buy_controller.set_item(item, selling)

func close_panel():
	_item_key = ""
	# TODO: These should really be one script
	buy_controller._item_key = ""
	self.hide()

func _on_confirm(item_key:String, count:int, cost:int):
	trade_confirmed.emit(item_key, count, cost, sell_mode)
