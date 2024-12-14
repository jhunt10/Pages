class_name StatHolder

const HealthKey:String = "Health"
const LOGGING = true

signal stats_changed
signal bar_stat_changed

var _stats_dirty = true
var _actor:BaseActor
var _base_stats:Dictionary = {}
var _cached_stats:Dictionary = {}
var _cached_mods_names:Dictionary = {}

## Stats which used as resources (Health, Mana, ...)
#var _bar_stats:Dictionary = {}
#var _bar_stats_regen:Dictionary = {}

# Commonly accessed stats
var current_health:int:
	get: return get_bar_stat(HealthKey)
var max_health:int: 
	get: return get_bar_stat_max(HealthKey)
var level:int:
	get: return _cached_stats.get('Level',-1)

func _init(actor:BaseActor, data:Dictionary) -> void:
	_actor = actor
	# Parse Stat Data
	for key:String in data.keys():
		## BarStat max
		#if key.begins_with("Max:"):
			#var subKey = key.substr(4)
			#_bar_stats[subKey] = data[key]
			#_base_stats[key] = data[key]
		## Bar Stat Regens
		#elif key.begins_with("Regen:"):
			#var tokens = key.split(":")
			#if tokens.size() != 3:
				#printerr("StatHolder._init: Invalid BarStat Regen format: '%s' exspected 'Regen:STAT_NAME:[TURN|ROUND]'." % [key])
				#continue
			#var stat_name = tokens[1]
			#var trigger = tokens[2]
			#if !_bar_stats_regen.keys().has(stat_name):
				#_bar_stats_regen[stat_name] = {}
			#_bar_stats_regen[stat_name][trigger] = data[key]
		## Other Stats
		#elif data[key] is int or data[key] is float:
		_base_stats[key] = data[key]
	actor.equipment_changed.connect(dirty_stats)
	actor.turn_starting.connect(_on_actor_turn_start)
	actor.turn_ended.connect(_on_actor_turn_end)
	actor.round_ended.connect(_on_actor_round_end)

func dirty_stats():
	if LOGGING: print("Stats Dirty")
	_stats_dirty = true

func recache_stats():
	if LOGGING: printerr("Recaching Stats")
	_calc_cache_stats()

func get_stat(stat_name:String, default:int=0):
	var full_stat_name = stat_name
	if _stats_dirty:
		_calc_cache_stats()
	return _cached_stats.get(stat_name, default)

func get_base_stat(stat_name:String, default:int=0):
	return _base_stats.get(stat_name, default)
	
func get_bar_stat(stat_name:String):
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
		
## Reduce current value of bar stat by given val and return true if cost was be paied
func reduce_bar_stat_value(stat_name:String, val:int, allow_partial:bool=true) -> bool:
	var full_stat_name = "BarStat:" + stat_name
	if _cached_stats.has(stat_name):
		if not allow_partial and _cached_stats[stat_name] < val:
			return false
		_cached_stats[stat_name] = max(0, _cached_stats[stat_name]  - val)
		bar_stat_changed.emit()
		return true
	return false

## Increase current value of bar stat by given val
func add_to_bar_stat(stat_name:String, val:int):
	var full_stat_name = "BarStat:" + stat_name
	if _cached_stats.has(stat_name):
		_cached_stats[stat_name] = min(_cached_stats[stat_name] + val, get_bar_stat_max(stat_name))
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
	for stat_name in list_bar_stat_names():
		var regen = get_bar_stat_regen_per_turn(stat_name) 
		if regen != 0:
			add_to_bar_stat(stat_name, regen)

func _on_actor_round_end():
	for stat_name in list_bar_stat_names():
		var regen = get_bar_stat_regen_per_round(stat_name) 
		if regen != 0:
			add_to_bar_stat(stat_name, regen)


