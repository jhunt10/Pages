class_name ActionDetailsControl
extends Control

@export var parent_card_control:ItemDetailsCard
@export var description_box:RichTextLabel
@export var target_type_label:Label
@export var cost_container:PageDetailsCard_CostContaienr
@export var range_display:MiniRangeDisplay
@export var damage_label:DamageLabelContainer

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
		if target_params:
			range_display.load_area_matrix(target_params.target_area)
			range_display.show()
		else:
			range_display.hide()
			target_type_label.hide()
	else:
		range_display.hide()
		target_type_label.hide()
	
	if action.has_ammo():
		cost_container.set_data(action.get_ammo_data())
		cost_container.show()
	else:
		cost_container.hide()
	
	if action.has_preview_damage():
		var damage_data = action.get_preview_damage_data(actor)
		if actor.pages.has_item(page.Id):
			damage_label.set_damage_data(damage_data, actor)
		else:
			damage_label.set_damage_data(damage_data)
	else:
		damage_label.hide()
	
	var target_params = action.get_preview_target_params(actor)
	if target_params:
		target_type_label.text = TargetParameters.TargetTypes.keys()[target_params.target_type]
		

#func on_eqiup_button_pressed():
	#if _actor.equipment.has_item(_item.Id):
		#_actor.equipment.remove_equipment(_item)
	#elif _actor.equipment.can_equip_item(_item):
		#_actor.equipment.try_equip_item(_item, true)
	#parent_card_control.start_hide()
