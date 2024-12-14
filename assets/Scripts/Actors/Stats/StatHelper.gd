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
const Armor = "Armor"
const Ward = "Ward"
const Push = "Push"
const PPR = "PPR"
const Awareness = "Awareness"
const CritChance = "CritChance"
const CritMod = "CritMod"
const BlockChance = "BlockChance"
const BlockMod = "BlockMod"
const Accuracy = "Accuracy"
const Evasion = "Evasion"
const Potency = "Potency"
const Protection = "Protection"
const BlocksLOS = "BlocksLOS"
