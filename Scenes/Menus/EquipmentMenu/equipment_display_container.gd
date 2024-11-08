@tool
class_name EquipmentDisplayContainer
extends BackPatchContainer

@export var portrait_sprite:Sprite2D
@export var armor_lable:Label
@export var ward_label:Label
@export var phyatk_label:Label
@export var magatk_label:Label
@export var mass_label:Label
@export var speed_label:Label
@export var page_count_label:Label
@export var que_count_label:Label

signal equipt_slot_pressed(slot:int)

var _actor:BaseActor

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

func set_actor(actor:BaseActor):
	#portait_texture_rect.texture = _actor.get_sprite()
	if _actor and _actor.sprite_changed.is_connected(on_actor_sprite_change):
		_actor.sprite_changed.disconnect(on_actor_sprite_change)
	_actor = actor
	_actor.sprite_changed.connect(on_actor_sprite_change)
	
	portrait_sprite.texture = _actor.get_sprite()
	var frames = _actor.get_load_val("SpriteFrameWH", [1,1])
	portrait_sprite.hframes = frames[0]
	portrait_sprite.vframes = frames[1]
	var offset = _actor.get_load_val("SpriteOffset", [0,0])
	portrait_sprite.position = Vector2(offset[0], offset[1])
	
	
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

func on_actor_sprite_change():
	portrait_sprite.texture = _actor.get_sprite()
	

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
