class_name CharacterMenu_StatsTab
extends ScrollContainer

@export var parent_menu:Control
@export var tag_box:TagBox
@export var stat_labels:Array[StatLabelContainer]

@export var limit_effect_contaienr:LimitedEffectContainer

@export var block_container:Container
@export var block_chance_label:StatLabelContainer
@export var block_mod_label:StatLabelContainer

@export var main_weapon_damage_label:DamageLabelContainer
@export var off_weapon_damage_label:DamageLabelContainer
@export var damage_datas_container:Container
@export var range_display:MiniRangeDisplay

@export var resistances_container:CharacterMenu_ResistancesContainer

var _actor:BaseActor:
	get:
		if parent_menu:
			return parent_menu._actor
		else:
			return null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_weapon_damage_label.hide()
	self.visibility_changed.connect(sync)

func sync():
	if !self.visible:
		return
	if! _actor:
		return
	
	tag_box.set_tags(_actor.get_tags())
	for child in damage_datas_container.get_children():
		child.queue_free()
	var damage_datas = _actor.get_weapon_damage_datas()
	for damage_key in damage_datas.keys():
		var damage_data = damage_datas[damage_key]
		var damage_label = main_weapon_damage_label.duplicate()
		damage_label.set_damage_data(damage_data,_actor)
		damage_datas_container.add_child(damage_label)
		damage_label.show()
	
	var target_params = _actor.get_weapon_attack_target_params("Weapon")
	range_display.load_area_matrix(target_params.target_area)
	
	for stat_label in stat_labels:
		stat_label.mouse_over_parent = parent_menu
		stat_label.set_stat_values(_actor)
	limit_effect_contaienr.set_actor(_actor)
	
	var block_chance = _actor.stats.get_stat(StatHelper.BlockChance, -1)
	if block_chance != -1:
		block_container.show()
		block_chance_label.set_stat_values(_actor)
		block_mod_label.set_stat_values(_actor)
	else:
		block_container.hide()
	
	resistances_container.set_values(_actor)
