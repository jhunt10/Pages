class_name ActionQueData

var _que_holder:ActionQueHolder
# Raw array of dictionary for each turn
var _turns_data:Array = []
# Current index of qued pages
#var _qued_turn_index:int = 0


## Mapping from turn index to "real" que index to account for padding
# Positive numbers denote real_que index offset by 1	Example: 3 padded to 6 [1,-1,2,-2,3,-3]
# Negative numbers represent padded slots and point back to last real_que index
var _turn_to_que_index_mapping:Array = []

## Mapping from que index to corasponding _turn_data index
var _que_index_to_turn_mapping:Array = []

var _max_que_size:int:
	get:
		return _que_index_to_turn_mapping.size()

func _init(que_holder, padding_array:Array) -> void:
	_que_holder = que_holder
	# Build _turns_data by filling with empty dicts
	# And set turn mapping as we incriment _max_que_size
	for index in range(padding_array.size()):
		# Is Action
		if padding_array[index]:
			_turns_data.append({"IsAction": true})
			_turn_to_que_index_mapping.append(_max_que_size+1)
			_que_index_to_turn_mapping.append(index)
		# Is Gap
		else:
			_turns_data.append({"IsGap":true})
			_turn_to_que_index_mapping.append(-(_max_que_size+1))

func copy_from_que(other_que:ActionQueData):
	for turn_index in range(other_que._max_que_size):
		if other_que.is_turn_gap(turn_index):
			continue
		var other_page = other_que.get_action_for_turn(turn_index)
		if other_page:
			var turn_data = other_que.get_data_for_turn(turn_index)
			self.que_action(other_page, {}, turn_data)
		
	

##################################
##    Turn to Index Mapping
##################################

func _turn_to_que_index(turn_index:int)->int:
	if turn_index < 0 or turn_index >= _turn_to_que_index_mapping.size():
		return -1
	var real_index = _turn_to_que_index_mapping[turn_index]
	if real_index < 0:
		real_index = -real_index
	return real_index-1

##################################
##    Actions
##################################

func que_action(action:PageItemAction, on_que_data:Dictionary, turn_execution_data:TurnExecutionData=null)->bool:
	# Check if _qued_index is open
	var _qued_turn_index = 0
	while _qued_turn_index < _turns_data.size():
		var turn_data = _turns_data[_qued_turn_index]
		# Is Gap
		if turn_data.get("IsGap", false):
			_qued_turn_index += 1
			continue
		# Already has an Action
		if turn_data.get("ActionId", false):
			_qued_turn_index += 1
			continue
		# This one
		break
	# No open turn found
	if _qued_turn_index >= _turns_data.size():
		return false
	if !turn_execution_data:
		turn_execution_data = TurnExecutionData.new(_que_holder.actor, on_que_data)
	var queing_turn_data = _turns_data[_qued_turn_index]
	queing_turn_data['ActionId'] = action.Id
	queing_turn_data['TurnExecData'] = turn_execution_data
	return true

func delete_at_index(que_index:int):
	var turn_index = _turn_to_que_index_mapping.find(que_index+1)
	delete_at_turn_index(turn_index)

func delete_at_turn_index(turn_index:int):
	if turn_index < 0 or turn_index >= _turns_data.size():
		printerr("ActionQueData.delete_at_index: Invalid turn_index: %s" % [turn_index])
		return
	var old_action_turn_data = []
	for index in range(_turns_data.size()):
		if index == turn_index:
			continue
		var turn_data:Dictionary = _turns_data[index]
		if turn_data.get("IsAction", false):
			old_action_turn_data.append(turn_data)
	
	for index in range(_turns_data.size()):
		var turn_data:Dictionary = _turns_data[index]
		if turn_data.get("IsGap", false):
			continue
		if old_action_turn_data.size() > 0:
			_turns_data[index] = old_action_turn_data[0]
			old_action_turn_data.remove_at(0)
		else:
			_turns_data[index] = {"IsAction": true}
	

func is_ready()->bool:
	var ready = true
	var check_index = 0
	while ready and check_index < _turns_data.size():
		var turn_data = _turns_data[check_index]
		check_index += 1
		# Is Gap
		if turn_data.get("IsGap", false):
			continue
		# Already has an Action
		if turn_data.get("ActionId", false):
			continue
		ready = false
	return ready

func is_turn_gap(turn_index:int)->bool:
	if turn_index < 0 or turn_index >= _turns_data.size():
		#printerr("ActionQueData.is_turn_gap: Invalid turn_index: %s" % [turn_index])
		return true
	var turn_data = _turns_data[turn_index]
	return turn_data.get("IsGap", false)

func list_qued_action_ids():
	var out_list = []
	for turn_data in _turns_data:
		var action_id = turn_data.get("ActionId", null)
		if !action_id:
			continue
		out_list.append(action_id)
	return out_list
	
func list_qued_actions():
	var out_list = []
	var actor = _que_holder.actor
	for turn_data in _turns_data:
		var action_id = turn_data.get("ActionId", null)
		if !action_id:
			continue
		var action = actor.get_action_page(action_id)
		if action:
			out_list.append(action)
	return out_list

func get_action_for_turn(turn_index : int)->PageItemAction:
	if turn_index < 0 or turn_index >= _turns_data.size():
		printerr("ActionQueData.get_action_for_turn: Invalid turn_index: %s" % [turn_index])
		return null
	var turn_data = _turns_data[turn_index]
	var action_id = turn_data.get("ActionId", null)
	if !action_id:
		return null
	return _que_holder.actor.get_action_page(action_id)

func get_last_qued_action()->PageItemAction:
	var qued_actions = list_qued_actions()
	if qued_actions.size() > 0:
		return qued_actions[qued_actions.size()-1]
	return null


##################################
##    Turn Data
##################################

func get_data_for_turn(turn_index:int)->TurnExecutionData:
	if turn_index < 0:
		printerr("Faked Turn Data")
		return TurnExecutionData.new(_que_holder.actor, {})
	if turn_index < 0 or turn_index >= _turns_data.size():
		printerr("ActionQueData.get_data_for_turn: Invalid turn_index: %s" % [turn_index])
		return null
	var turn_data = _turns_data[turn_index]
	return turn_data.get("TurnExecData", null)

func get_current_turn_data()->TurnExecutionData:
	var current_turn = CombatRootControl.QueController.action_index
	return get_data_for_turn(current_turn)
