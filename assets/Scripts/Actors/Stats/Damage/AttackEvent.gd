class_name AttackEvent

enum AttackDirection {Front, Flank, Back, AOE}
enum AttackStage {
	## Attack Event has just been created
	PreAttackRoll,
	## Attack Event has rolled for Hit / Miss / Evade / Crit / Block
	PostAttackRoll,
	## Attack Event has applied damage and is done
	Resolved
}


var attacker:BaseActor
var defender:BaseActor
var source_tag_chain:SourceTagChain
var attack_stage:AttackStage

var attack_direction:AttackDirection
var defender_has_cover:bool
var is_aoe:bool:
	get: return attack_direction == AttackDirection.AOE

var is_hit:bool
var is_evade:bool
var is_crit:bool
var is_blocked:bool

var damage_data_arr:Array

var attacker_accuracy:int
var attacker_crit_chance:float
var attcker_crit_mod:float

var defender_evasion:int
var defender_block_chance:float
var defender_block_mod:float

var final_damage_mod:float
var damage_events:Array = []

func _init( attacking_actor:BaseActor, 
			defending_actor:BaseActor, 
			direction_of_attack:AttackDirection, 
			defender_is_under_cover:bool, 
			tag_chain:SourceTagChain, 
			damage_datas:Array) -> void:
	attacker = attacking_actor
	defender = defending_actor
	source_tag_chain = tag_chain
	damage_data_arr = damage_datas
	attack_stage = AttackStage.PreAttackRoll
	
	attack_direction = direction_of_attack
	defender_has_cover = defender_is_under_cover
	
	attacker_accuracy = StatHelper.get_attack_stat_for_attack_direction(attacker, attack_direction, StatHelper.Accuracy, 100)
	attacker_crit_chance =  StatHelper.get_attack_stat_for_attack_direction(attacker, attack_direction, StatHelper.CritChance, 0) / 100.0
	attcker_crit_mod = StatHelper.get_attack_stat_for_attack_direction(attacker, attack_direction, StatHelper.CritMod, 1.5)
	
	defender_evasion = StatHelper.get_defense_stat_for_attack_direction(defender, attack_direction, StatHelper.Evasion, 0)
	defender_block_chance = (StatHelper.get_defense_stat_for_attack_direction(defender, attack_direction, StatHelper.BlockChance, 0) / 100.0)
	defender_block_mod = StatHelper.get_defense_stat_for_attack_direction(defender, attack_direction, StatHelper.BlockMod, 0.25)

func roll_for_hit():
	if attack_direction == AttackDirection.Front:
		print("Attacking from FRONT")
	if attack_direction == AttackDirection.Flank:
		print("Attacking from Flank")
	if attack_direction == AttackDirection.Back:
		print("Attacking from Back")
	if attack_direction == AttackDirection.AOE:
		print("Attacking from AOE")
	var net_evasion = max(0, defender_evasion + (100 - attacker_accuracy))
	
	var hit_chance = DamageHelper.calc_armor_reduction(net_evasion)
	var roll = randf()
	is_hit = roll > 1 - hit_chance
	is_evade = defender_evasion > 100 - attacker_accuracy
	is_crit = roll > 1 - attacker_crit_chance
	
	var block_roll = randf()
	is_blocked = block_roll >  1 - defender_block_chance
	
	print("Accuracy: %s | Evasion: %s | Net: %s" % [attacker_accuracy, defender_evasion, net_evasion])
	print("Attack Roll: %s | Hit Chance: %s | Crit Chance: %s | Is Hit: %s | Is Crit: %s"%
		[roll, hit_chance, attacker_crit_chance, is_hit, is_crit])
	print("Block Roll: %s | Block Chance: %s | Is Block: %s | Block Mod: %s" % [block_roll, defender_block_chance, is_blocked, defender_block_mod])
	
	final_damage_mod = 1.0
	if is_hit and attack_direction != AttackDirection.AOE:
		if is_crit and not is_blocked:
			final_damage_mod = attcker_crit_mod
		elif is_blocked and not is_crit:
			final_damage_mod = defender_block_mod
			
	self.attack_stage = AttackStage.PostAttackRoll

func get_damage_datas():
	return damage_data_arr
	
