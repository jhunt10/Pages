class_name DamageHelper

const STAT_BALENCE:int = 100
const ARMOR_STRETCH:float = 30
const ARMOR_SCALE:float = 80

static func handle_damage(attacker:BaseActor, defender:BaseActor, damage_data:Dictionary):
	var damage_type:String = damage_data['DamageType']
	var damage = DamageHelper.calc_damage(attacker, defender, damage_data)
	defender.stats.apply_damage(damage, damage_type, attacker)
	
	var damage_effect = damage_data.get("DamageEffect", null)
	if damage_effect:
		CombatRootControl.Instance.create_damage_effect(defender, damage_effect, damage)
	

static func calc_damage(attacker:BaseActor, defender:BaseActor, damage_data:Dictionary):
	var attack_stat_key = damage_data['AtkStat']
	var defense_stat_key = damage_data['DefStat']
	var base_damage = damage_data['BaseDamage']
	var damage_type = damage_data['DamageType']
	
	var attack_stat = attacker.stats.get_stat(attack_stat_key)
	var defense_stat = defender.stats.get_stat(defense_stat_key)
	var defense_armor = defender.stats.get_stat('Armor')
	var armor_reduction = calc_armor_reduction(defense_armor)
	
	var damage = base_damage * ((attack_stat + STAT_BALENCE) / (defense_stat + STAT_BALENCE))
	
	damage = damage * armor_reduction
	
	return ceili(damage)
	
static func calc_armor_reduction(armor)->float:
	var log_x = log(armor)
	var val = (log((armor+ARMOR_STRETCH)/ARMOR_STRETCH) / log(10)) * ARMOR_SCALE
	return 1-(val/100)
