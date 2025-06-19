class_name ActionQue

signal action_list_changed
signal ammo_changed(action_key:String)

var Id : String :
	get: return actor.Id
var QueExecData:QueExecutionData

var actor:BaseActor
var real_que : Array = []
var _cached_max_que_size:int = -1

# Keyed off ActionKey, contains:
#		"Cost": per use
#		"Clip": max value
#		"Value": Current Value of Clip
#		"AmmoType": AmmoItem.AmmoType
#		"FreeChance": Chance to not consume ammo
#		"PreviewUses": Number of times it's qued
var _page_ammo_datas:Dictionary = {}
var _cached_ammo_mods:Dictionary
var _ammo_mod_dirty:bool=true

## Mapping from turn index to real_que index to account for padding
# Positive numbers denote real_que index offset by 1	Example: 3 padded to 6 [1,-1,2,-2,3,-3]
# Negative numbers represent padded slots and point back to last real_que index
var _turn_mapping:Array

signal action_que_changed
signal max_que_size_changed

func _init(act) -> void:
	if act.Que:
		printerr("Actor already has que")
		return
	actor = act
	actor.Que = self
	_cache_que_info(true)
	actor.stats_changed.connect(_cache_que_info)
	QueExecData = QueExecutionData.new(self)

func _cache_que_info(supress_emit:bool=false):
	var que_size = actor.stats.get_stat("PPR", 0)
	if _cached_max_que_size != que_size:
		_cached_max_que_size = que_size
		if not supress_emit:
			max_que_size_changed.emit()
	else:
		_cached_max_que_size = que_size

func fail_turn():
	var turn_data = QueExecData.get_current_turn_data()
	if !turn_data:
		return
	if turn_data.turn_failed:
		return
	turn_data.turn_failed = true
	actor.action_failed.emit()

func get_max_que_size()->int:
	if _cached_max_que_size < 0:
		_cache_que_info()
	return _cached_max_que_size

func list_qued_actions():
	return real_que

func is_turn_gap(turn_index:int)->bool:
	if turn_index < 0 or turn_index >= _turn_mapping.size():
		return true
	return _turn_mapping[turn_index] < 0

func turn_to_que_index(turn_index:int)->int:
	if turn_index < 0 or turn_index >= _turn_mapping.size():
		return -1
	var real_index = _turn_mapping[turn_index]
	if real_index < 0:
		real_index = -real_index
	return real_index-1

func is_ready()->bool:
	return real_que.size() ==  get_max_que_size()

func get_action_for_turn(turn_index : int)->PageItemAction:
	var real_index = turn_to_que_index(turn_index)
	if real_index < 0 or real_index >= real_que.size():
		return null
	return real_que[real_index]
	
func que_action(action:PageItemAction, data:Dictionary={}):
	if real_que.size() < get_max_que_size() and action != null:
		real_que.append(action)
		QueExecData.que_data(data)
		action_que_changed.emit()
		
func clear_que():
	real_que.clear()
	action_que_changed.emit()
	QueExecData.clear()

func delete_at_index(index):
	if index < 0:
		return
	if index < real_que.size():
		real_que.remove_at(index)
		QueExecData.TurnDataList.remove_at(index)
		action_que_changed.emit()
	
# Get the end position if all qued movement actions were resolved
func get_movement_preview_pos()->MapPos:
	var path = get_movement_preview_path()
	if path.size() > 0:
		return path[-1]
	return null

func get_movement_preview_path()->Array:
	var current_pos = CombatRootControl.Instance.GameState.get_actor_pos(actor)
	if !current_pos:
		return []
	var path = [current_pos]
	for action:PageItemAction in real_que:
		if action.has_preview_move_offset():
			var next_pos = MoveHandler.relative_pos_to_real(current_pos, action.get_preview_move_offset())
			# Position not changeing (turning)
			if current_pos.x == next_pos.x and current_pos.y == next_pos.y:
				current_pos = next_pos
				path.append(current_pos)
			# Check if spot is open
			elif MoveHandler.is_spot_traversable(CombatRootControl.Instance.GameState, next_pos, actor):
				current_pos = next_pos
				path.append(current_pos)
			#print("Before: " + str(befor) + " | Prev: " + str(action.get_preview_move_offset() + " | After: " + str(current_pos))
	return path

