class_name StatHolder

const HealthKey:String = "Health"
const LOGGING = false

signal held_stats_changed
signal bar_stat_changed

var _stats_dirty = true
var _actor:BaseActor
var _base_stats:Dictionary = {}
var _cached_stats:Dictionary = {}
var _cached_mods:Dictionary = {}

# Temparary mods applied for single event (used for AttackMods and Level Up preview)
var _temp_stat_mods:Dictionary = {}
var attribute_levels:Dictionary = {}

## Stats which used as resources (Health, Mana, ...)
#var _bar_stats:Dictionary = {}
#var _bar_stats_regen:Dictionary = {}

# Commonly accessed stats
var current_health:int:
	get: return get_bar_stat(HealthKey)
var max_health:int: 
	get: return get_bar_stat_max(HealthKey)

func _init(actor:BaseActor, data:Dictionary) -> void:
	_actor = actor
	# Parse Stat Data
	for key:String in data.keys():
		if key == 'StartingAttributeLevels':
			attribute_levels = data[key].duplicate()
		else:
			_base_stats[key] = data[key]
	# Actor handles signles between item holders
	#actor.equipment_changed.connect(dirty_stats)
	actor.turn_starting.connect(_on_actor_turn_start)
	actor.turn_ended.connect(_on_actor_turn_end)
	actor.round_ended.connect(_on_actor_round_end)

func build_save_data()->Dictionary:
	var out_dict = {}
	out_dict[StatHelper.Level] = get_stat(StatHelper.Level)
	out_dict[StatHelper.Experience] = get_stat(StatHelper.Experience, 0)
	out_dict['AttributeLevels'] = {
		StatHelper.Strength: attribute_levels[StatHelper.Strength],
		StatHelper.Agility: attribute_levels[StatHelper.Agility],
		StatHelper.Intelligence: attribute_levels[StatHelper.Intelligence],
		StatHelper.Wisdom: attribute_levels[StatHelper.Wisdom],
	}
	return out_dict

func load_data(stat_data:Dictionary):
	self._base_stats[StatHelper.Level] = stat_data.get(StatHelper.Level, 0)
	self._base_stats[StatHelper.Experience] = stat_data.get(StatHelper.Experience, 0)
	var loaded_attribute_levels = stat_data.get("AttributeLevels", {})
	for attribute in loaded_attribute_levels.keys():
		attribute_levels[attribute] = loaded_attribute_levels.get(attribute, 0)

func dirty_stats():
	if LOGGING: print("Stats Dirty")
	_stats_dirty = true

func recache_stats(emit_signal:bool=true):
	if LOGGING: printerr("Recaching Stats")
	_calc_cache_stats(emit_signal)

func has_stat(stat_name:String)->bool:
	if _stats_dirty:
		_calc_cache_stats()
	return _cached_stats.has(stat_name)

func get_stat(stat_name:String, default:float=0):
	var full_stat_name = stat_name
	if _stats_dirty:
		_calc_cache_stats()
	return _cached_stats.get(stat_name, default)

func get_base_stat(stat_name:String, default:int=0):
	return _base_stats.get(stat_name, default)

func get_leveled_attribute(stat_name:String):
	var base = _base_stats.get(stat_name, 0)
	return base + attribute_levels.get(stat_name, 0)

func base_damge_from_stat(stat_name):
	if !stat_name:
		return 1
	var base_stat_val = get_stat(stat_name)
	return base_stat_val

func get_mod_names_for_stat(stat_name:String)->Array:
	var out_list = []
	for mod:BaseStatMod in _cached_mods.get(stat_name, []):
		var display_name = ''
		if mod.mod_type	 == BaseStatMod.ModTypes.Set:
			display_name = "=" + str(mod.value) + " " + mod.display_name
		elif mod.mod_type	 == BaseStatMod.ModTypes.Add:
			display_name = "+" + str(mod.value) + " " + mod.display_name
		elif mod.mod_type == BaseStatMod.ModTypes.AddStat:
			var short_name = StatHelper.get_stat_abbr(mod.dep_stat_name)
			display_name = "+" + str(short_name) + "x" + str(mod.value) + " " + mod.display_name
		elif mod.mod_type == BaseStatMod.ModTypes.Scale:
			display_name = "x" + str(mod.value) + " " + mod.display_name
		else:
			display_name = mod.display_name
		if display_name != '':
			out_list.append(display_name)
	return out_list

