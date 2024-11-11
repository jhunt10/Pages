class_name ActionQue

signal action_list_changed

var Id : String :
	get: return actor.Id
var QueExecData:QueExecutionData

var actor:BaseActor
var real_que : Array = []
var _cached_max_que_size:int = -1

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
	actor.stats.stats_changed.connect(_cache_que_info)
	QueExecData = QueExecutionData.new(self)

func _cache_que_info():
	var que_size = actor.stats.get_stat("PagesPerRound", -1)
	if que_size < 0:
		que_size = actor.get_load_val("MaxQueSize", 0)
	#var que_equipments = actor.equipment.get_equipt_items_of_slot_type("Que")
	#for que_equipment:BaseQueEquipment in que_equipments:
		#que_size += que_equipment.get_max_que_size()
	#
	#_cached_max_page_count = page_count
	if _cached_max_que_size != que_size:
		_cached_max_que_size = que_size
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
	actor.on_turn_failed()

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

func get_action_for_turn(turn_index : int):
	var real_index = turn_to_que_index(turn_index)
	if real_index < 0 or real_index >= real_que.size():
		return null
	return real_que[real_index]
	
func que_action(action:BaseAction, data:Dictionary={}):
	if real_que.size() < get_max_que_size():
		real_que.append(action)
		if action.CostData.size() > 0:
			data["CostData"] = action.CostData
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
	var current_pos = CombatRootControl.Instance.GameState.MapState.get_actor_pos(actor)
	for action:BaseAction in real_que:
		if action.PreviewMoveOffset:
			var next_pos = MoveHandler.relative_pos_to_real(current_pos, action.PreviewMoveOffset)
			# Position not changeing (turning)
			if current_pos.x == next_pos.x and current_pos.y == next_pos.y:
				current_pos = next_pos
			# Check if spot is open
			elif MoveHandler.spot_is_valid_and_open(CombatRootControl.Instance.GameState, next_pos):
				current_pos = next_pos
			#print("Before: " + str(befor) + " | Prev: " + str(action.PreviewMoveOffset) + " | After: " + str(current_pos))
	return current_pos

func get_total_preview_costs():
	var costs = {}
	for action:BaseAction in real_que:
		for key in action.CostData.keys():
			if !costs.keys().has(key):
				costs[key] = action.CostData[key]
			else:
				costs[key] += action.CostData[key]
	return costs

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