# Called by ActionQurControl._calc_turn_padding()
func _set_turn_mapping(gap_or_nots:Array):
	_turn_mapping.clear()
	var last_index = 1
	for not_gap in gap_or_nots:
		if not_gap:
			_turn_mapping.append(last_index)
			last_index += 1
		else:
			_turn_mapping.append(-last_index)

func dirty_ammo_mods():
	_ammo_mod_dirty = true

func rechache_page_ammo():
	_cache_page_ammo()

func _cache_page_ammo():
	# Backup current ammo values before we wipe the list
	var current_values = {}
	for key in _page_ammo_datas.keys():
		current_values[key] = _page_ammo_datas[key]["Value"]
	_page_ammo_datas.clear()
	
	var _cached_ammo_mods = actor.get_ammo_mods()
	var ammo_mods = {}
	var type_mods = {}
	for mod_key in _cached_ammo_mods.keys():
		var mod_data = _cached_ammo_mods[mod_key]
		var mod_type = mod_data.get("ModType", "")
		if mod_type == "ChangeType":
			type_mods[mod_key] = mod_data
		elif mod_type != '':
			ammo_mods[mod_key] = mod_data
	
	for action:PageItemAction in actor.pages.list_actions():
		if not action.has_ammo():
			continue
		var key = action.ActionKey
		var ammo_data = action.get_ammo_data().duplicate()
		var cost = ammo_data.get("Cost", 1)
		var clip = ammo_data.get("Clip", 1)
		var ammo_type_str =  ammo_data.get("AmmoType", "NOT SET")
		var free_chance =  ammo_data.get("FreeChance", 0)
		var ammo_type = AmmoItem.AmmoTypes.get(ammo_type_str)
		if ammo_type < 0:
			_page_ammo_datas[key] = {
				"Cost": 1,
				"Clip": 1,
				"Value": 0,
				"AmmoType": AmmoItem.AmmoTypes.Abn,
				"FreeChance": 0,
				"PreviewUses": 0,
				"ModKeys": []
			}
			printerr("ActionQue._cache_page_ammo: Action '%s' has unknown AmmoType '%s'." % [key, ammo_type_str])
			continue
		
		var appply_mods_keys = []
		# Check which type changing mods apply
		if type_mods.size() > 0:
			var apply_type_mods = {}
			for mod_key in type_mods.keys:
				var mod_data = ammo_mods[mod_key]
				if _does_ammo_mod_apply_to_action(mod_data, ammo_data, action, actor):
					apply_type_mods[key] = mod_data
			# If multiple mods are found, apply none
			if apply_type_mods.size() > 1:
				printerr("ActionQue._cache_page_ammo: Multiple AmmoTypeMods found for '%s' '%s': %s" % [actor.Id, action.ActionKey, apply_type_mods.keys()])
			elif apply_type_mods.size() == 1:
				var new_ammo_type_str = apply_type_mods.values()[0]["Value"]
				var new_ammo_type = AmmoItem.AmmoTypes.get(new_ammo_type_str)
				if ammo_type < 0:
					printerr("ActionQue._cache_page_ammo: Ammo Mod '%s' has unknown AmmoType '%s'." % [apply_type_mods.keys()[0], new_ammo_type_str])
				else:
					appply_mods_keys.append(apply_type_mods.keys()[0])
					ammo_data["AmmoType"] = new_ammo_type_str
					ammo_type_str = new_ammo_type_str
					ammo_type = new_ammo_type
		
		for mod_key in ammo_mods.keys():
			var mod_data = ammo_mods[mod_key]
			var mod_type = mod_data.get("ModType", "")
			var default = 1
			if mod_type == "NoCostChance": default = 0
			var mod_value = mod_data.get("Value", default)
			if not _does_ammo_mod_apply_to_action(mod_data, ammo_data, action, actor):
				continue
			
			if mod_type == "ScaleClip":
				clip = clip * mod_value
			elif mod_type == "ScaleCost":
				cost = cost * mod_value
			elif mod_type == "FreeChance":
				free_chance += mod_value
			appply_mods_keys.append(mod_key)
		
		_page_ammo_datas[key] = {
			"Cost": cost,
			"Clip": clip,
			"Value": current_values.get(key, clip),
			"AmmoType": ammo_type,
			"FreeChance": free_chance,
			"PreviewUses": 0,
			"ModKeys": appply_mods_keys
		}
	_ammo_mod_dirty = false
	for key in _page_ammo_datas.keys():
		ammo_changed.emit(key)

