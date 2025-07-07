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
@export var health_stat_label:StatLabelContainer

@export var mag_atk_label:StatLabelContainer
@export var phys_atk_label:StatLabelContainer
@export var phy_atk_icon:TextureRect
@export var mag_atk_icon:TextureRect
@export var accuracy_stat_label:StatLabelContainer
@export var potency_stat_label:StatLabelContainer
@export var range_display:MiniRangeDisplay

@export var main_hand_damage_label:DamageLabelContainer
@export var other_hand_damage_label:DamageLabelContainer

@export var crit_mod_label:Label
@export var crit_chance_label:Label

@export var armor_label:StatLabelContainer
@export var ward_label:StatLabelContainer
@export var evasion_stat_label:StatLabelContainer
@export var protection_stat_label:StatLabelContainer
@export var awareness_stat_label:StatLabelContainer
@export var awareness_display:MiniAwarenessDisplay
@export var block_chance_label:StatLabelContainer
@export var block_mod_label:StatLabelContainer
@export var evade_front_chance_label:Label
@export var evade_flank_chance_label:Label
@export var evade_back_chance_label:Label
@export var block_front_chance_label:Label
@export var block_flank_chance_label:Label
@export var block_back_chance_label:Label

@export var full_stat_display:FullStatDisplayControl

var _actor:BaseActor

func set_actor(actor:BaseActor):
	if _actor and actor != _actor:
		_actor.stats_changed.disconnect(_set_stats)
	if actor != _actor:
		actor.stats_changed.connect(_set_stats)
	_actor = actor
	if full_stat_display:
		full_stat_display.set_actor(_actor)
	_set_stats()
#
func _set_stats():
	strength_label.text = str(_actor.stats.get_stat(StatHelper.Strength, 0))
	agility_label.text = str(_actor.stats.get_stat(StatHelper.Agility, 0))
	intelligence_label.text = str(_actor.stats.get_stat(StatHelper.Intelligence, 0))
	wisdom_label.text = str(_actor.stats.get_stat(StatHelper.Wisdom, 0))
	
	#bar_stats_container.set_actor(_actor)
	
	speed_stat_label.set_stat_values(_actor)
	mass_stat_label.set_stat_values(_actor)
	ppr_stat_label.set_stat_values(_actor)
	health_stat_label.set_stat_values(_actor)
	accuracy_stat_label.set_stat_values(_actor)
	potency_stat_label.set_stat_values(_actor)
	phys_atk_label.set_stat_values(_actor)
	mag_atk_label.set_stat_values(_actor)
	
	var target_params = _actor.get_weapon_attack_target_params("Weapon")
	
	var mag_attack = _actor.stats.get_stat(StatHelper.MagAttack)
	var phy_attack = _actor.stats.get_stat(StatHelper.PhyAttack)
	range_display.load_area_matrix(target_params.target_area)
	#mag_atk_label.text = str(mag_attack)
	#phys_atk_label.text = str(phy_attack)
	#var primary_weapon = _actor.equipment.get_primary_weapon()
	#if primary_weapon:
		#var damage_data = primary_weapon.get_damage_data()
		#var damage_var = damage_data.get("AtkPwrRange",1)
	
	var damage_datas = _actor.get_weapon_damage_datas(
		{
			"IncludeSlots": [ "Primary", "OffHand" ],
			"FallbackToUnarmed": true, 
			"LimitRangeMelee": "Either"
	})
	if damage_datas.keys().size() > 0:
		main_hand_damage_label.set_damage_data(damage_datas.values()[0], _actor)
		if not main_hand_damage_label.visible:
			main_hand_damage_label.hide()
	else:
		main_hand_damage_label.hide()
		
	if damage_datas.keys().size() > 1:
		other_hand_damage_label.set_damage_data(damage_datas.values()[1], _actor)
		if not other_hand_damage_label.visible:
			other_hand_damage_label.hide()
	else:
		other_hand_damage_label.hide()
		
	crit_mod_label.text = str(_actor.stats.get_stat(StatHelper.CritMod))
	crit_chance_label.text = str(_actor.stats.get_stat(StatHelper.CritChance)) + "%"
	
	armor_label.set_stat_values(_actor)
	ward_label.set_stat_values(_actor)
	#armor_label.value_label.text = str(_actor.stats.get_stat("Armor", 0))
	#ward_label.value_label.text = str(_actor.equipment.get_total_equipment_ward())
	evasion_stat_label.set_stat_values(_actor)
	protection_stat_label.set_stat_values(_actor)
	awareness_stat_label.set_stat_values(_actor)
	awareness_display.awareness = _actor.stats.get_stat(StatHelper.Awareness)
	
	block_chance_label.set_stat_values(_actor)
	block_mod_label.set_stat_values(_actor)
	#var block_chc = _actor.stats.get_stat(StatHelper.BlockChance)
	#if block_chc > 0:
		#block_chance_label.text = str(block_chc) +"%"
		#block_mod_label.text = str(_actor.stats.get_stat(StatHelper.BlockMod, 1))
	#else:
		#block_chance_label.text = "--%"
		#block_mod_label.text = "1.0"
	var evd_front_val = StatHelper.get_defense_stat_for_attack_direction(_actor, AttackHandler.AttackDirection.Front, StatHelper.Evasion)
	evade_front_chance_label.text = str(evd_front_val)
	var evd_flank_val = StatHelper.get_defense_stat_for_attack_direction(_actor, AttackHandler.AttackDirection.Flank, StatHelper.Evasion)
	evade_flank_chance_label.text = str(evd_flank_val)
	var evd_back_val = StatHelper.get_defense_stat_for_attack_direction(_actor, AttackHandler.AttackDirection.Back, StatHelper.Evasion)
	evade_back_chance_label.text = str(evd_back_val)
	
	var blk_front_val = StatHelper.get_defense_stat_for_attack_direction(_actor, AttackHandler.AttackDirection.Front, StatHelper.BlockChance)
	block_front_chance_label.text = str(blk_front_val)
	var blk_flank_val = StatHelper.get_defense_stat_for_attack_direction(_actor, AttackHandler.AttackDirection.Flank, StatHelper.BlockChance)
	block_flank_chance_label.text = str(blk_flank_val)
	var val = StatHelper.get_defense_stat_for_attack_direction(_actor, AttackHandler.AttackDirection.Back, StatHelper.BlockChance)
	block_back_chance_label.text = str(val)
	
