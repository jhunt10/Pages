class_name DamageEvent

const LOGGING = true

enum DefenseType{None, Armor, Ward}

enum DamageTypes {	
	Test, RAW, Healing, Percent,
	Pierce, Slash, Blunt, Crash, # Usually negated by Armor
	Fire, Cold, Electric, Poison, # Usually negated by Ward
}

var game_state:GameStateData
var source
var defender:BaseActor
var source_tag_chain:SourceTagChain

var _attack_power:int
var _damage_variance:float

var damage_type:DamageTypes
var defense_type:DefenseType

var is_successful:bool
var base_damage:int
var raw_damage:float
var damage_after_armor:float
var damage_after_attack_mods:float
var damage_after_defend_mods:float
var final_damage:int

func _init(data:Dictionary, source, base_damage:int, defender:BaseActor, source_tag_chain:SourceTagChain, game_state:GameStateData) -> void:
	self.game_state = game_state
	self.source = source
	self.defender = defender
	self.source_tag_chain = source_tag_chain
	is_successful = true
	
	self.base_damage = base_damage
	_attack_power = data.get("AtkPower", 100)
	_damage_variance = data.get("DamageVarient", 0)
	
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
	#var attacker = event.attacker
	var defender = self.defender
	
	# Calc raw damage
	var attack_power:float = (float(self._attack_power)/100.0) + randf_range(-self._damage_variance, self._damage_variance)
	self.raw_damage = self.base_damage * attack_power
	
	# Get the defend's Armor or Ward
	var defense_armor = 0
	if self.defense_type == DamageEvent.DefenseType.Armor:
		defense_armor = defender.stats.get_stat('Armor')
	if self.defense_type == DamageEvent.DefenseType.Ward:
		defense_armor = defender.stats.get_stat('Ward')
	var armor_reduction = DamageHelper.calc_armor_reduction(defense_armor)
	self.damage_after_armor = self.raw_damage * armor_reduction
	
	# Get all tags that apply to the attack  and defense
	var attack_tags = self.source_tag_chain.get_all_tags()
	var defend_tags = defender.get_tags()
		
	
	# Get and apply all "OnDealDamage" mods from the attacker
	self.damage_after_attack_mods = self.damage_after_armor
	
	# Damage is coming from another actor
	if self.source is BaseActor:
		# Add Ally or Enemy tag
		var attacker = self.source as BaseActor
		if self.source.FactionIndex == defender.FactionIndex:
			attack_tags.append("Ally")
			defend_tags.append("Ally")
		else:
			attack_tags.append("Enemy")
			defend_tags.append("Enemy")
		var attacker_damage_mods = attacker.effects.get_on_deal_damage_mods()
		attacker_damage_mods = DamageHelper._order_damage_mods(attacker_damage_mods)
		for mod:BaseDamageMod in attacker_damage_mods:
			if mod.is_valid_in_case(false, attack_tags, defend_tags, self):
				self.damage_after_attack_mods = mod.apply_mod(self.damage_after_attack_mods, self)
	
	# Get and apply all "OnTakeDamage" mods from the defender
	self.damage_after_defend_mods = self.damage_after_attack_mods
	var defender_damage_mods = defender.effects.get_on_take_damage_mods()
	defender_damage_mods = DamageHelper._order_damage_mods(defender_damage_mods)
	for mod:BaseDamageMod in defender_damage_mods:
		if mod.is_valid_in_case(true, attack_tags, defend_tags, self):
			self.damage_after_defend_mods = mod.apply_mod(self.damage_after_defend_mods, self)
	if LOGGING:
		print("DamageHelper: base_damage: %s | raw_damage: %s | after_armor: %s" % [self.base_damage, self.raw_damage, self.damage_after_armor])
	self.final_damage = self.damage_after_defend_mods
