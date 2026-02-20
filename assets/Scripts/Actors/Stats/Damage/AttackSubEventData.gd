class_name AttackSubEvent

enum AttackDirection {Front, Flank, Back, AOE}

var parent_event:AttackEvent
var defending_actor_id:String
var defending_actor_team:String

var hit_chance:float
var hit_roll:float
var is_miss:bool # Defender was not valid for attack

# Some attacks can't/shouldn't be evaded. Like: Healing, AOE, ...
# Healing specifically can't be determined untill after Damage is rolled
# Therefore Evade/Block/Crit will all be rolled even if they don't apply
var can_evade:bool # Can defender Evade attack
var rolled_evade:bool # Defender successfully evaided attack
var is_evade:bool: # Evade is valid 
	get: return can_evade and rolled_evade

var can_block:bool # Can defender Block attack
var rolled_blocked:bool # Defender successfully blocked attack
var is_blocked:bool: # Block is valid
	get: return (can_block and rolled_blocked) and not (can_crit and rolled_crit) 


var can_crit:bool # Can attacker Crit on attack
var rolled_crit:bool # Attacker successfully Crit on attack
var is_crit:bool: # Crit is_valid
	get: return (can_crit and rolled_crit) and not (can_block and rolled_blocked)

var attack_direction:AttackDirection
var defender_has_cover:bool
var defender_evasion:int
var defender_block_chance:float
var defender_block_mod:float
var defender_protection:int
var defender_cover_bonus:float

var final_damage_mod:float
var damage_events:Dictionary = {}
var applied_effect_datas:Dictionary = {}

func _init( parent:AttackEvent,
			defending_actor:BaseActor,
			direction_of_attack:AttackDirection, 
			defender_is_under_cover:bool
) -> void:
	parent_event = parent
	defending_actor_id = defending_actor.Id
	defending_actor_team = defending_actor.TeamKey
	attack_direction = direction_of_attack
	defender_has_cover = defender_is_under_cover
	
	can_evade = true
	can_block = true
	can_crit = true
	
	defender_evasion = StatHelper.get_defense_stat_for_attack_direction(defending_actor, attack_direction, StatHelper.Evasion)
	defender_block_chance = (StatHelper.get_defense_stat_for_attack_direction(defending_actor, attack_direction, StatHelper.BlockChance) / 100.0)
	defender_block_mod = defending_actor.stats.get_stat(StatHelper.BlockMod, 0) #StatHelper.get_defense_stat_for_attack_direction(defending_actor, attack_direction, StatHelper.BlockMod)
	defender_protection = defending_actor.stats.get_stat(StatHelper.Protection, 0) #StatHelper.get_defense_stat_for_attack_direction(defending_actor, attack_direction, StatHelper.Protection)
	defender_cover_bonus = defending_actor.stats.get_stat(StatHelper.CoverBonus, 0)


func dictialize_self()->Dictionary:
	var data = {
		"defending_actor_id": defending_actor_id,
		"defending_actor_team": defending_actor_team,
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
		"defender_cover_bonus": defender_cover_bonus,
		"final_damage_mod": final_damage_mod,
		"applied_effect_datas": applied_effect_datas,
		
		"damage_events": {},
	}
	for damage_event_key in damage_events.keys():
		data["damage_events"][damage_event_key] = damage_events[damage_event_key].dictialize_self()
	return data

func get_defender()->BaseActor:
	return ActorLibrary.get_actor(defending_actor_id)

func get_effect_meta_data(effect_data_key:String):
	if effect_data_key.ends_with(":DmgEft"):
		var damage_data_key = effect_data_key.trim_suffix(":DmgEft")
		var damage_data = parent_event.damage_datas[damage_data_key]
		return damage_data.get("DmgEffectData")
	else:
		return parent_event.effect_datas[effect_data_key]
