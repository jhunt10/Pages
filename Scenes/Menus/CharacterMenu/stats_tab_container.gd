class_name CharacterMenu_StatsTab
extends ScrollContainer

@export var menu_root:Control
@export var tag_box:TagBox
@export var stat_labels:Array[StatLabelContainer]

@export var block_container:Container
@export var block_chance_label:StatLabelContainer
@export var block_mod_label:StatLabelContainer

@export var main_weapon_damage_label:DamageLabelContainer
@export var off_weapon_damage_label:DamageLabelContainer
@export var damage_datas_container:Container
@export var range_display:MiniRangeDisplay

@export var resistances_container:CharacterMenu_ResistancesContainer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_weapon_damage_label.hide()
	pass # Replace with function body.

func sync(actor:BaseActor):
	tag_box.set_tags(actor.get_tags())
	for child in damage_datas_container.get_children():
		child.queue_free()
	var damage_datas = actor.get_weapon_damage_datas()
	for damage_key in damage_datas.keys():
		var damage_data = damage_datas[damage_key]
		var damage_label = main_weapon_damage_label.duplicate()
		damage_label.set_damage_data(damage_data,actor)
		damage_datas_container.add_child(damage_label)
		damage_label.show()
	
	var target_params = actor.get_weapon_attack_target_params("Weapon")
	range_display.load_area_matrix(target_params.target_area)
	
	for stat_label in stat_labels:
		stat_label.mouse_over_parent = menu_root
		stat_label.set_stat_values(actor)
	
	var block_chance = actor.stats.get_stat(StatHelper.BlockChance, -1)
	if block_chance != -1:
		block_container.show()
		block_chance_label.set_stat_values(actor)
		block_mod_label.set_stat_values(actor)
	else:
		block_container.hide()
	
	resistances_container.set_values(actor)
