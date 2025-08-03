class_name StatHelper

enum CoreStats {Strength, Agility, Intelligence, Wisdom}

const StatBarColors:Dictionary = {
	"Health": Color.RED,
	"Mana": Color.DEEP_SKY_BLUE,
	"Stamina": Color.GREEN
}


## Every Actor is exspected to have these stats
const BasicStats:Array = [
	HealthMax, HealthCurrent, Mass, Speed, Push, PPR,
	Armor, Ward, 
	Accuracy, Evasion, Potency, Protection,
	Awareness, CritChance, CritMod, BlockChance, BlockMod,
	BlocksLOS
]
const Level = "Level"
const Experience = "Experience"
const Strength = "Strength"
const Agility = "Agility"
const Intelligence = "Intelligence"
const Wisdom = "Wisdom"
const HealthMax = "HealthMax"
const HealthCurrent = "HealthCur"
const Mass = "Mass"
const Speed = "Speed"
const Push = "Push"
const PPR = "PPR"
const PhyAttack = "PhyAttack"
const MagAttack = "MagAttack"
const Armor = "Armor"
const Ward = "Ward"
const Awareness = "Awareness"
const Accuracy = "Accuracy"
const Evasion = "Evasion"
const Potency = "Potency"
const Protection = "Protection"

const CritChance = "CritChance"
const CritMod = "CritMod"

const BlockChance = "BlockChance"
const BlockMod = "BlockMod"

const BlocksLOS = "BlocksLOS"
const AggroMod = "AggroMod"

const stat_abbrs:Dictionary = {
	PhyAttack: "PHY ATK",
	MagAttack: "MAG ATK",
	Strength: "STR",
	Agility: "AGL",
	Intelligence: "INT",
	Wisdom: "WIS",
	Mass: "MAS",
	Speed: "SPD",
	Armor: "ARM",
	Ward: "WRD",
	Awareness: "AWR",
	Accuracy: "ACC",
	Evasion: "EVS",
	Potency: "POT",
	Protection: "PRO",
	
	CritChance: "CrtC",
	CritMod: "CrtM",
	BlockChance: "BlkC",
	BlockMod: "BlkM"
}

const stat_icon_paths:Dictionary = {
	"BarStat": "res://assets/Sprites/UI/SymbolIcons/BarStatSymbol.png",
	HealthCurrent: "res://assets/Sprites/UI/SymbolIcons/HealthSymbol.png",
	HealthMax: "res://assets/Sprites/UI/SymbolIcons/HealthSymbol.png",
	PhyAttack: "res://assets/Sprites/UI/SymbolIcons/PhyDamageSymbol.png",
	MagAttack: "res://assets/Sprites/UI/SymbolIcons/MagDamageSymbol.png",
	Strength: "res://assets/Sprites/UI/SymbolIcons/_S_Symbole.png",
	Agility: "res://assets/Sprites/UI/SymbolIcons/_A_Symbole.png",
	Intelligence: "res://assets/Sprites/UI/SymbolIcons/_I_Symbole.png",
	Wisdom: "res://assets/Sprites/UI/SymbolIcons/_W_Symbole.png",
	Mass: "res://assets/Sprites/UI/SymbolIcons/MassSymbol.png",
	Speed: "res://assets/Sprites/UI/SymbolIcons/SpeedSymbol.png",
	Armor: "res://assets/Sprites/UI/SymbolIcons/ArmorSymbol.png",
	Ward: "res://assets/Sprites/UI/SymbolIcons/WardSymbol.png",
	Awareness: "res://assets/Sprites/UI/SymbolIcons/AwarenessSymbol.png",
	Accuracy: "res://assets/Sprites/UI/SymbolIcons/AccuracySymbol.png",
	Evasion: "res://assets/Sprites/UI/SymbolIcons/EvasionSymbol.png",
	Potency: "res://assets/Sprites/UI/SymbolIcons/PotencySymbol.png",
	Protection: "res://assets/Sprites/UI/SymbolIcons/ProtectionSymbol.png",
	PPR: "res://assets/Sprites/UI/SymbolIcons/PPRSymbol.png",
	
	CritChance: "res://assets/Sprites/UI/SymbolIcons/CriticalSymbol.png",
	CritMod: "res://assets/Sprites/UI/SymbolIcons/CriticalSymbol.png"
}

static func get_stat_abbr(stat_name:String)->String:
	if stat_name.begins_with("Resistance:"):
		var damage_type = stat_name.trim_prefix("Resistance:")
		return damage_type + " Dmg Resist"
	if stat_name.begins_with("LmtEftCount:"):
		var limited_effect_type = stat_name.trim_prefix("LmtEftCount:")
		return "Max " + limited_effect_type + " Count"
	return stat_abbrs.get(stat_name, stat_name)

static func get_stat_icon(stat_name:String)->Texture2D:
	var path = stat_icon_paths.get(stat_name)
	if path:
		return SpriteCache.get_sprite(path)
	return null



