class_name StatHelper

enum CoreStats {Strength, Agility, Intelligence, Wisdom}

const StatBarColors:Dictionary = {
	"Health": Color.RED,
	"Mana": Color.DEEP_SKY_BLUE,
	"Stamina": Color.GREEN
}


## Every Actor is exspected to have these stats
const BasicStats:Array = [
	Health, Mass, Speed, Push, PPR,
	Armor, Ward, 
	Accuracy, Evasion, Potency, Protection,
	Awareness, CritChance, CritMod, BlockChance, BlockMod,
	BlocksLOS
]
const Health = "BarStat:Health"
const Mass = "Mass"
const Speed = "Speed"
const Push = "Push"
const PPR = "PPR"
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
const EvasionPenaltyFlank = "EvasionPenF"
const EvasionPenaltyBack = "EvasionPenB"
const BlockPenaltyFlank = "BlockPenF"
const BlockPenaltyBack = "BlockPenB"
const BlocksLOS = "BlocksLOS"

const stat_abbrs:Dictionary = {
	"PhyAttack": "PHY",
	"MagAttack": "MAG",
	"Strength": "STR",
	"Agility": "AGL",
	"Intelligence": "INT",
	"Wisdom": "WIS",
	"Mass": "MAS",
	"Speed": "SPD",
	"Armor": "ARM",
	"Ward": "WRD",
	"Awareness": "AWR",
	"Accuracy": "ACC",
	"Evasion": "EVS",
	"Potency": "POT",
	"Protection": "PRO"
}

const stat_icon_paths:Dictionary = {
	"BarStat": "res://assets/Sprites/UI/SymbolIcons/BarStatSymbol.png",
	"PhyAttack": "res://assets/Sprites/UI/SymbolIcons/PhyDamageSymbol.png",
	"MagAttack": "res://assets/Sprites/UI/SymbolIcons/MagDamageSymbol.png",
	"Strength": "res://assets/Sprites/UI/SymbolIcons/_S_Symbole.png",
	"Agility": "res://assets/Sprites/UI/SymbolIcons/_A_Symbole.png",
	"Intelligence": "res://assets/Sprites/UI/SymbolIcons/_I_Symbole.png",
	"Wisdom": "res://assets/Sprites/UI/SymbolIcons/_W_Symbole.png",
	"Mass": "res://assets/Sprites/UI/SymbolIcons/MassSymbol.png",
	"Speed": "res://assets/Sprites/UI/SymbolIcons/SpeedSymbol.png",
	"Armor": "res://assets/Sprites/UI/SymbolIcons/ArmorSymbol.png",
	"Ward": "res://assets/Sprites/UI/SymbolIcons/WardSymbol.png",
	"Awareness": "res://assets/Sprites/UI/SymbolIcons/AwarenessSymbol.png",
	"Accuracy": "res://assets/Sprites/UI/SymbolIcons/AccuracySymbol.png",
	"Evasion": "res://assets/Sprites/UI/SymbolIcons/EvasionSymbol.png",
	"Potency": "res://assets/Sprites/UI/SymbolIcons/PotencySymbol.png",
	"Protection": "res://assets/Sprites/UI/SymbolIcons/ProtectionSymbol.png"
}

static func get_stat_abbr(stat_name:String)->String:
	return stat_abbrs.get(stat_name, stat_name)

static func get_stat_icon(stat_name:String)->Texture2D:
	var path = stat_icon_paths.get(stat_name)
	if path:
		return SpriteCache.get_sprite(path)
	return null
