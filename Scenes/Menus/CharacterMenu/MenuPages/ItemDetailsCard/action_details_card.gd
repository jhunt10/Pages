class_name ActionDetailsControl
extends Control

@export var parent_card_control:ItemDetailsCard
@export var description_box:RichTextLabel
@export var cost_container:PageDetailsCard_CostContaienr
@export var range_display:MiniRangeDisplay

var _item:BasePageItem
var _actor:BaseActor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_action(actor:BaseActor, page:BasePageItem):
	_actor = actor
	_item = page
	var action = page.get_action()
	description_box.text = action.details.description
	
	if action.has_preview_target():
		var target_params = action.get_preview_target_params(_actor)
		range_display.load_area_matrix(target_params.target_area)
		range_display.show()
	else:
		range_display.hide()
	
	if action.CostData.size() > 0:
		cost_container.set_costs(action.CostData)
		cost_container.show()
	else:
		cost_container.hide()

#func on_eqiup_button_pressed():
	#if _actor.equipment.has_item(_item.Id):
		#_actor.equipment.remove_equipment(_item)
	#elif _actor.equipment.can_equip_item(_item):
		#_actor.equipment.try_equip_item(_item, true)
	#parent_card_control.start_hide()
