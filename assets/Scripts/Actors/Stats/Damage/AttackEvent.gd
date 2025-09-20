class_name AttackEvent

const LOGGING = true
enum AttackStage 
{
	## Attack Event has just been created
	Created,
	## Attack Event has rolled for Hit / Miss / Evade / Crit / Block 
	RolledForHit,
	## Attack Event has calculated/rolled Damage
	RolledForDamage,
	## Attack Event has rolled Effect Application
	RolledForEffects,
	## Attack Event has applied Damage and Effects
	Resolved
}

var attacker_id:String
var attacker_faction:int
var source_tag_chain:SourceTagChain
var attack_details:Dictionary
var attack_stage:AttackStage

var defender_ids:Array:
	get: return sub_events.keys()
var sub_events:Dictionary = {}

var attack_mods:Dictionary
var damage_datas:Dictionary
var effect_datas:Dictionary

var attacker_accuracy:int
var attacker_cover_penalty:float
var attacker_crit_chance:float
var attcker_crit_mod:float
var attacker_potency:float

func _init( attacking_actor:BaseActor, 
			defending_actors:Array,
			defenders_dir_and_cover_data:Dictionary,
			attack_details:Dictionary,
			tag_chain:SourceTagChain, 
			damage_datas:Dictionary,
			effect_datas:Dictionary,
			attack_mods:Dictionary) -> void:
	attacker_id = attacking_actor.Id
	attacker_faction = attacking_actor.FactionIndex
	self.attack_details = attack_details
	source_tag_chain = tag_chain
	self.damage_datas = damage_datas
	self.effect_datas = effect_datas
	self.attack_mods = attack_mods
	attack_stage = AttackStage.Created
	
	# StatMods from AttackMods should already have been applied to Attacker and Defenders
	attacker_accuracy = attacking_actor.stats.get_stat(StatHelper.Accuracy, 100)
	attacker_cover_penalty = attacking_actor.stats.get_stat(StatHelper.CoverPenalty, 0)
	attacker_potency = attacking_actor.stats.get_stat(StatHelper.Potency, 100)
	attacker_crit_chance = attacking_actor.stats.get_stat(StatHelper.CritChance, 0) / 100.0
	attcker_crit_mod = attacking_actor.stats.get_stat(StatHelper.CritMod, 0)
	
	for defender:BaseActor in defending_actors:
		var dir = defenders_dir_and_cover_data[defender.Id]['AttackDirection']
		var has_cover = defenders_dir_and_cover_data[defender.Id]['HasCover']
		sub_events[defender.Id] = AttackSubEvent.new(self, defender,dir, has_cover)
	
	for damage_data_key in self.damage_datas.keys():
		self.damage_datas[damage_data_key]['DamageDataKey'] = damage_data_key
	
func serialize_self()->String:
	var data = {
	"attacker_id": attacker_id,
	"attacker_faction": attacker_faction,
	"source_tag_chain": source_tag_chain.get_all_tags(),
	"attack_details": attack_details,
	"attack_stage": attack_stage,
	"defender_ids": defender_ids,
	
	"attack_mods": attack_mods,
	"damage_datas": damage_datas,
	"effect_datas": effect_datas,
	"attacker_accuracy": attacker_accuracy,
	"attacker_crit_chance": attacker_crit_chance,
	"attcker_crit_mod": attcker_crit_mod,
	"attacker_potency": attacker_potency,
	"attacker_cover_penalty": attacker_cover_penalty,
	"sub_events": {}
	}
	for defender_id in defender_ids:
		var sub_event:AttackSubEvent = sub_events[defender_id]
		data['sub_events'][defender_id] = sub_event.dictialize_self()
	return JSON.stringify(data)

func get_sub_event_for_defender(defender_or_id)->AttackSubEvent:
	if defender_or_id is BaseActor:
		defender_or_id = defender_or_id.Id
	return sub_events.get(defender_or_id) 