func get_stats_dependant_on_attribute(attribute_name:String)->Array:
	var out_list = []
	for stat_name in _cached_mods.keys():
		for mod:BaseStatMod in _cached_mods[stat_name]:
			
			if mod.dep_stat_name == attribute_name:
				out_list.append(mod.stat_name)
	return out_list

func get_damage_resistance(damage_type:DamageEvent.DamageTypes)->float:
	var type_str = DamageEvent.DamageTypes.keys()[damage_type]
	var int_val = get_stat("Resistance:" + str(type_str), 0)
	return float(int_val)

# -----------------------------------------------------------------
#					Level Up
# -----------------------------------------------------------------

func add_experiance(value:int):
	if not _base_stats.has(StatHelper.Experience):
		_base_stats[StatHelper.Experience] = 0
	_base_stats[StatHelper.Experience] += value
	_cached_stats[StatHelper.Experience] = _base_stats[StatHelper.Experience]

func get_exp_to_next_level(current_level:int=-1)->int:
	if current_level < 0:
		current_level = get_stat(StatHelper.Level)
	return 100 + (100 * current_level) + (50 * (current_level - 1))

func can_level_up()->bool:
	var required = get_exp_to_next_level()
	if not _base_stats.has(StatHelper.Experience):
		return false
	return required < _base_stats[StatHelper.Experience]

func get_level_for_exp(total_exp:int)->int:
	var remaining = total_exp
	for level in range(100):
		var required = get_exp_to_next_level(level)
		if required > remaining:
			return level
		remaining -= required
	return 100

func apply_level_up(new_level:int, remaining_exp:int, add_att_levels:Dictionary):
	_base_stats[StatHelper.Level] = new_level
	_base_stats[StatHelper.Experience] = remaining_exp
	attribute_levels[StatHelper.Strength] = add_att_levels.get(StatHelper.Strength)
	attribute_levels[StatHelper.Agility] = add_att_levels.get(StatHelper.Agility)
	attribute_levels[StatHelper.Intelligence] = add_att_levels.get(StatHelper.Intelligence)
	attribute_levels[StatHelper.Wisdom] = add_att_levels.get(StatHelper.Wisdom)
	recache_stats()
	

# -----------------------------------------------------------------
#					Bar Stats
# -----------------------------------------------------------------


func get_bar_stat(stat_name:String)->int:
	return get_stat("BarStat:" + stat_name, 0)
	
## Retruns list of StatKey for all bar stats
func list_bar_stat_names():
	var out_list = []
	for stat_name in _cached_stats.keys():
		if stat_name.begins_with("BarStat:"):
			out_list.append(stat_name.trim_prefix("BarStat:"))
	return out_list
	
func fill_bar_stats():
	for stat_name in list_bar_stat_names():
		var max_val = get_bar_stat_max(stat_name)
		_cached_stats["BarStat:"+stat_name] = max_val

func apply_damage_event(damage_event:DamageEvent, trigger_effect:bool=false, game_state:GameStateData=null):
	if trigger_effect:
		if not game_state:
			printerr("StatHolder.apply_damage_event: Attempted Trigger Effects, but no GameState provided")
		else:
			_actor.effects.trigger_damage_taken(game_state, damage_event)
	var damage = damage_event.final_damage
	var health_key = "BarStat:"+HealthKey
	_cached_stats[health_key] = max(min(_cached_stats[health_key] - damage, max_health), 0)
	if current_health <= 0 and CombatRootControl.Instance:
		CombatRootControl.Instance.kill_actor(_actor)
	bar_stat_changed.emit()
	

func apply_damage(damage):
	if damage is DamageEvent:
		damage = damage.final_damage
	_cached_stats["BarStat:"+HealthKey] = max(min(_cached_stats["BarStat:"+HealthKey] - damage, max_health), 0)
	if current_health <= 0 and CombatRootControl.Instance:
		CombatRootControl.Instance.kill_actor(_actor)
	bar_stat_changed.emit()

func apply_healing(value:int, can_revive:bool=false):
	var health_key = "BarStat:"+HealthKey
	if _actor.is_dead and not can_revive:
		return
	_cached_stats[health_key] = max(min(_cached_stats[health_key] + value, max_health), 0)
	if _actor.is_dead and _cached_stats[health_key] > 0:
		if CombatRootControl.Instance:
			CombatRootControl.Instance.revive_actor(_actor)
	bar_stat_changed.emit()
	