func _calc_cache_stats():
	if LOGGING: print("#Caching Stats for: %s" % _actor.ActorKey)
	
	_cached_mods_names.clear()
	# Aggregate all the mods together by stat_name, then type
	var agg_mods = {}
	var set_stats = {}
	var mods_list = _actor.effects.get_stat_mods()
	mods_list.append_array(_actor.equipment.get_all_stat_mods())
	for mod:BaseStatMod in mods_list:
		if LOGGING: print("# Found Mod '", mod.display_name, " for: %s" % _actor.ActorKey)
		
		if not agg_mods.keys().has(mod.stat_name): # Add stat name to agg mods
			agg_mods[mod.stat_name] = {}
		if not agg_mods[mod.stat_name].keys().has(mod.mod_type): # Add mod type to agg mods
			agg_mods[mod.stat_name][mod.mod_type] = []
		if not _cached_mods_names.keys().has(mod.stat_name): # Add stat name to mod list
			_cached_mods_names[mod.stat_name] = []
			
		_cached_mods_names[mod.stat_name].append(mod.display_name)
		if mod.mod_type	 == BaseStatMod.ModTypes.Set:
			if set_stats.keys().has(mod.stat_name):
				printerr("StatHolder._calc_cache_stats: Multiple 'Set' mods found on stat '%s'." % [mod.stat_name])
			set_stats[mod.stat_name] = mod.value
		elif mod.mod_type	 == BaseStatMod.ModTypes.Add:
			if not _base_stats.keys().has(mod.stat_name):
				if not set_stats.keys().has(mod.stat_name):
					set_stats[mod.stat_name] = 0
			agg_mods[mod.stat_name][mod.mod_type].append(mod.value)
		else:
			agg_mods[mod.stat_name][mod.mod_type].append(mod.value)
		
	if LOGGING: print("- Found: %s modded stats" % agg_mods.size())
	
	# Build temp stat list from base stats and stats created by mods
	var temp_stats = {}
	for base_stat_name in _base_stats.keys():
		temp_stats[base_stat_name] = _base_stats[base_stat_name]
	for set_stat_name in set_stats.keys():
		temp_stats[set_stat_name] = set_stats[set_stat_name]
	# Add current values for bar stats
	for stat_name:String in temp_stats.keys():
		if stat_name.begins_with("BarMax:"):
			var bar_stat_name = stat_name.replace("BarMax:","BarStat:")
			if not temp_stats.keys().has(bar_stat_name):
				temp_stats[bar_stat_name] = _cached_stats.get(bar_stat_name, temp_stats[stat_name])
	
	_cached_stats.clear()
	for stat_name:String in temp_stats.keys():
		# No mods for stat
		if not agg_mods.keys().has(stat_name):
			_cached_stats[stat_name] = temp_stats[stat_name]
			continue
		#if stat_name.begins_with("Max:"):
		var agg_stat:Dictionary = agg_mods[stat_name]
		var temp_val = float(temp_stats[stat_name])
		if agg_stat.keys().has(BaseStatMod.ModTypes.Add):
			for val in agg_stat[BaseStatMod.ModTypes.Add]:
				temp_val += val
		if agg_stat.keys().has(BaseStatMod.ModTypes.Scale):
			for val in agg_stat[BaseStatMod.ModTypes.Scale]:
				temp_val = temp_val * val
		_cached_stats[stat_name] = temp_val
	if LOGGING: print("--- Done Caching Stats")
	_stats_dirty = false
	stats_changed.emit()


func apply_damage(damage, _source):
	_cached_stats["BarStat:"+HealthKey] = max(min(_cached_stats["BarStat:"+HealthKey] - damage, max_health), 0)
	if current_health <= 0:
		CombatRootControl.Instance.kill_actor(_actor)
	bar_stat_changed.emit()

func base_damge_from_stat(stat_name):
	var base_stat_val = get_stat(stat_name)
	#var weapon:BaseWeaponEquipment = _actor.equipment.get_item_in_slot(BaseEquipmentItem.EquipmentSlots.Weapon)
	#if weapon and weapon.get_damage_data().get("AtkStat", '') == stat_name:
		#base_stat_val += weapon.get_damage_data().get("BaseDamage", 0)
	return base_stat_val

func get_base_phyical_attack():
	var strength = get_stat("Strength")
	#var weapon:BaseWeaponEquipment = _actor.equipment.get_item_in_slot(BaseEquipmentItem.EquipmentSlots.Weapon)
	#if weapon and weapon.get_damage_data().get("AtkStat", '') == "Strength":
		#strength += weapon.get_damage_data().get("BaseDamage", 0)
	return strength
	
func get_base_magic_attack():
	var intelligence = get_stat("Intelligence")
	#var weapon:BaseWeaponEquipment = _actor.equipment.get_item_in_slot(BaseEquipmentItem.EquipmentSlots.Weapon)
	#if weapon and weapon.get_damage_data().get("AtkStat", '') == "Intelligence":
		#intelligence += weapon.get_damage_data().get("BaseDamage", 0)
	return intelligence

func get_mod_names_for_stat(stat_name:String)->Array:
	if _cached_mods_names.keys().has(stat_name):
		return _cached_mods_names[stat_name]
	return []
