class_name PageQueDetailsControl
extends Control

@export var parent_card_control:ItemDetailsCard
@export var ppr_label:Label
@export var passive_count_label:Label
@export var action_count_label:Label
@export var page_sets_container:HBoxContainer
@export var premade_page_set_label:ItemCard_PageSetLabel
@export var description_box:DescriptionBox

var _item:BaseQueEquipment
var _actor:BaseActor

func _ready() -> void:
	premade_page_set_label.hide()

func set_item(actor:BaseActor, que:BaseQueEquipment):
	_actor = actor
	_item = que
	description_box.text = que.details.description
	ppr_label.text = str(que.get_pages_per_round())
	passive_count_label.text = str(que.get_base_passive_page_limit())
	action_count_label.text = str(que.get_base_action_page_limit())
	for page_set in que.get_load_val("ItemSlotsData", []):
		var new_label:ItemCard_PageSetLabel = premade_page_set_label.duplicate()
		new_label.tag_label.text = page_set['DisplayName']
		new_label.count_label.text = str(page_set['Count'])
		page_sets_container.add_child(new_label)
		new_label.show()
	
	if _actor.equipment.has_item(_item.Id):
		parent_card_control.equip_label.text = "Remove"	
	elif _actor.equipment.can_equip_item(_item):
		parent_card_control.equip_label.text = "Equip"
	else:
		parent_card_control.equip_button_background.hide()
	

func on_eqiup_button_pressed():
	if _actor.equipment.has_item(_item.Id):
		_actor.equipment.remove_equipment(_item)
	elif _actor.equipment.can_equip_item(_item):
		_actor.equipment.try_equip_item(_item, true)
	parent_card_control.start_hide()