## Reduce current value of bar stat by given val and return true if cost was be paied
func reduce_bar_stat_value(stat_name:String, val:int, allow_partial:bool=true) -> bool:
	var full_stat_name = "BarStat:" + stat_name
	if _cached_stats.has(full_stat_name):
		if not allow_partial and _cached_stats[full_stat_name] < val:
			return false
		_cached_stats[full_stat_name] = max(0, _cached_stats[full_stat_name]  - val)
		bar_stat_changed.emit()
		return true
	return false

## Increase current value of bar stat by given val
func add_to_bar_stat(stat_name:String, val:int):
	var full_stat_name = "BarStat:" + stat_name
	if _cached_stats.has(full_stat_name):
		_cached_stats[full_stat_name] = min(_cached_stats[full_stat_name] + val, get_bar_stat_max(stat_name))
		bar_stat_changed.emit()

## Get Max value of BarStat
func get_bar_stat_max(stat_name):
	return get_stat("BarMax:"+stat_name)

func _on_actor_turn_start():
	pass

func get_bar_stat_regen_per_turn(stat_name):
	var full_stat_name = "BarRegen:" + stat_name + ":Turn"
	return get_stat(full_stat_name)

func get_bar_stat_regen_per_round(stat_name):
	var full_stat_name = "BarRegen:" + stat_name + ":Round"
	return get_stat(full_stat_name)

func _on_actor_turn_end():
	# On Turn Regen
	for stat_name in list_bar_stat_names():
		var regen = get_bar_stat_regen_per_turn(stat_name) 
		if regen != 0:
			add_to_bar_stat(stat_name, regen)

func _on_actor_round_end():
	# On Round Regen
	for stat_name in list_bar_stat_names():
		var regen = get_bar_stat_regen_per_round(stat_name) 
		if regen != 0:
			add_to_bar_stat(stat_name, regen)

# -----------------------------------------------------------------
#					Stat Mods
# -----------------------------------------------------------------

func add_temp_stat_mod(stat_mod_id:String, stat_mod:BaseStatMod, reache_now:bool=true):
	_temp_stat_mods[stat_mod_id] = stat_mod
	if reache_now:
		recache_stats(false)

func apply_temp_stat_mods():
	if _temp_stat_mods.size() == 0:
		return
	recache_stats(false)

func clear_temp_stat_mods(reache_now:bool=true):
	if _temp_stat_mods.size() == 0:
		return
	_temp_stat_mods.clear()
	if reache_now:
		recache_stats(false)

