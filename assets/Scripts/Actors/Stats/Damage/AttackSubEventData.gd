class_name AttackSubEvent

enum AttackDirection {Front, Flank, Back, AOE}

var parent_event:AttackEvent
var defending_actor_id:String
var defending_actor_faction:int

var hit_chance:float
var hit_roll:float
var is_miss:bool # Defender was not valid for attack
var is_evade:bool # Defender evaided attack
var is_blocked:bool # Defender blocked attack
var is_crit:bool # Attacker rolled critical hit

var attack_direction:AttackDirection
var defender_has_cover:bool
var defender_evasion:int
var defender_block_chance:float
var defender_block_mod:float
var defender_protection:int

var final_damage_mod:float
var damage_events:Array = []
var applied_effect_datas:Dictionary = {}


func _init( parent:AttackEvent,
			defending_actor:BaseActor,
			direction_of_attack:AttackDirection, 
			defender_is_under_cover:bool
) -> void:
	parent_event = parent
	defending_actor_id = defending_actor.Id
	defending_actor_faction = defending_actor.FactionIndex
	attack_direction = direction_of_attack
	defender_has_cover = defender_is_under_cover
	
	defender_evasion = StatHelper.get_defense_stat_for_attack_direction(defending_actor, attack_direction, StatHelper.Evasion, 0)
	defender_block_chance = (StatHelper.get_defense_stat_for_attack_direction(defending_actor, attack_direction, StatHelper.BlockChance, 0) / 100.0)
	defender_block_mod = StatHelper.get_defense_stat_for_attack_direction(defending_actor, attack_direction, StatHelper.BlockMod, 0.25)
	defender_protection = StatHelper.get_defense_stat_for_attack_direction(defending_actor, attack_direction, StatHelper.Protection, 0)


func dictialize_self()->Dictionary:
	var data = {
		"defending_actor_id": defending_actor_id,
		"defending_actor_faction": defending_actor_faction,
		"hit_chance":hit_chance,
		"hit_roll":hit_roll,
		"is_miss": is_miss,
		"is_evade": is_evade,
		"is_blocked": is_blocked,
		"is_crit": is_crit,
		"attack_direction": attack_direction,
		"defender_has_cover": defender_has_cover,
		"defender_evasion": defender_evasion,
		"defender_block_chance": defender_block_chance,
		"defender_block_mod": defender_block_mod,
		"defender_protection": defender_protection,
		"final_damage_mod": final_damage_mod,
		"applied_effect_datas": applied_effect_datas,
		
		"damage_events": [],
	}
	for damage_event in damage_events:
		data["damage_events"].append(damage_event.dictialize_self())
	return data
