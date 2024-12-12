class_name StatHelper

enum CoreStats {Strength, Agility, Intelligence, Wisdom}

const StatBarColors:Dictionary = {
	"Health": Color.RED,
	"Mana": Color.DEEP_SKY_BLUE,
	"Stamina": Color.GREEN
}


## Every Actor is exspected to have these stats
const BasicStats:Array = [
	Health, Mass, Speed, Armor, Ward, Push, CritChance, CritMod, Accuracy, Evasion, Potency, Resist
]
const Health = "BarStat:Health"
const Mass = "Mass"
const Speed = "Speed"
const Armor = "Armor"
const Ward = "Ward"
const Push = "Push"
const CritChance = "CritChance"
const CritMod = "CritMod"
const BlockChance = "BlockChance"
const BlockMod = "BlockMod"
const Accuracy = "Accuracy"
const Evasion = "Evasion"
const Potency = "Potency"
const Resist = "Resist"
