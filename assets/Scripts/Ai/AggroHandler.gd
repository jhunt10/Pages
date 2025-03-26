class_name AggroHandler

const THREAT_SWITCH_THRESHOLD = 1.2

signal switched_aggro

var _actor:BaseActor
var actor_id_to_threat:Dictionary = {}
var current_aggroed_actor_id:String = ''

func _init(actor:BaseActor) -> void:
	_actor = actor

func get_current_aggroed_actor_id()->String:
	return current_aggroed_actor_id

func get_threat_from_actor(actor_id:String)->float:
	if actor_id_to_threat.has(actor_id):
		return actor_id_to_threat[actor_id]
	return 0

func add_threat_from_actor(enemy:BaseActor, val:float):
	
	#TODO: Add threat from healing and applying effects
	
	if not enemy or enemy.FactionIndex == _actor.FactionIndex:
		return
	if not actor_id_to_threat.has(enemy.Id):
		actor_id_to_threat[enemy.Id] = 0
	var enemy_aggro_scale = enemy.stats.get_stat(StatHelper.AggroMod, 1)
	actor_id_to_threat[enemy.Id] += (val * enemy_aggro_scale)
	var switch_thresh =  THREAT_SWITCH_THRESHOLD * get_threat_from_actor(current_aggroed_actor_id) 
	if current_aggroed_actor_id == '' or actor_id_to_threat[enemy.Id] >= switch_thresh:
		current_aggroed_actor_id = enemy.Id
		switched_aggro.emit()

func get_lowest_threat()->float:
	var lowest = -1
	for val in actor_id_to_threat.values():
		if val < lowest or lowest < 0:
			lowest = val
	return max(0, lowest)

func get_highest_threat()->float:
	var highest = -1
	for val in actor_id_to_threat.values():
		if val > highest:
			highest = val
	return max(0, highest)
