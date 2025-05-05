class_name DamageEvent

const LOGGING = true

enum DefenseType{None, Armor, Ward}

enum DamageTypes {	
	Test, RAW, Healing, Percent,
	Light, Dark, Chaos, Psycic,
	Pierce, Slash, Blunt, Crash, # Usually negated by Armor
	Fire, Cold, Shock, Poison, # Usually negated by Ward
}

var source
var damage_data_key:String
var attacker:BaseActor
var defender:BaseActor
var source_tag_chain:SourceTagChain
var damage_mods:Dictionary

var attack_stat:String
var attack_power:int
var damage_variance:float
var applied_power:float

var damage_type:DamageTypes
var defense_type:DefenseType
var defense_value:int
var defense_reduction:float
var defender_resistance:float

var is_successful:bool
var base_damage:int
var raw_damage:float
var damage_after_armor:float
var damage_after_mods:float
var damage_after_resistance:float
var final_damage:int

var was_applied:bool # Damage has been applied to target

func _init(data:Dictionary, source, defender:BaseActor, tag_chain:SourceTagChain) -> void:
	self.source = source
	self.attacker = tag_chain.source_actor
	self.defender = defender
	self.source_tag_chain = tag_chain
	self.is_successful = true
	self.damage_data_key = data.get("DamageDataKey", "NOKEY")
	self.attack_stat = data.get("AtkStat", "Fixed")
	self.attack_power = data.get("AtkPower", 100)
	self.damage_variance = data.get("DamageVarient", 0)
	
	if attack_stat == "Fixed" or attack_stat == "":
		self.base_damage = data.get("BaseDamage", 0)
	elif attack_stat.begins_with("Percent"):
		self.base_damage = defender.stats.max_health
	elif source is BaseActor:
		self.base_damage = source.stats.get_stat(attack_stat, 1)
	
	var damage_type = data.get("DamageType", null)
	if damage_type is String: self.damage_type = DamageTypes.get(damage_type, 0)
	elif damage_type is int and DamageTypes.has(damage_type): self.damage_type = damage_type
	else: printerr("DamageEvent: Unknown DamageTypes type")
	
	var defense_type = data.get("DefenseType", null)
	if defense_type is String: self.defense_type = DefenseType.get(defense_type, 0)
	elif defense_type is int and DefenseType.has(defense_type): self.defense_type = defense_type
	else: printerr("DamageEvent: Unknown DefenseType type")
	
	#_calc_damage_for_event()

func add_damage_mod(damage_mod_data:Dictionary):
	var damage_mod_id = damage_mod_data['DamageModId']
	damage_mods[damage_mod_id] = damage_mod_data

func get_source_actor()->BaseActor:
	if source is BaseActor:
		return (source as BaseActor)
	if source.has("get_source_actor"):
		return source.get_source_actor()
	return null


func dictialize_self()->Dictionary:
	return {
		"_DamageDataKey": damage_data_key,
		"attacker": attacker.Id,
		"defender": defender.Id,
		"source_tag_chain": source_tag_chain.get_all_tags(),
		"damage_mods": damage_mods,
		"attack_stat": attack_stat,
		"attack_power": attack_power,
		"damage_variance": damage_variance,
		"applied_power": applied_power,
		"damage_type": damage_type,
		"defense_type": defense_type,
		"defense_value": defense_value,
		"defense_reduction": defense_reduction,
		"defender_resistance": defender_resistance,
		"is_successful": is_successful,
		"base_damage": base_damage,
		"raw_damage": raw_damage,
		"damage_after_armor": damage_after_armor,
		"damage_after_mods": damage_after_mods,
		"damage_after_resistance": damage_after_resistance,
		"final_damage": final_damage,
	}
