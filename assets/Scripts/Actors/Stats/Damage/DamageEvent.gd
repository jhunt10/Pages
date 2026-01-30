class_name DamageEvent

const LOGGING = true

enum DefenseType {None, Armor, Ward}

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
var attack_power_range:int
var attack_power_scale:float
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

func _init(data:Dictionary, source_val, defender_val:BaseActor, tag_chain_val:SourceTagChain) -> void:
	self.source = source_val
	self.attacker = tag_chain_val.source_actor
	self.defender = defender_val
	self.source_tag_chain = tag_chain_val
	self.is_successful = true
	self.damage_data_key = data.get("DamageDataKey", "NOKEY")
	
	
	self.attack_stat = data.get("AtkStat", "Fixed")
	self.attack_power = data.get("AtkPwrBase", 100)
	self.attack_power_scale = data.get("AtkPwrScale", 1)
	self.attack_power_range = data.get("AtkPwrRange", 0)
	if data.has("AtkPwrStat") and source is BaseActor:
		self.attack_power = self.attack_power * source.stats.get_stat(data["AtkPwrStat"], 1)
	
	# Determine Base Damage from attack_stat
	# Fixed Damage or no Attack Stat
	if attack_stat == "Fixed" or attack_stat == "":
		self.base_damage = data.get("BaseDamage", 0)
	# Percent of Target's Health
	elif attack_stat.begins_with("Percent"):
		self.base_damage = defender.stats.max_health
	
	elif source is BaseActor:
		self.base_damage = source.stats.get_stat(attack_stat, 1)
	
	var damage_type_val = data.get("DamageType", null)
	if damage_type_val is String: self.damage_type = DamageTypes.get(damage_type_val, 0)
	elif damage_type_val is int and DamageTypes.has(damage_type_val): self.damage_type = damage_type_val
	else: printerr("DamageEvent: Unknown DamageTypes type")
	
	var defense_type_val = data.get("DefenseType", null)
	if defense_type_val == "AUTO":
		if DamageHelper.ElementalDamageTypes.has(self.damage_type):
			self.defense_type = DamageEvent.DefenseType.Ward
		elif DamageHelper.PhysicalDamageTypes.has(self.damage_type):
			self.defense_type = DamageEvent.DefenseType.Armor
		else:
			self.defense_type = DamageEvent.DefenseType.None
	elif defense_type_val is String:
		self.defense_type = DefenseType.get(defense_type_val, 0)
	elif defense_type_val is int and DefenseType.has(defense_type_val): 
		self.defense_type = defense_type_val
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
		"attack_power_range": attack_power_range,
		"attack_power_scale": attack_power_scale,
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
