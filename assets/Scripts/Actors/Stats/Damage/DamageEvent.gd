class_name DamageEvent

enum DefenseType{None, Armor, Ward}

enum DamageTypes {	
	Test, RAW, Healing, Percent,
	Pierce, Slash, Blunt, Blast, # Usually negated by Armor
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
	_attack_power = data.get("AtkPower", 0)
	_damage_variance = data.get("DamageVarient", 0)
	
	var damage_type = data.get("DamageType", null)
	if damage_type is String: self.damage_type = DamageTypes.get(damage_type, 0)
	elif damage_type is int and DamageTypes.has(damage_type): self.damage_type = damage_type
	else: printerr("DamageEvent: Unknown DamageTypes type")
	
	var defense_type = data.get("DefenseType", null)
	if defense_type is String: self.defense_type = DefenseType.get(defense_type, 0)
	elif defense_type is int and DefenseType.has(defense_type): self.defense_type = defense_type
	else: printerr("DamageEvent: Unknown DefenseType type")
