class_name DamageEvent

const LOGGING = false

enum DefenseType{None, Armor, Ward}

enum DamageTypes {	
	Test, RAW, Healing, Percent,
	Light, Dark, Chaos, Psycic,
	Pierce, Slash, Blunt, Crash, # Usually negated by Armor
	Fire, Ice, Electric, Poison, # Usually negated by Ward
}

var _been_calced
var source
var attacker:BaseActor
var defender:BaseActor
var source_tag_chain:SourceTagChain

var attack_stat:String
var attack_power:int
var damage_variance:float
var applied_power:float

var damage_type:DamageTypes
var defense_type:DefenseType
var defense_value:int
var defense_reduction:float

var is_successful:bool
var base_damage:int
var raw_damage:float
var damage_after_armor:float
var damage_after_attack_mods:float
var damage_after_defend_mods:float
var final_damage:int

func _init(data:Dictionary, source, defender:BaseActor, tag_chain:SourceTagChain, game_state:GameStateData) -> void:
	self.source = source
	self.attacker = tag_chain.source_actor
	self.defender = defender
	self.source_tag_chain = tag_chain
	self.is_successful = true
	self.attack_stat = data.get("AtkStat", "")
	self.attack_power = data.get("AtkPower", 100)
	self.damage_variance = data.get("DamageVarient", 0)
	
	if attack_stat == "Fixed":
		self.base_damage = data.get("BaseDamage", 0)
	elif attack_stat.begins_with("Percent"):
		self.base_damage = defender.stats.max_health
		if attack_stat.ends_with("PPR"):
			self.base_damage = defender.stats.max_health / max(defender.stats.get_stat("PPR"),1)
	
	var damage_type = data.get("DamageType", null)
	if damage_type is String: self.damage_type = DamageTypes.get(damage_type, 0)
	elif damage_type is int and DamageTypes.has(damage_type): self.damage_type = damage_type
	else: printerr("DamageEvent: Unknown DamageTypes type")
	
	var defense_type = data.get("DefenseType", null)
	if defense_type is String: self.defense_type = DefenseType.get(defense_type, 0)
	elif defense_type is int and DefenseType.has(defense_type): self.defense_type = defense_type
	else: printerr("DamageEvent: Unknown DefenseType type")
	
	_calc_damage_for_event()

func get_source_actor()->BaseActor:
	if source is BaseActor:
		return (source as BaseActor)
	if source.has("get_source_actor"):
		return source.get_source_actor()
	return null

func _calc_damage_for_event():
	if _been_calced:
		printerr("Attempted to _calc_damage_for_event on already completed damage event!")
		return
	_been_calced = true
	# Get all tags that apply to the attack  and defense
	var attack_tags = source_tag_chain.get_all_tags()
	var defend_tags = defender.get_tags()
	
	# Calc raw damage
	var float_power = float(attack_power)/100.0
	applied_power = (float_power + (float_power * randf_range(-damage_variance, damage_variance)))
	
	
	# Get the defend's Armor or Ward
	if defense_type == DamageEvent.DefenseType.Armor:
		defense_value = defender.stats.get_stat('Armor')
	if defense_type == DamageEvent.DefenseType.Ward:
		defense_value = defender.stats.get_stat('Ward')
	defense_reduction = DamageHelper.calc_armor_reduction(defense_value)
	
	raw_damage = base_damage * applied_power
	damage_after_armor = raw_damage * defense_reduction
	
	# Get and apply all "OnDealDamage" mods from the attacker
	damage_after_attack_mods = damage_after_armor
	if source is BaseActor:
		# Add Ally or Enemy tag
		var attacker = source as BaseActor
		if source.FactionIndex == defender.FactionIndex:
			attack_tags.append("Ally")
			defend_tags.append("Ally")
		else:
			attack_tags.append("Enemy")
			defend_tags.append("Enemy")
		var attacker_damage_mods = attacker.effects.get_on_deal_damage_mods()
		attacker_damage_mods = DamageHelper._order_damage_mods(attacker_damage_mods)
		for mod:BaseDamageMod in attacker_damage_mods:
			if mod.is_valid_in_case(false, attack_tags, defend_tags, self):
				damage_after_attack_mods = mod.apply_mod(damage_after_attack_mods, self)
	
	# Get and apply all "OnTakeDamage" mods from the defender
	damage_after_defend_mods = damage_after_attack_mods
	for mod:BaseDamageMod in DamageHelper._order_damage_mods(defender.effects.get_on_take_damage_mods()):
		if mod.is_valid_in_case(true, attack_tags, defend_tags, self):
			damage_after_defend_mods = mod.apply_mod(damage_after_defend_mods, self)
	
	if LOGGING: 
		print("DamageEvent: AtkPower: %s | Var: %s | Applied: %s | Raw Damage: %s" % [attack_power, damage_variance, applied_power, raw_damage])
		print("DamageEvent: Defense: %s | Value: %s | Reduction: %s" % [DamageEvent.DefenseType.keys()[defense_type], defense_value, defense_reduction])
		print("DamageEvent: base_damage: %s | raw_damage: %s | after_armor: %s" % [base_damage, raw_damage, damage_after_armor])
	
	final_damage = damage_after_defend_mods

func _get_percent_damage(data):
	return 0
