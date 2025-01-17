class_name StatsPageControl
extends Control

#@export var premade_stat_entry:StatEntryContainer
#@export var entry_container:Container
#@export var scroll_bar:CustScrollBar

#@export var block_evade_display:BlockEvadeStatEntry
#@export var attack_stats_display:AttackStatsDisplayControl

@export var strength_label:Label
@export var agility_label:Label
@export var intelligence_label:Label
@export var wisdom_label:Label

@export var bar_stats_container:BarStatsDisplayContainer

@export var speed_stat_label:StatLabelContainer
@export var mass_stat_label:StatLabelContainer
@export var ppr_stat_label:StatLabelContainer
@export var crash_stat_label:StatLabelContainer

@export var mag_atk_label:Label
@export var phys_atk_label:Label
@export var phy_atk_icon:TextureRect
@export var mag_atk_icon:TextureRect
@export var accuracy_stat_label:StatLabelContainer
@export var potency_stat_label:StatLabelContainer
@export var range_display:MiniRangeDisplay
@export var main_hand_min_damage_label:Label
@export var main_hand_max_damage_label:Label
@export var main_hand_damage_type:Label

@export var off_hand_damage_container:Container
@export var off_hand_min_damage_label:Label
@export var off_hand_max_damage_label:Label
@export var off_hand_damage_type:Label

@export var crit_mod_label:Label
@export var crit_chance_label:Label

@export var armor_label:StatLabelContainer
@export var ward_label:StatLabelContainer
@export var evasion_stat_label:StatLabelContainer
@export var protection_stat_label:StatLabelContainer
@export var awareness_stat_label:StatLabelContainer
@export var awareness_display:MiniAwarenessDisplay
@export var block_chance_label:Label
@export var block_mod_label:Label
@export var evade_front_chance_label:Label
@export var evade_flank_chance_label:Label
@export var evade_back_chance_label:Label
@export var block_front_chance_label:Label
@export var block_flank_chance_label:Label
@export var block_back_chance_label:Label



var _actor:BaseActor

func set_actor(actor:BaseActor):
	if _actor and actor != _actor:
		_actor.stats.stats_changed.disconnect(_set_stats)
	if actor != _actor:
		actor.stats.stats_changed.connect(_set_stats)
	_actor = actor
	_set_stats()
#
func _set_stats():
	strength_label.text = str(_actor.stats.get_stat(StatHelper.Strength, 0))
	agility_label.text = str(_actor.stats.get_stat(StatHelper.Agility, 0))
	intelligence_label.text = str(_actor.stats.get_stat(StatHelper.Intelligence, 0))
	wisdom_label.text = str(_actor.stats.get_stat(StatHelper.Wisdom, 0))
	
	bar_stats_container.set_actor(_actor)
	
	speed_stat_label.set_stat_values(_actor)
	mass_stat_label.set_stat_values(_actor)
	ppr_stat_label.set_stat_values(_actor)
	crash_stat_label.set_stat_values(_actor)
	accuracy_stat_label.set_stat_values(_actor)
	potency_stat_label.set_stat_values(_actor)
	
	var target_params = _actor.get_default_attack_target_params()
	
	var mag_attack = _actor.stats.get_stat(StatHelper.MagAttack)
	var phy_attack = _actor.stats.get_stat(StatHelper.PhyAttack)
	range_display.load_area_matrix(target_params.target_area)
	mag_atk_label.text = str(mag_attack)
	phys_atk_label.text = str(phy_attack)
	#var primary_weapon = _actor.equipment.get_primary_weapon()
	#if primary_weapon:
		#var damage_data = primary_weapon.get_damage_data()
		#var damage_var = damage_data.get("DamageVarient",1)
		
	for damage_data in _actor.get_default_attack_damage_datas().values():
		var attack_stat = damage_data.get("AtkStat")
		var base_damage = _actor.stats.base_damge_from_stat(attack_stat)
		var damage_var = damage_data.get("DamageVarient",0)
		if damage_data.get("DefenseType", '') == "Ward":
			phy_atk_icon.hide()
			mag_atk_icon.show()
		else:
			phy_atk_icon.show()
			mag_atk_icon.hide()
		main_hand_min_damage_label.text = str(base_damage - (base_damage * damage_var))
		main_hand_max_damage_label.text = str(base_damage + (base_damage * damage_var))
		main_hand_damage_type.text = damage_data.get("DamageType", "")
	#else:
		#main_hand_min_damage_label.text = "--"
		#main_hand_max_damage_label.text = "--"
		#main_hand_damage_type.text = ""
	
	crit_mod_label.text = str(_actor.stats.get_stat(StatHelper.CritMod))
	crit_chance_label.text = str(_actor.stats.get_stat(StatHelper.CritChance)) + "%"
	
	armor_label.value_label.text = str(_actor.equipment.get_total_equipment_armor())
	ward_label.value_label.text = str(_actor.equipment.get_total_equipment_ward())
	evasion_stat_label.set_stat_values(_actor)
	protection_stat_label.set_stat_values(_actor)
	awareness_stat_label.set_stat_values(_actor)
	awareness_display.awareness = _actor.stats.get_stat(StatHelper.Awareness)
	var block_chc = _actor.stats.get_stat(StatHelper.BlockChance)
	if block_chc > 0:
		block_chance_label.text = str(block_chc) +"%"
		block_mod_label.text = str(_actor.stats.get_stat(StatHelper.BlockMod, 1))
	else:
		block_chance_label.text = "--%"
		block_mod_label.text = "1.0"
	var evd_front_val = StatHelper.get_defense_stat_for_attack_direction(_actor, AttackEvent.AttackDirection.Front, StatHelper.Evasion)
	evade_front_chance_label.text = str(evd_front_val)
	var evd_flank_val = StatHelper.get_defense_stat_for_attack_direction(_actor, AttackEvent.AttackDirection.Flank, StatHelper.Evasion)
	evade_flank_chance_label.text = str(evd_flank_val)
	var evd_back_val = StatHelper.get_defense_stat_for_attack_direction(_actor, AttackEvent.AttackDirection.Back, StatHelper.Evasion)
	evade_back_chance_label.text = str(evd_back_val)
	
	var blk_front_val = StatHelper.get_defense_stat_for_attack_direction(_actor, AttackEvent.AttackDirection.Front, StatHelper.BlockChance)
	block_front_chance_label.text = str(blk_front_val)
	var blk_flank_val = StatHelper.get_defense_stat_for_attack_direction(_actor, AttackEvent.AttackDirection.Flank, StatHelper.BlockChance)
	block_flank_chance_label.text = str(blk_flank_val)
	var val = StatHelper.get_defense_stat_for_attack_direction(_actor, AttackEvent.AttackDirection.Back, StatHelper.BlockChance)
	block_back_chance_label.text = str(val)
	
