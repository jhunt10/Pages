class_name DamageEvent

enum DefenseType{None, Armor, Resist}

enum DamageTypes {	
	Test, RAW, Healing, Percent,
	Pierce, Slash, Blunt, Blast, # Usually negated by Armor
	Fire, Cold, Electric, Poison, # Usually negated by Resist
}

var game_state:GameStateData
var attacker:BaseActor
var defender:BaseActor
var source_tag_chain:SourceTagChain
var base_damage:int
var attack_stat:String
var damage_type:DamageTypes
var defense_type:DefenseType

var raw_damage:float
var damage_after_armor:float
var damage_after_attack_mods:float
var damage_after_defend_mods:float
var final_damage:int

func _init(attacker:BaseActor, defender:BaseActor, source_tag_chain:SourceTagChain, game_state:GameStateData,
			base_damage:int, attack_stat:String, damage_type, defense_type) -> void:
	self.game_state = game_state
	self.attacker = attacker
	self.defender = defender
	self.source_tag_chain = source_tag_chain
	self.base_damage = base_damage
	self.attack_stat = attack_stat
	
	if damage_type is String: self.damage_type = DamageTypes.get(damage_type, 0)
	elif damage_type is int and DamageTypes.has(damage_type): self.damage_type = damage_type
	else: printerr("DamageEvent: Unknown DamageTypes type")
	
	if defense_type is String: self.defense_type = DefenseType.get(defense_type, 0)
	elif defense_type is int and DefenseType.has(defense_type): self.defense_type = defense_type
	else: printerr("DamageEvent: Unknown DefenseType type")