func _calc_cache_stats(emit_signal:bool=true):
	if LOGGING: 
		print("#Caching Stats for: %s" % _actor.ActorKey)
	
	_cached_mods.clear()
	# Aggregate all the mods together by stat_name, then type
	var agg_mods = {}
	var set_stats = {}
	var key_depends_on_vals = {}
	var key_is_dependant_of_vals = {}
	
	var mods_list = _actor.effects.get_stat_mods()
	mods_list.append_array(_temp_stat_mods.values())
	mods_list.append_array(_actor.equipment.get_passive_stat_mods())
	mods_list.append_array(_actor.pages.get_passive_stat_mods())
	
	for mod:BaseStatMod in mods_list:
		if LOGGING: print("# Found Mod '", mod.display_name, " for: %s" % _actor.ActorKey)
		
		#
		if not agg_mods.keys().has(mod.stat_name): # Add stat name to agg mods
			agg_mods[mod.stat_name] = {}
		if not agg_mods[mod.stat_name].keys().has(mod.mod_type): # Add mod type to agg mods
			agg_mods[mod.stat_name][mod.mod_type] = []
		if not _cached_mods.keys().has(mod.stat_name): # Add stat name to mod list
			_cached_mods[mod.stat_name] = []
		
		
		_cached_mods[mod.stat_name].append(mod)
		if mod.mod_type	 == BaseStatMod.ModTypes.Set:
			if set_stats.keys().has(mod.stat_name):
				printerr("StatHolder._calc_cache_stats: Multiple 'Set' mods found on stat '%s'." % [mod.stat_name])
			set_stats[mod.stat_name] = mod.value
			agg_mods[mod.stat_name][mod.mod_type].append(mod.value)
			var display_name = "=" + str(mod.value) + " " + mod.display_name
		elif mod.mod_type	 == BaseStatMod.ModTypes.Add:
			if not _base_stats.keys().has(mod.stat_name):
				if not set_stats.keys().has(mod.stat_name):
					set_stats[mod.stat_name] = 0
			agg_mods[mod.stat_name][mod.mod_type].append(mod.value)
			var display_name = "+" + str(mod.value) + " " + mod.display_name
		elif mod.mod_type == BaseStatMod.ModTypes.AddStat:
			var dep_stat_name = mod.dep_stat_name
			if key_depends_on_vals.has(dep_stat_name) and key_depends_on_vals[dep_stat_name].has(mod.stat_name):
				printerr("StatHolder._calc_cache_stats: Circular dependancy found for stats %s <-> %s. Rejecting mod: %s" % [mod.stat_name, dep_stat_name, mod.display_name] )
				continue
			if not key_depends_on_vals.keys().has(mod.stat_name):
				key_depends_on_vals[mod.stat_name] = []
			if not key_depends_on_vals[mod.stat_name].has(dep_stat_name):
				key_depends_on_vals[mod.stat_name].append(dep_stat_name)
				
			if not key_is_dependant_of_vals.has(dep_stat_name):
				key_is_dependant_of_vals[dep_stat_name] = []
			if not key_is_dependant_of_vals[dep_stat_name].has(mod.stat_name):
				key_is_dependant_of_vals[dep_stat_name].append(mod.stat_name)
			agg_mods[mod.stat_name][mod.mod_type].append({"DepStat": dep_stat_name, "Scale": mod.value})
			var display_name = "+" + str(dep_stat_name) + "x" + str(mod.value) + " " + mod.display_name
		else:
			agg_mods[mod.stat_name][mod.mod_type].append(mod.value)
			var display_name = "x" + str(mod.value) + " " + mod.display_name
			
		
	if LOGGING: print("- Found: %s modded stats" % agg_mods.size())
	
	# Build temp stat list from base stats and stats created by mods
	var temp_stats = {}
	for base_stat_name in _base_stats.keys():
		temp_stats[base_stat_name] = _base_stats[base_stat_name]
	for set_stat_name in set_stats.keys():
		temp_stats[set_stat_name] = set_stats[set_stat_name]
	for attribute_name in attribute_levels.keys():
		temp_stats[attribute_name] += attribute_levels[attribute_name]
		
	
	# Add current values for bar stats
	for stat_name:String in temp_stats.keys():
		if stat_name.begins_with("BarStat:") and _cached_stats.keys().has(stat_name):
				temp_stats[stat_name] = _cached_stats.get(stat_name, 0)
		elif stat_name.begins_with("BarMax:"):
			var bar_stat_name = stat_name.replace("BarMax:","BarStat:")
			if not temp_stats.keys().has(bar_stat_name):
				temp_stats[bar_stat_name] = _cached_stats.get(bar_stat_name, temp_stats[stat_name])
	
	_cached_stats.clear()
	var safety_limit = 10
	var first_pass = true
	while (first_pass or key_depends_on_vals.size() > 0) and safety_limit > 0:
		safety_limit -= 1
		first_pass = false
		for stat_name:String in temp_stats.keys():
			if key_depends_on_vals.keys().has(stat_name):
				var still_waiting = false
				for dep_stat in key_depends_on_vals[stat_name]:
					if _cached_stats.has(dep_stat):
						key_depends_on_vals[stat_name].erase(dep_stat)
				if key_depends_on_vals[stat_name].size() > 0:
					continue
				else:
					key_depends_on_vals.erase(stat_name)
			var temp_val = float(temp_stats[stat_name])
			# Apply stat mods
			if agg_mods.keys().has(stat_name):
				var agg_stat:Dictionary = agg_mods[stat_name]
				if agg_stat.keys().has(BaseStatMod.ModTypes.Add):
					for val in agg_stat[BaseStatMod.ModTypes.Add]:
						temp_val += val
				if agg_stat.keys().has(BaseStatMod.ModTypes.AddStat):
					for val in agg_stat[BaseStatMod.ModTypes.AddStat]:
						var dep_stat_name = val['DepStat']
						var stat_scale = val['Scale']
						temp_val += _cached_stats[dep_stat_name] * stat_scale
				if agg_stat.keys().has(BaseStatMod.ModTypes.Scale):
					for val in agg_stat[BaseStatMod.ModTypes.Scale]:
						temp_val = temp_val * val
			_cached_stats[stat_name] = temp_val
	
	if LOGGING: print("--- Done Caching Stats")
	if safety_limit <= 0:
		printerr("Stat Caching Failed wth to many dependancies!")
	_stats_dirty = false
	if emit_signal:
		held_stats_changed.emit()
