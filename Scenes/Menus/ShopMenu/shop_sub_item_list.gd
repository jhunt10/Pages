@tool
class_name ShopSubItemList
extends Control

enum States {Hidden, Growing, Showing, Shrinking}

@export var showing:bool:
	set(val):
		showing = val
		if showing and (state == States.Hidden or state == States.Shrinking):
			state = States.Growing
		if not showing and (state == States.Showing or state == States.Growing):
			state = States.Shrinking
		if symbole_texture_rect:
			if showing:
				symbole_texture_rect.texture = minus_icon
			else:
				symbole_texture_rect.texture = plus_icon

@export var title:String:
	set(val):
		title = val
		if title_label:
			title_label.text = title

@export var state:States:
	set(val):
		state = val
		if state == States.Hidden:
			grow_timer = 0
			self.custom_minimum_size = _get_minimum_size()
			minimum_size_changed.emit()
		elif state == States.Showing:
			grow_timer = grow_time
			self.custom_minimum_size = _get_minimum_size()
			minimum_size_changed.emit()
		#item_rect_changed.emit()
@export var min_hight:int = 60
@export var grow_time:float
@export var grow_timer:float

@export var title_button:Button
@export var title_h_box:HBoxContainer
@export var symbole_texture_rect:TextureRect
@export var plus_icon:Texture2D
@export var minus_icon:Texture2D

@export var title_label:Control

@export var entries_v_box:VBoxContainer
@export var premade_item_button:Control

var parent_controller:ShopItemMenuController
var _item_buttons_by_id:Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	premade_item_button.hide()
	#title_button.pressed.connect(_toggle_show)
	pass # Replace with function body.

func _toggle_show():
	showing = !showing

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state == States.Growing:
		grow_timer += delta
		if grow_timer > grow_time:
			state = States.Showing
		else:
			self.custom_minimum_size = _get_minimum_size()
	if state == States.Shrinking:
		grow_timer -= delta
		if grow_timer < 0:
			state = States.Hidden
		else:
			self.custom_minimum_size = _get_minimum_size()
		
	pass

func _get_minimum_size() -> Vector2:
	var parent_size = self.get_parent_area_size()
	if !title_h_box or !entries_v_box:
		return Vector2(parent_size.x, min_hight)
	if state == States.Showing:
		var _size = Vector2(parent_size.x, title_h_box.size.y + entries_v_box.get_minimum_size().y)
		return _size
	if state == States.Hidden:
		var _size =  Vector2(parent_size.x, min_hight)
		return _size
	var percent_done = minf(1.0, grow_timer / grow_time)
	var size_diff = entries_v_box.get_minimum_size().y
	var add_size = size_diff * percent_done

	var _size =  Vector2(parent_size.x, min_hight + add_size)
	return _size

func set_item_list(catagory:String, items:Array):
	title_label.text = catagory
	for item_id in _item_buttons_by_id.keys():
		if items.has(item_id):
			entries_v_box.remove_child(_item_buttons_by_id[item_id])
		else:
			_item_buttons_by_id[item_id].queue_free()
			_item_buttons_by_id.erase(item_id)
	
	for item_id in items:
		var item = ItemLibrary.get_item(item_id)
		if not item:
			continue
		var button:ShopItemButton = null
		if _item_buttons_by_id.has(item_id):
			button = _item_buttons_by_id[item_id]
		else:
			button = premade_item_button.duplicate()
			button.button.pressed.connect(parent_controller._on_item_button_pressed.bind(item.ItemKey))
			_item_buttons_by_id[item_id] = button
		entries_v_box.add_child(button)
		button.set_item(item)
		print("Added Item: " + item_id)
		button.show()
