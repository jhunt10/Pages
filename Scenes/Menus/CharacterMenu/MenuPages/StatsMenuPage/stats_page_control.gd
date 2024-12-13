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
	_actor = actor
	_actor.stats.stats_changed.connect(_set_stats)
	_set_stats()
#
func _set_stats():
	strength_label.text = str(_actor.stats.get_stat("Strength", 0))
	agility_label.text = str(_actor.stats.get_stat("Agility", 0))
	intelligence_label.text = str(_actor.stats.get_stat("Intelligence", 0))
	wisdom_label.text = str(_actor.stats.get_stat("Wisdom", 0))
	
	bar_stats_container.set_actor(_actor)
	
	speed_stat_label.set_stat_values(_actor)
	mass_stat_label.set_stat_values(_actor)
	ppr_stat_label.set_stat_values(_actor)
	crash_stat_label.set_stat_values(_actor)
	accuracy_stat_label.set_stat_values(_actor)
	potency_stat_label.set_stat_values(_actor)
	
	var mag_attack = _actor.stats.get_base_magic_attack()
	var phy_attack = _actor.stats.get_base_phyical_attack()
	mag_atk_label.text = str(mag_attack)
	phys_atk_label.text = str(phy_attack)
	var primary_weapon = _actor.equipment.get_primary_weapon()
	if primary_weapon:
		var damage_data = primary_weapon.get_damage_data()
		var damage_var = damage_data.get("DamageVarient",1)
		range_display.load_area_matrix(primary_weapon.target_parmas.target_area)
		if damage_data.get("DefenseType", '') == "Ward":
			phy_atk_icon.hide()
			mag_atk_icon.show()
			main_hand_min_damage_label.text = str(phy_attack - (phy_attack * damage_var))
			main_hand_max_damage_label.text = str(phy_attack + (phy_attack * damage_var))
			main_hand_damage_type.text = damage_data.get("DamageType", "")
		else:
			phy_atk_icon.show()
			mag_atk_icon.hide()
			main_hand_min_damage_label.text = str(mag_attack - (mag_attack * damage_var))
			main_hand_max_damage_label.text = str(mag_attack + (mag_attack * damage_var))
			main_hand_damage_type.text = damage_data.get("DamageType", "")
	else:
		main_hand_min_damage_label.text = "--"
		main_hand_max_damage_label.text = "--"
		main_hand_damage_type.text = ""
	
	crit_mod_label.text = "+"+str(_actor.stats.get_stat("CritMod"))
	crit_chance_label.text = str(_actor.stats.get_stat("CritChance")) + "%  "
	
	armor_label.value_label.text = str(_actor.equipment.get_total_equipment_armor())
	ward_label.value_label.text = str(_actor.equipment.get_total_equipment_ward())
	evasion_stat_label.set_stat_values(_actor)
	protection_stat_label.set_stat_values(_actor)
	awareness_stat_label.set_stat_values(_actor)
	awareness_display.awareness = _actor.stats.get_stat("Awareness")
	block_chance_label.text = str(_actor.stats.get_stat("BlockChance")) +"%"
	block_mod_label.text = "-"+str(_actor.stats.get_stat("BlockMod"))
	var evd_front_val = DamageHelper.get_defense_stat_for_attack_direction(_actor, AttackEvent.AttackDirection.Front, "Evasion")
	evade_front_chance_label.text = str(evd_front_val)
	var evd_flank_val = DamageHelper.get_defense_stat_for_attack_direction(_actor, AttackEvent.AttackDirection.Flank, "Evasion")
	evade_flank_chance_label.text = str(evd_flank_val)
	var evd_back_val = DamageHelper.get_defense_stat_for_attack_direction(_actor, AttackEvent.AttackDirection.Back, "Evasion")
	evade_back_chance_label.text = str(evd_back_val)
	
	var blk_front_val = DamageHelper.get_defense_stat_for_attack_direction(_actor, AttackEvent.AttackDirection.Front, "BlockChance")
	block_front_chance_label.text = str(blk_front_val)
	var blk_flank_val = DamageHelper.get_defense_stat_for_attack_direction(_actor, AttackEvent.AttackDirection.Flank, "BlockChance")
	block_flank_chance_label.text = str(blk_flank_val)
	var val = DamageHelper.get_defense_stat_for_attack_direction(_actor, AttackEvent.AttackDirection.Back, "BlockChance")
	block_back_chance_label.text = str(val)
	
	#printerr("Bulding Stats")
	#block_evade_display.set_actor(_actor)
	#attack_stats_display.set_actor(_actor)
	#premade_stat_entry.hide()
	#for child in entry_container.get_children():
		#if child != premade_stat_entry:
			#child.queue_free()
	#for stat_name in _actor.stats._cached_stats.keys():
		#var new_entry:StatEntryContainer = premade_stat_entry.duplicate()
		#new_entry.set_stat(_actor, stat_name)
		#new_entry.show()
		#entry_container.add_child(new_entry)
	#scroll_bar.calc_bar_size()
