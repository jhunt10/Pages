@tool
class_name EquipmentDisplayContainer
extends BackPatchContainer

@export var actor_node:ActorNode
@export var armor_lable:Label
@export var ward_label:Label
@export var phyatk_label:Label
@export var magatk_label:Label
@export var mass_label:Label
@export var speed_label:Label
@export var page_count_label:Label
@export var que_count_label:Label

@onready var left_button:Button = $InnerContainer/MiddlePortraitContainer/ButtonsContainer/Button
@onready var right_button:Button = $InnerContainer/MiddlePortraitContainer/ButtonsContainer/Button2

signal equipt_slot_pressed(slot:int)

@onready var main_hand_slider:Slider = $InnerContainer/LeftEquipSlots/HSlider
@onready var off_hand_slider:Slider = $InnerContainer/RightEquipSlots/HSlider

var _actor:BaseActor
var _display_dir:int = 2

var slot_displays:Array:
	get: return [
		$InnerContainer/RightEquipSlots/QueSlotButton,
		$InnerContainer/RightEquipSlots/BagSlotButton,
		$InnerContainer/LeftEquipSlots/HeadSlotButton,
		$InnerContainer/LeftEquipSlots/BodySlotButton,
		$InnerContainer/LeftEquipSlots/FeetSlotButton,
		$InnerContainer/RightEquipSlots/TrinketSlotButton,
		$InnerContainer/LeftEquipSlots/MainHandSlotButton,
		$InnerContainer/RightEquipSlots/OffHandSlotButton,
	]

func _ready() -> void:
	for slot:int in range(slot_displays.size()):
		var slot_display:EquipmentDisplaySlotButton = slot_displays[slot]
		slot_display.pressed.connect(_on_slot_pressed.bind(slot))
	left_button.pressed.connect(_rotate_sprite.bind(true))
	right_button.pressed.connect(_rotate_sprite.bind(false))
	main_hand_slider.value_changed.connect(rotate_main_hand)
	off_hand_slider.value_changed.connect(rotate_off_hand)

func rotate_main_hand(val):
	print("Setting MainHand rotation: %s " % [val])
	if _actor.equipment.is_two_handing():
		if actor_node.two_hand_weapon_node.rotation_factor != 1:
			actor_node.two_hand_weapon_node.rotation_factor = 1
		actor_node.two_hand_weapon_node.custom_rotation = val
		off_hand_slider.set_value_no_signal(val)
		var primary = _actor.equipment.get_primary_weapon()
		if primary:
			primary.get_load_val("WeaponSpriteData", {})['Rotation'] = val
	else:
		var primary = _actor.equipment.get_primary_weapon()
		if primary:
			primary.get_load_val("WeaponSpriteData", {})['Rotation'] = val
		if actor_node.main_hand_weapon_node.rotation_factor != 1:
			actor_node.main_hand_weapon_node.rotation_factor = 1
		actor_node.main_hand_weapon_node.custom_rotation = val
func rotate_off_hand(val):
	print("Setting OffHand rotation: %s " % [val])
	if _actor.equipment.is_two_handing():
		if actor_node.two_hand_weapon_node.rotation_factor != 1:
			actor_node.two_hand_weapon_node.rotation_factor = 1
		actor_node.two_hand_weapon_node.custom_rotation = val
		off_hand_slider.set_value_no_signal(val)
		var primary = _actor.equipment.get_primary_weapon()
		if primary:
			primary.get_load_val("WeaponSpriteData", {})['Rotation'] = val
	else:
		var offhand = _actor.equipment.get_offhand_weapon()
		if offhand:
			offhand.get_load_val("WeaponSpriteData", {})['Rotation'] = val
		if actor_node.off_hand_weapon_node.rotation_factor != 1:
			actor_node.off_hand_weapon_node.rotation_factor = 1
		actor_node.off_hand_weapon_node.custom_rotation = val

func _rotate_sprite(left:bool):
	var dir = _display_dir
	var new_dir = dir 
	if left: new_dir = (dir + 1 + 4) % 4
	else: new_dir = (dir - 1 + 4) % 4
	actor_node.set_display_pos(MapPos.new(0,0,0,new_dir))
	_display_dir = new_dir

func set_actor(actor:BaseActor):
	if actor == _actor:
		_sync()
		return
	if _actor:
		if _actor.equipment_changed.is_connected(_sync):
			_actor.equipment_changed.disconnect(_sync)
	_actor = actor
	actor_node.set_actor(actor)
	_actor.equipment_changed.connect(_sync)
	_sync()

func _sync():
	armor_lable.text = str(_actor.equipment.get_total_equipment_armor())
	ward_label.text = str(_actor.equipment.get_total_equipment_ward())
	for index:int in range(slot_displays.size()):
		var slot_display:EquipmentDisplaySlotButton = slot_displays[index]
		var slot_type = _actor.equipment.get_slot_equipment_type(index)
		slot_display.set_slot_type(slot_type)
		if _actor.equipment.has_equipment_in_slot(index):
			var item:BaseEquipmentItem = _actor.equipment.get_equipment_in_slot(index)
			slot_display.set_item(item)
		else:
			slot_display.clear_item()
	#for slot in BaseEquipmentItem.EquipmentSlots.values():
		#if _actor.equipment.has_item_in_slot(slot):
			#slots_to_display[slot].set_item(_actor.equipment.get_item_in_slot(slot))
		#else:
			#slots_to_display[slot].clear_item()
	#mass_label.text = str(_actor.stats.get_stat("Mass"))
	#speed_label.text = str(_actor.stats.get_stat("Speed"))
	#var que:BaseQueEquipment = _actor.equipment.get_item_in_slot(BaseEquipmentItem.EquipmentSlots.Que)
	#if que:
		#page_count_label.text = str(que.get_max_page_count())
		#page_count_label.self_modulate = Color.WHITE
		#que_count_label.text = str(que.get_max_que_size())
		#que_count_label.self_modulate = Color.WHITE
	#else:
		#page_count_label.text = "!!!"
		#page_count_label.self_modulate = Color.RED
		#que_count_label.text = "!!!"
		#que_count_label.self_modulate = Color.RED
	magatk_label.text = str(_actor.stats.get_base_magic_attack())
	phyatk_label.text = str(_actor.stats.get_base_phyical_attack())
	page_count_label.text = str(_actor.pages.get_max_page_count())
	que_count_label.text = str(_actor.stats.get_stat("PagesPerRound"))
	var primary_weapon = _actor.equipment.get_primary_weapon()
	if primary_weapon:
		main_hand_slider.value = primary_weapon.get_load_val("WeaponSpriteData", {}).get("Rotation", 0)
	var offhand_weapon = _actor.equipment.get_primary_weapon()
	if offhand_weapon:
		off_hand_slider.value = offhand_weapon.get_load_val("WeaponSpriteData", {}).get("Rotation", 0)

func _on_slot_pressed(index:int):
	var slot_display:EquipmentDisplaySlotButton = slot_displays[index]
	equipt_slot_pressed.emit(index)

func clear_highlights():
	for slot_display:EquipmentDisplaySlotButton in slot_displays:
		slot_display.highlight(false)

func highlight_slots_of_type(slot_type:String):
	for slot_display:EquipmentDisplaySlotButton in slot_displays:
		slot_display.highlight(slot_display.slot_type == slot_type)

func get_mouse_over_slot_index()->int:
	for index:int in range(slot_displays.size()):
		var slot_display:EquipmentDisplaySlotButton = slot_displays[index]
		if slot_display.is_mouse_over():
			return index
	return -1
