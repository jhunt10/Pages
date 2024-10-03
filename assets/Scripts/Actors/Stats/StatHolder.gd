class_name StatHolder

var _actor:BaseActor
var _base_stats:Dictionary = {}
var _cached_stats:Dictionary = {}
#var _active_mods:Dictionary = {}

var current_health:int
var max_health:int: 
	get: return _cached_stats.get('MaxHealth',1)
var level:int:
	get: return _cached_stats.get('Level',-1)


func _init(actor:BaseActor, data:Dictionary) -> void:
	_actor = actor
	for key in data.keys():
		if data[key] is int or data[key] is float:
			_base_stats[key] = data[key]
	_calc_cache_stats()
	current_health = max_health

func get_stat(stat_name:String, default:int=0):
	return _cached_stats.get(default, 0)

func _calc_cache_stats():
	# TODO: Stat calc
	for key in _base_stats.keys():
		_cached_stats[key] = _base_stats[key]
	
func apply_damage(value:int, _damage_type:String, _source):
	#TODO:Damage calc
	current_health -= value
	if current_health <= 0:
		CombatRootControl.Instance.kill_actor(_actor)
	
