class_name BaseCharacterSubMenu
extends Control

signal item_button_down(context, item_key, index)
signal item_button_up(context, item_key, index)
signal mouse_enter_item(context, item_key, index)
signal mouse_exit_item(context, item_key, index)

var parent_menu#:CharacterMenuControl:
	#get: return $"../../.."

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
	self.visibility_changed.connect(sync)

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
func sync():
	if !_actor:
		return
	
	if !self.visible:
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

func highlight_slot(index:int):
	var button = get_item_slot_button_for_index(index)
	if button:
		button.show_highlight()

func clear_highlight(index:int):
	var button = get_item_slot_button_for_index(index)
	if button:
		button.hide_highlight()

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


func can_place_item_in_slot(item:BaseItem, index:int):
	var holder = get_item_holder()
	return holder.can_set_item_in_slot(item, index, true)

func try_place_item_in_slot(item:BaseItem, index:int):
	var holder = get_item_holder()
	var res = ItemHelper.try_transfer_item_from_inventory_to_holder(item, holder, index, true)
	if res == '':
		return true
	return false

func try_move_item_to_slot(_item:BaseItem, from_index:int, to_index:int):
	var holder = get_item_holder()
	ItemHelper.swap_item_holder_slots(holder, from_index, to_index)

func remove_item_from_slot(item:BaseItem, _index:int):
	var holder = get_item_holder()
	ItemHelper.try_transfer_item_from_holder_to_inventory(item, holder)