func _does_ammo_mod_apply_to_action(mod_data:Dictionary, ammo_data:Dictionary, action:PageItemAction, actor)->bool:
	if not action.has_ammo():
		return false
	
	var conditions = mod_data.get("Conditions", null)
	if not conditions:
		return true
	
	var ammo_types = conditions.get("AmmoTypes", [])
	if ammo_types.size() > 0:
		var ammo_type = ammo_data.get("AmmoType", "NOTSET")
		if not ammo_types.has(ammo_type):
			return false
	
	var tag_filters = conditions.get("ActionTagFilters", [])
	for filter in tag_filters:
		if not SourceTagChain.filters_accept_tags(filter, action.get_tags()):
			return false
	
	return true

func fill_page_ammo(action_key:String="", supress_signal:bool=false):
	if _ammo_mod_dirty:
		_cache_page_ammo()
	if action_key == "":
		for key in _page_ammo_datas.keys():
			fill_page_ammo(key, true)
			if not supress_signal:
				ammo_changed.emit(key)
	else:
		var ammo_data = _page_ammo_datas.get(action_key, null)
		if not ammo_data:
			return
		ammo_data["Value"] = ammo_data["Clip"]
		if not supress_signal:
			ammo_changed.emit(action_key)

func get_page_ammo_type(action_key:String)->AmmoItem.AmmoTypes:
	if _ammo_mod_dirty:
		_cache_page_ammo()
	var ammo_data = _page_ammo_datas.get(action_key, null)
	if not ammo_data:
		return AmmoItem.AmmoTypes.Limit
	return ammo_data["AmmoType"]

func get_page_ammo_max_clip(action_key:String)->int:
	if true or _ammo_mod_dirty:
		_cache_page_ammo()
	var ammo_data = _page_ammo_datas.get(action_key, null)
	if not ammo_data:
		return 0
	return ceilf(ammo_data["Clip"])

func get_page_ammo_cost_per_use(action_key:String)->int:
	if _ammo_mod_dirty:
		_cache_page_ammo()
	var ammo_data = _page_ammo_datas.get(action_key, null)
	if not ammo_data:
		return 0
	return ceilf(ammo_data["Cost"])

func get_page_ammo_current_value(action_key:String)->int:
	if _ammo_mod_dirty:
		_cache_page_ammo()
	var ammo_data = _page_ammo_datas.get(action_key, null)
	if not ammo_data:
		return 0
	return ceilf(ammo_data["Value"])

func can_pay_page_ammo(action_key:String)->bool:
	if _ammo_mod_dirty:
		_cache_page_ammo()
	var ammo_data = _page_ammo_datas.get(action_key, null)
	if not ammo_data:
		return true
	return ammo_data["Value"] >= ammo_data["Cost"]

func try_consume_page_ammo(action_key:String)->bool:
	if _ammo_mod_dirty:
		_cache_page_ammo()
	var ammo_data = _page_ammo_datas.get(action_key, null)
	if not ammo_data:
		return true
	if ammo_data["Value"] < ammo_data["Cost"]:
		return false
	var free_chance = ammo_data.get("FreeChance", 0)
	if free_chance > 0:
		var roll = RandomHelper.roll()
		if roll <= free_chance:
			return true
	ammo_data["Value"] = max(ammo_data["Value"] - ammo_data["Cost"], 0)
	ammo_changed.emit(action_key)
	return true
