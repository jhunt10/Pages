class_name ActionDetailsControl
extends Control

@export var parent_card_control:ItemDetailsCard
@export var description_box:DescriptionBox
@export var target_type_label:Label
@export var cost_container:PageDetailsCard_CostContaienr
@export var range_display:MiniRangeDisplay
@export var damage_label:DamageLabelContainer
@export var damage_container:Container

@export var accuracy_icon:TextureRect
@export var accuracy_label:Label
@export var potency_icon:TextureRect
@export var potency_label:Label

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
	description_box.set_page_item(page, actor)
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
	
	if action.has_ammo(actor):
		cost_container.set_data(action.get_ammo_data())
		cost_container.show()
	else:
		cost_container.hide()
	
	if action.has_preview_damage():
		
		if actor and actor.pages.has_item(page.Id):
			var damage_datas = action.get_preview_damage_datas(actor)
			var dam_label = damage_label
			for dam_data in damage_datas.values():
				if dam_label == null:
					dam_label = damage_label.duplicate()
					damage_container.add_child(dam_label)
				dam_label.set_damage_data(dam_data, actor)
				dam_label = null
		else:
			var damage_datas = action.get_preview_damage_datas()
			var dam_label = damage_label
			for dam_data in damage_datas.values():
				if dam_label == null:
					dam_label = damage_label.duplicate()
					damage_container.add_child(dam_label)
				dam_label.set_damage_data(dam_data)
				dam_label = null
	else:
		damage_label.hide()
	
	var target_params = action.get_preview_target_params(actor)
	if target_params:
		target_type_label.text = TargetParameters.TargetTypes.keys()[target_params.target_type]
	
	var attack_details = action.get_load_val("AttackDetails", {})
	var accuracy_mod = attack_details.get('AccuracyMod', 1)
	if accuracy_mod == 1:
		accuracy_icon.hide()
		accuracy_label.hide()
	elif _actor:
		accuracy_label.text = str(accuracy_mod * _actor.stats.get_stat(StatHelper.Accuracy))
	else:
		accuracy_label.text = str(accuracy_mod * 100)
	
	var potency_mod = attack_details.get('PotencyMod', 1)
	if potency_mod == 1:
		potency_icon.hide()
		potency_label.hide()
	elif _actor:
		potency_label.text = str(potency_mod * _actor.stats.get_stat(StatHelper.Potency))
	else:
		potency_label.text = str(potency_mod * 100)
		

#func on_eqiup_button_pressed():
	#if _actor.equipment.has_item(_item.Id):
		#_actor.equipment.remove_equipment(_item)
	#elif _actor.equipment.can_equip_item(_item):
		#_actor.equipment.try_equip_item(_item, true)
	#parent_card_control.start_hide()
