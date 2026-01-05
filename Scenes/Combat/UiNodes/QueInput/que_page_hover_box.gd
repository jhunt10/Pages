class_name QuePageHoverBox
extends Control

@export var backpatch:BackPatchContainer
@export var title_label:FitScaleLabel
@export var description_box:DescriptionBox
@export var target_type_label:Label
@export var current_ammo_label:Label
@export var cost_container:PageDetailsCard_CostContaienr
@export var damage_label:DamageLabelContainer
@export var damage_container:Container

@export var ammo_acc_pot_container:Container
@export var accuracy_icon:TextureRect
@export var accuracy_label:Label
@export var potency_icon:TextureRect
@export var potency_label:Label

@export var ammo_acc_pot_line:ColorRect
@export var damage_line:ColorRect

var _cached_box_size

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if backpatch:
		var patch_size = backpatch.size
		if patch_size != _cached_box_size:
			_cached_box_size = patch_size
			backpatch.position = Vector2i(-_cached_box_size.x / 2, -_cached_box_size.y - 8)
	pass


func set_action(actor:BaseActor, page_item:BasePageItem):
	var action = page_item as PageItemAction
	if actor.pages.has_action(action.ActionKey):
		action = actor.pages.get_action_page(action.ActionKey)
	var title = action.get_display_name()
	title_label.text = title
	title_label._size_dirty = true
	description_box.set_page_item(action, actor)
	
	
	if action.get_tags().has("Attack") or action.has_ammo(actor):
		# Ammo
		if action.has_ammo(actor):
			cost_container.set_data(action, actor)
			cost_container.show()
			if current_ammo_label:
				current_ammo_label.text = str(actor.Que.get_page_ammo_current_uses(action.ActionKey))
		else:
			cost_container.hide()
		
		var attack_details = action.get_attack_details()
		var accuracy_mod = attack_details.get('AccuracyMod', 1)
		var potency_mod = attack_details.get('PotencyMod', 1)
		accuracy_label.text = str(accuracy_mod * actor.stats.get_stat(StatHelper.Accuracy))
		potency_label.text = str(potency_mod * actor.stats.get_stat(StatHelper.Potency))
		ammo_acc_pot_container.show()
		ammo_acc_pot_line.show()
	else:
		ammo_acc_pot_container.hide()
		ammo_acc_pot_line.hide()
	
	# Damage
	if action.has_preview_damage():
		damage_line.show()
		var damage_datas = action.get_preview_damage_datas(actor)
		var dam_label = damage_label
		var merged_counts = {}
		for dam_data in damage_datas.values():
			var hash_val = hash(dam_data)
			if not merged_counts.has(hash_val):
				merged_counts[hash_val] = {"Value": dam_data, "Count": 1}
			else:
				merged_counts[hash_val]['Count'] += 1
		for merged_data in merged_counts.values():
			if dam_label == null:
				dam_label = damage_label.duplicate()
				damage_container.add_child(dam_label)
			dam_label.set_damage_data(merged_data['Value'], actor, merged_data['Count'])
			dam_label.show()
			dam_label = null
	else:
		damage_label.hide()
		damage_line.hide()
	
	var target_params = action.get_preview_target_params(actor)
	if target_params:
		target_type_label.text = TargetParameters.TargetTypes.keys()[target_params.target_type]
	
	
func show_self():
	self.visible = true
	title_label._size_dirty = true