### Added to stat_name ("StatName:SUFIX") to mod value when defending against attack from Front
#const DirectionalDefenseSufix_Front = "DirDefFr"
### Added to stat_name ("StatName:SUFIX") to mod value when defending against attack from Flank
#const DirectionalDefenseSufix_Flank = "DirDefFl"
### Added to stat_name ("StatName:SUFIX") to mod value when defending against attack from Back
#const DirectionalDefenseSufix_Back = "DirDefBk"
### Added to stat_name ("StatName:SUFIX") to mod value when attacking from Front
#const DirectionalAttackSufix_Front = "DirAtkFr"
### Added to stat_name ("StatName:SUFIX") to mod value when attacking from Flank
#const DirectionalAttackSufix_Flank = "DirAtkFl"
### Added to stat_name ("StatName:SUFIX") to mod value when attacking from Back
#const DirectionalAttackSufix_Back = "DirAtkBk"

const DirectionalMod_Front = "DirMod_Front"
const DirectionalMod_Flank = "DirMod_Flank"
const DirectionalMod_Back = "DirMod_Back"
const DirectionalMod_Aoe = "DirMod_Aoe"
const DirectionalSubsitute_Aoe = "DirSub_Aoe"

## Directionaly modded Stats are in form of "DirMod_Flank:STATNAME". 
## If no cached stat is found with exact name, default DirMod_ stats are used to scale STATNAME
static func get_defense_stat_for_attack_direction(actor:BaseActor, attack_dir, stat_name:String)->float:
	
	if attack_dir == AttackHandler.AttackDirection.AOE:
		var subsitute_enum:int = floori(actor.stats.get_stat(DirectionalSubsitute_Aoe + ":" + stat_name, -1))
		if subsitute_enum >= 0:
			attack_dir = subsitute_enum
			
	
	# Default Directional Mods:
	# Front: 1.0 | 100% | -0%
	# Flank: 0.5 | 50% | -50%
	#  Back: 0.0 | 00% | -100%
	#  AOE : 0.0 | 00% | -100%
	var dir_prefix = DirectionalMod_Front
	var default_mod = 1.0
	if attack_dir == AttackHandler.AttackDirection.Flank:
		dir_prefix = DirectionalMod_Flank
		default_mod = 0.5
	elif attack_dir == AttackHandler.AttackDirection.Back:
		dir_prefix = DirectionalMod_Back
		default_mod = 0.0
	elif attack_dir == AttackHandler.AttackDirection.AOE:
		dir_prefix = DirectionalMod_Aoe
		default_mod = 0.0
	
	
	var full_stat_name = dir_prefix + ":" + stat_name
	var mod_val = 1
	
	if actor.stats.has_stat(full_stat_name):
		mod_val = actor.stats.get_stat(full_stat_name)
	else:
		mod_val = actor.stats.get_stat(dir_prefix, default_mod)
	
	var raw_val = actor.stats.get_stat(stat_name, 0)
	
	return (raw_val * mod_val)

# This old idea depreciated because an AttackEvent can involve mutiple directions
### Returns stat for when actor is attacking from the target's [Front / Flank / Back]
#static func get_attack_stat_for_attack_direction(actor:BaseActor, attack_dir:AttackHandler.AttackDirection, stat_name:String, default:int=0)->float:
	#var sufix = ""
	#if attack_dir == AttackHandler.AttackDirection.Front:
		#sufix = StatHelper.DirectionalAttackSufix_Front
	#elif attack_dir == AttackHandler.AttackDirection.Flank:
		#sufix = StatHelper.DirectionalAttackSufix_Flank
	#elif attack_dir == AttackHandler.AttackDirection.Back:
		#sufix = StatHelper.DirectionalAttackSufix_Back
	#
	#var directional_mod = 1.0
	#var add_val = 0.0
	#if sufix != "":
		#var full_stat_name = stat_name + ":" + sufix
		#directional_mod = actor.stats.get_stat(full_stat_name, get_default_directional_mod(full_stat_name))
		#add_val = actor.stats.get_stat(full_stat_name + ":Add")
	#var raw_val = actor.stats.get_stat(stat_name, default) 
	#return (raw_val * directional_mod) + add_val

#static func get_default_directional_mod(full_stat_name:String)->float:
	#var tokens = full_stat_name.split(":")
	#if tokens.size() != 2:
		#printerr("StatHelper.get_default_directional_mod: Invalid direction stat_name: %s" % [full_stat_name])
		#return 1
	#var stat_name = tokens[0]
	#var sufix = tokens[1]
	#if sufix == DirectionalDefenseSufix_Flank:
		#if stat_name == Evasion:
			#return 0.5
		#elif stat_name == BlockChance:
			#return 0.5
	#elif sufix == DirectionalDefenseSufix_Back:
		#if stat_name == Evasion:
			#return 0
		#elif stat_name == BlockChance:
			#return 0
	#return 1
