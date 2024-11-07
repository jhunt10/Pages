@tool
class_name PageQueSlotsContainer
extends BackPatchContainer

signal page_slot_pressed(index:int)

@export var premade_page_slot_button:PageQueSlotButton
@export var page_slots_container:FlowContainer

func _ready() -> void:
	#super()
	if Engine.is_editor_hint(): return
	premade_page_slot_button.visible = false

func set_actor(actor:BaseActor):
	for child in page_slots_container.get_children():
		child.queue_free()
	var que_equipments = actor.equipment.get_equipt_items_of_slot_type("Que")
	var action_key_list:Array = actor.get_action_list()
	var que_equipment:BaseQueEquipment = que_equipments[0]
	for index in range(que_equipment.get_max_page_count()):
		var page:BaseAction = null
		if index < action_key_list.size() and action_key_list[index]:
			page = ActionLibrary.get_action(action_key_list[index])
		_create_slots(index, page)
	pass

func _create_slots(index:int, page:BaseAction):
	var new_slot:PageQueSlotButton = premade_page_slot_button.duplicate()
	page_slots_container.add_child(new_slot)
	new_slot.visible = true
	if page:
		new_slot.set_page(page)
	new_slot.pressed.connect(on_page_slot_pressed.bind(index))

func on_page_slot_pressed(index:int):
	page_slot_pressed.emit(index)
