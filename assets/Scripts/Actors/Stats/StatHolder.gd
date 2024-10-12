class_name StatHolder

const HealthKey:String = "Health"
const LOGGING = true

var _actor:BaseActor
var _base_stats:Dictionary = {}
var _cached_stats:Dictionary = {}
# Stats which frequently change in battle (Health, Mana, ...)
var _bar_stats:Dictionary = {}
var _stats_dirty = true
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

func dirty_stats():
	if LOGGING: print("Stats Dirty")
	_stats_dirty = true
	

func get_stat(stat_name:String, default:int=0):
	if _bar_stats.has(stat_name):
		return _bar_stats[stat_name]
	if _stats_dirty:
		_calc_cache_stats()
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
	
func add_to_bar_stat(stat_name:String, val:int):
	if _bar_stats.has(stat_name):
		_bar_stats[stat_name] = min(_bar_stats[stat_name] + val, get_max_stat(stat_name))
	

func get_max_stat(stat_name):
	return get_stat("Max:"+stat_name)

func _calc_cache_stats():
	if !_actor.effects:
		for stat_name in _base_stats.keys():
			_cached_stats[stat_name] = _base_stats[stat_name]
		return
	if LOGGING: print("#Caching Stats for: %s" % _actor.ActorKey)
	
	# Aggregate all the mods together by stat_name, then type
	var agg_mods = {}
	for mod:BaseStatMod in _actor.effects.get_stat_mods():
		if LOGGING: print("# Found Mod '", mod.display_name, " for: %s" % _actor.ActorKey)
		if not agg_mods.keys().has(mod.stat_name):
			agg_mods[mod.stat_name] = {}
		if not agg_mods[mod.stat_name].keys().has(mod.mod_type):
			agg_mods[mod.stat_name][mod.mod_type] = []
		agg_mods[mod.stat_name][mod.mod_type].append(mod.value)
		
		
	if LOGGING: print("- Found: %s modded stats" % agg_mods.size())
	
	
	for stat_name in _base_stats.keys():
		if not agg_mods.keys().has(stat_name):
			_cached_stats[stat_name] = _base_stats[stat_name]
			continue
			
		var agg_stat:Dictionary = agg_mods[stat_name]
		var temp_val = float(_base_stats[stat_name])
		if agg_stat.keys().has(BaseStatMod.ModTypes.Add):
			for val in agg_stat[BaseStatMod.ModTypes.Add]:
				temp_val += val
		if agg_stat.keys().has(BaseStatMod.ModTypes.Scale):
			for val in agg_stat[BaseStatMod.ModTypes.Scale]:
				temp_val = temp_val * val
		_cached_stats[stat_name] = temp_val
	if LOGGING: print("--- Done Caching Stats")
	_stats_dirty = false
		
	
func apply_damage(value:int, _damage_type:String, _source):
	_bar_stats[HealthKey] = _bar_stats[HealthKey] - value
	if current_health <= 0:
		CombatRootControl.Instance.kill_actor(_actor)
