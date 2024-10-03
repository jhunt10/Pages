class_name StatHolder

const HealthKey:String = "Health"

var _actor:BaseActor
var _base_stats:Dictionary = {}
var _cached_stats:Dictionary = {}
# Stats which frequently change in battle (Health, Mana, ...)
var _bar_stats:Dictionary = {}
#var _active_mods:Dictionary = {}

var current_health:int:
	get: return _bar_stats.get(HealthKey,1)
var max_health:int: 
	get: return _cached_stats.get('Max:'+HealthKey,1)
var level:int:
	get: return _cached_stats.get('Level',-1)


func _init(actor:BaseActor, data:Dictionary) -> void:
	_actor = actor
	
	# Parse Stat Data
	for key:String in data.keys():
		if key.begins_with("Max:"):
			var subKey = key.substr(4)
			_bar_stats[subKey] = data[key]
			_base_stats[key] = data[key]
		elif data[key] is int or data[key] is float:
			_base_stats[key] = data[key]
			
	_calc_cache_stats()
	current_health = max_health

func get_stat(stat_name:String, default:int=0):
	if _bar_stats.has(stat_name):
		return _bar_stats[stat_name]
	return _cached_stats.get(stat_name, default)
	
func list_bar_stats():
	return _bar_stats.keys()

# Returns true if cost can be paied
func reduce_bar_stat_value(stat_name:String, val:int, allow_partial:bool=true) -> bool:
	if _bar_stats.has(stat_name):
		if not allow_partial and _bar_stats[stat_name] < val:
			return false
		_bar_stats[stat_name] = max(0, _bar_stats[stat_name]  - val)
		return true
	return false

func get_max_stat(stat_name):
	return get_stat("Max:"+stat_name)

func _calc_cache_stats():
	# TODO: Stat calc
	for key in _base_stats.keys():
		_cached_stats[key] = _base_stats[key]
	
func apply_damage(value:int, _damage_type:String, _source):
	_bar_stats[HealthKey] = _bar_stats[HealthKey] - value
	if current_health <= 0:
		CombatRootControl.Instance.kill_actor(_actor)
	
