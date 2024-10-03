class_name DamageHelper

const STAT_BALENCE:int = 100
const ARMOR_STRETCH:int = 30
const ARMOR_SCALE:int = 80

static func calc_damage(attacker:BaseActor, defender:BaseActor, damage_data:Dictionary):
	var attack_stat_key = damage_data['AtkStat']
	var defense_stat_key = damage_data['DefStat']
	var base_damage = damage_data['BaseDamage']
	var damage_type = damage_data['DamageType']
	
	var attack_stat = attacker.stats.get_stat(attack_stat_key)
	var defense_stat = defender.stats.get_stat(defense_stat_key)
	var armor_reduction = calc_armor_reduction(defender.stats.get_stat('Armor'))
	
	var damage = base_damage * ((attack_stat + STAT_BALENCE) / (defense_stat + STAT_BALENCE))
	
	damage = damage * armor_reduction
	
	return ceili(damage)
	
static func calc_armor_reduction(armor)->float:
	var val = log((armor+ARMOR_STRETCH)/ARMOR_STRETCH) * ARMOR_SCALE
	return 1-(val/100)
