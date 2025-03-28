class_name DamageEvent

const LOGGING = true

enum DefenseType{None, Armor, Ward}

enum DamageTypes {	
	Test, RAW, Healing, Percent,
	Light, Dark, Chaos, Psycic,
	Pierce, Slash, Blunt, Crash, # Usually negated by Armor
	Fire, Cold, Shock, Poison, # Usually negated by Ward
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
var damage_after_resistance:float
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
		#if attack_stat.ends_with("PPR"):
			#self.base_damage = defender.stats.max_health / max(defender.stats.get_stat("PPR"),1)
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
	
	if attacker.FactionIndex == defender.FactionIndex:
		attack_tags.append("Ally")
		defend_tags.append("Ally")
	else:
		attack_tags.append("Enemy")
		defend_tags.append("Enemy")
	
	var applied_damage_mods = _get_applied_damage_mods(attack_tags, defend_tags)
	
	
	# --- Damage Calc Order ---
	# 1) Get applied power from damage_variance
	# 2) Raw damage = attack_power * applied power
	# 3) Apply DamageType Resistances
	# 4) Apply Armor/Ward resuction
	# 5) Apply Attacker's "OnDealDamage" mods
	# 6) Apply Defender's "OnTakeDamage" mods
	
	# Calc raw damage
	var float_power = float(attack_power)/100.0
	applied_power = (float_power + (float_power * randf_range(-damage_variance, damage_variance)))
	
	# Get Damage Resistance
	var defender_resistance = defender.stats.get_damage_resistance(damage_type)
	var resistance_mods = applied_damage_mods.get("Resistance", [])
	defender_resistance = _apply_mods_to_value(defender_resistance, resistance_mods)
	var resistance_reduction = 1.0 - (defender_resistance / 100)
	
	# Get the defend's Armor or Ward
	if defense_type == DamageEvent.DefenseType.Armor:
		defense_value = defender.stats.get_stat('Armor')
	if defense_type == DamageEvent.DefenseType.Ward:
		defense_value = defender.stats.get_stat('Ward')
	defense_reduction = DamageHelper.calc_armor_reduction(defense_value)
	
	raw_damage = base_damage * applied_power
	damage_after_resistance = raw_damage * resistance_reduction
	damage_after_armor = damage_after_resistance * defense_reduction
	
	
	#if source is BaseActor:
		## Get and apply all "OnDealDamage" mods from the attacker
		#damage_after_attack_mods = damage_after_armor
		#attacker_damage_mods = DamageHelper._order_damage_mods(attacker_damage_mods)
		#for mod in attacker_damage_mods:
			#if mod.is_valid_in_case(false, attack_tags, defend_tags, self):
				#damage_after_attack_mods = mod.apply_mod(damage_after_attack_mods, self)
	#else:
	damage_after_attack_mods = damage_after_armor
	
	# Get and apply all "OnTakeDamage" mods from the defender
	damage_after_defend_mods = damage_after_attack_mods
	for mod in DamageHelper._order_damage_mods(defender.effects.get_on_take_damage_mods()):
		if mod.is_valid_in_case(true, attack_tags, defend_tags, self):
			damage_after_defend_mods = mod.apply_mod(damage_after_defend_mods, self)
	
	#final_damage = damage_after_defend_mods
	if damage_after_defend_mods > 0:
		final_damage = max(1,damage_after_defend_mods)
	else:
		final_damage = min(-1,damage_after_defend_mods)
	
	if LOGGING: 
		print("--- Damage Event: --- ")
		print("- BaseDamage: %s " % [self.base_damage])
		print("- AtkPower: %s | Var: %s | Applied Power: %s" % [self.attack_power, self.damage_variance, applied_power])
		print("- RawDamage: %s " % [raw_damage])
		print("- Damage Type: %s | Resist: %s | Reduc: %s | After Res: %s " % [DamageEvent.DamageTypes.keys()[damage_type], defender_resistance, resistance_reduction, damage_after_resistance])
		print("- Defence Type: %s | Value: %s | Reduc: %s |  After Armor: %s " % [DamageEvent.DefenseType.keys()[defense_type], defense_value, defense_reduction, damage_after_armor])
		print("- Final Damage: %s " % [final_damage])
		print("--------------------- ")
	

func _get_percent_damage(data):
	return 0


func _get_applied_damage_mods(attack_tags, defend_tags)->Dictionary:
	var all_damage_mods = []
	all_damage_mods.append_array(defender.get_damage_mods(true))
	all_damage_mods.append_array(attacker.get_damage_mods(false))
	var applied_damage_mods = {}
	for mod_data in all_damage_mods:
		var condition_data = mod_data.get("Conditions")
		if condition_data.has("DamageType"):
			if condition_data['DamageType'] != DamageTypes.keys()[damage_type]:
				continue
		if condition_data.has("LimitSourceTags"):
			var required_tags = condition_data['LimitSourceTags']
			if not SourceTagChain.tags_include_all_in_array(required_tags, attack_tags):
				continue
		if condition_data.has("ExcludeSourceTags"):
			var forbidden_tags = condition_data['ExcludeSourceTags']
			if SourceTagChain.tags_include_any_in_array(forbidden_tags, attack_tags):
				continue
		if condition_data.has("LimitDefenderTags"):
			var required_tags = condition_data['LimitDefenderTags']
			if not SourceTagChain.tags_include_all_in_array(required_tags, defend_tags):
				continue
		if condition_data.has("ExcludeDefenderTags"):
			var forbidden_tags = condition_data['ExcludeDefenderTags']
			if SourceTagChain.tags_include_any_in_array(forbidden_tags, defend_tags):
				continue
		var mod_prop = mod_data.get("ModProperty", "")
		if not applied_damage_mods.keys().has(mod_prop):
			applied_damage_mods[mod_prop] = []
		applied_damage_mods[mod_prop].append(mod_data)
	return applied_damage_mods

func _apply_mods_to_value(base_value:float, mods:Array)->float:
	var add_to = 0.0
	var scale_by = 1.0
	for mod in mods:
		if mod.get("ModType") == "Add":
			add_to += mod.get("Value", 0)
		if mod.get("ModType") == "Scale":
			scale_by *= mod.get("Value", 1)
	return (base_value + add_to) * scale_by
	
