class_name PageBookDetailsControl
extends BoxContainer

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
	description_box.set_object(que._def, que, actor)
	ppr_label.text = str(que.get_pages_per_round())
	passive_count_label.text = str(que.get_base_passive_page_limit())
	action_count_label.text = str(que.get_base_action_page_limit())
	for page_set in que.get_page_slot_data():
		var key = page_set.get("Key", '')
		if key == "BasePassives" or key == "BaseActions":
			continue
		var new_label:ItemCard_PageSetLabel = premade_page_set_label.duplicate()
		new_label.tag_label.text = page_set['DisplayName']
		new_label.count_label.text = str(page_set['Count'])
		page_sets_container.add_child(new_label)
		new_label.show()
