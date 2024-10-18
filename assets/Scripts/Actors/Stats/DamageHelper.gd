class_name DamageHelper

const STAT_BALENCE:int = 100
const ARMOR_STRETCH:float = 30
const ARMOR_SCALE:float = 80

static func handle_damage(attacker:BaseActor, defender:BaseActor, damage_data:Dictionary, source_tag_chain:SourceTagChain):
	var damage_type:String = damage_data['DamageType']
	var damage = DamageHelper.calc_damage(attacker, defender, damage_data, source_tag_chain)
	defender.stats.apply_damage(damage, damage_type, attacker)
	
	var damage_effect = damage_data.get("DamageEffect", null)
	if damage_effect:
		CombatRootControl.Instance.create_damage_effect(defender, damage_effect, damage)
	

static func calc_damage(attacker:BaseActor, defender:BaseActor, damage_data:Dictionary, source_tag_chain:SourceTagChain):
	var attack_stat_key = damage_data['AtkStat']
	var defense_stat_key = damage_data['DefStat']
	var base_damage = damage_data['BaseDamage']
	var damage_type = damage_data['DamageType']
	
	var attack_stat = attacker.stats.get_stat(attack_stat_key)
	var defense_stat = defender.stats.get_stat(defense_stat_key)
	var defense_armor = defender.stats.get_stat('Armor')
	var armor_reduction = calc_armor_reduction(defense_armor)
	
	var raw_damage = base_damage * armor_reduction * ((attack_stat + STAT_BALENCE) / (defense_stat + STAT_BALENCE))
	var temp_damage = raw_damage  
	
	var tags = source_tag_chain.get_all_tags()
	printerr("Damage Test: Tags: %s" % [tags])
	
	var attacker_damage_mods = attacker.effects.get_on_deal_damage_mods()
	attacker_damage_mods = _order_damage_mods(attacker_damage_mods)
	#for mod:BaseDamageMod in attacker_damage_mods:
		#damage = mod.apply_mod()
	
	return ceili(temp_damage)

static func _order_damage_mods(mods:Array):
	var add_list = []
	var scale_list = []
	var overridde_list = []
	for mod:BaseDamageMod in mods:
		if mod.mod_type == BaseDamageMod.ModTypes.Add:
			add_list.append(mod)
		if mod.mod_type == BaseDamageMod.ModTypes.Scale:
			scale_list.append(mod)
	add_list.append_array(scale_list)
	return add_list
	

static func calc_armor_reduction(armor)->float:
	var log_x = log(armor)
	var val = (log((armor+ARMOR_STRETCH)/ARMOR_STRETCH) / log(10)) * ARMOR_SCALE
	return 1-(val/100)
