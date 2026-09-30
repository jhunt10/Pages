class_name CharacterMenu_EquipmentControl
extends BaseCharacterSubMenu

@export var title_button:EquipmentSlotButton
@export var book_button:EquipmentSlotButton
@export var bag_button:EquipmentSlotButton
@export var trinket_button:EquipmentSlotButton
@export var main_hand_button:EquipmentSlotButton
@export var off_hand_button:EquipmentSlotButton

func get_item_holder()->BaseItemHolder:
	if _actor:
		return _actor.equipment
	return null

func _ready() -> void:
	pass
	#title_button.button_down.connect(_on_slot_down.bind(0))
	#book_button.button_down.connect(_on_slot_down.bind(1))
	#bag_button.button_down.connect(_on_slot_down.bind(2))
	#trinket_button.button_down.connect(_on_slot_down.bind(3))
	#main_hand_button.button_down.connect(_on_slot_down.bind(4))
	#off_hand_button.button_down.connect(_on_slot_down.bind(5))


func build_item_slots():
	item_slot_buttons = [book_button, bag_button, main_hand_button, off_hand_button, trinket_button]

func sync():
	item_slot_buttons = [book_button, bag_button, main_hand_button, off_hand_button, trinket_button]
	super()
	var title_page = _actor.get_title_page()
	if title_page:
		title_button.set_item(_actor, null, title_page)
	if _actor.equipment.is_two_handing():
		var primary = _actor.equipment.get_primary_weapon()
		if primary:
			off_hand_button.set_item(_actor, _actor.equipment, primary)

# Highjack button logic to point OffHand to MainHand when TwoHand
func _on_item_button_down(index:int):
	if _actor.equipment.is_two_handing():
		if _actor.equipment.list_offhand_indexes().has(index):
			index = _actor.equipment.list_all_hand_indexes()[0]
	super(index)

func _on_item_button_up(index:int):
	if _actor.equipment.is_two_handing():
		if _actor.equipment.list_offhand_indexes().has(index):
			index = _actor.equipment.list_all_hand_indexes()[0]
	super(index)

# When TwoHand, treat both HandSlots as the same
func highlight_slot(index:int):
	if _actor.equipment.is_two_handing():
		var all_hands =  _actor.equipment.list_all_hand_indexes()
		if all_hands.has(index):
			for hand_index in all_hands:
				super(hand_index)
	else:
		super(index)

func clear_highlight(index:int):
	if _actor.equipment.is_two_handing():
		var all_hands =  _actor.equipment.list_all_hand_indexes()
		if all_hands.has(index):
			for hand_index in all_hands:
				super(hand_index)
	else:
		super(index)
