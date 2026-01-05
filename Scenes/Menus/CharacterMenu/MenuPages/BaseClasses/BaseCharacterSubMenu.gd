class_name BaseCharacterSubMenu
extends Node

signal item_button_down(context, item_key, index)
signal item_button_up(context, item_key, index)
signal mouse_enter_item(context, item_key, index)
signal mouse_exit_item(context, item_key, index)

var parent_menu:CharacterMenuControl:
	get: return $"../../.."

var item_slot_buttons:Array = []
var rebuild_slots:bool = true
var last_synced_actor_id:String = ''

var _actor:BaseActor:
	get:
		if parent_menu:
			return parent_menu._actor
		else:
			return null


func _ready() -> void:
	pass 

func _process(_delta: float) -> void:
	pass

######################################
########### Override These ###########
######################################
 
func get_item_holder()->BaseItemHolder:
	return null
func build_item_slots():
	pass
func get_button_mouse_offset(index:int)->Vector2:
	if index >= 0 and index < item_slot_buttons.size():
		return item_slot_buttons[index].get_local_mouse_position()
	return Vector2.ZERO



######################################
###########   Base Funcs   ###########
######################################
func show_menu_page():
	sync()
	self.visible = true

func sync():
	if !_actor:
		return
	if last_synced_actor_id != _actor.Id:
		rebuild_slots = true
	
	if rebuild_slots:
		build_item_slots()
	
	var holder = get_item_holder()
	# Set stuff on buttons
	for index in range(item_slot_buttons.size()):
		var item = holder.get_item_in_slot(index)
		var item_slot = get_item_slot_button_for_index(index)
		if item_slot.parent_sub_menu != self:
			item_slot.parent_sub_menu = self
		if not item_slot.button.button_down.is_connected(_on_item_button_down):
			item_slot.button.button_down.connect(_on_item_button_down.bind(index))
			item_slot.button.button_up.connect(_on_item_button_up.bind(index))
			item_slot.button.mouse_entered.connect(_on_mouse_enter_item_button.bind(index))
			item_slot.button.mouse_exited.connect(_on_mouse_exit_item_button.bind(index))
		item_slot.set_item(_actor, holder, item)
	
	last_synced_actor_id = _actor.Id


func get_item_slot_button_for_index(index:int)->BaseCharacterMenu_ItemSlotButton:
	if index >= 0 and item_slot_buttons.size() > index:
		return item_slot_buttons[index]
	return null

func highlight_slot(_index:int):
	pass

func _on_item_button_down(index:int):
	var holder = get_item_holder()
	var item_id = holder.get_item_id_in_slot(index)
	var offset =  get_button_mouse_offset(index)
	item_button_down.emit(holder.get_holder_name(), item_id, index, offset)

func _on_item_button_up(index:int):
	var holder = get_item_holder()
	var item_id = holder.get_item_id_in_slot(index)
	item_button_up.emit(holder.get_holder_name(), item_id, index)

func _on_mouse_enter_item_button(index:int):
	var holder = get_item_holder()
	var item_id = holder.get_item_id_in_slot(index)
	mouse_enter_item.emit(holder.get_holder_name(), item_id, index)

func _on_mouse_exit_item_button(index:int):
	var holder = get_item_holder()
	var item_id = holder.get_item_id_in_slot(index)
	mouse_exit_item.emit(holder.get_holder_name(), item_id, index)
