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

var _locked_max_que_size:int
var _max_que_size:int

var _max_turn_count:int

var _qued_transfer_data:Dictionary = {}

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
			_max_que_size = _que_index_to_turn_mapping.size()
		# Is Gap
		else:
			_turns_data.append({"IsGap":true})
			_turn_to_que_index_mapping.append(-(_max_que_size+1))
	_max_que_size = _que_index_to_turn_mapping.size()
	_locked_max_que_size = _max_que_size
	_max_turn_count = _turn_to_que_index_mapping.size()
	

func copy_from_que(other_que:ActionQueData):
	for turn_index in range(other_que._max_que_size):
		if other_que.is_turn_gap(turn_index):
			continue
		var other_page = other_que.get_action_for_turn(turn_index)
		if other_page:
			var turn_data = other_que.get_data_for_turn(turn_index)
			self.que_action(other_page, {}, turn_data)
	_qued_transfer_data = other_que._qued_transfer_data.duplicate()
		
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

func que_index_to_turn_index(que_index:int)->int:
	if que_index < 0 or que_index >= _que_index_to_turn_mapping.size():
		return -1
	var real_index = _que_index_to_turn_mapping[que_index]
	return real_index

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

func delete_at_que_index(que_index:int):
	var turn_index = _turn_to_que_index_mapping.find(que_index+1)
	delete_at_turn_index(turn_index)

func delete_at_turn_index(turn_index:int):
	if turn_index < 0 or turn_index >= _turns_data.size():
		printerr("ActionQueData.delete_at_turn_index: Invalid turn_index: %s" % [turn_index])
		return
	var old_action_turn_data = []
	# Collect old turn data
	for index in range(_turns_data.size()):
		if index == turn_index:
			continue
		var turn_data:Dictionary = _turns_data[index]
		if turn_data.get("IsAction", false):
			old_action_turn_data.append(turn_data)
	# Re-apply old turn data
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
	
func list_qued_actions(include_actions_on_gaps:bool=true):
	var out_list = []
	var actor = _que_holder.actor
	for turn_data in _turns_data:
		if turn_data.get("IsGap", false):
			if not include_actions_on_gaps:
				continue
		var action_id = turn_data.get("ActionId", null)
		if !action_id:
			continue
		var action = actor.get_action_page(action_id)
		if action:
			out_list.append(action)
	return out_list

func get_action_id_for_turn(turn_index : int)->String:
	if turn_index < 0 or turn_index >= _turns_data.size():
		printerr("ActionQueData.get_action_for_turn: Invalid turn_index: %s" % [turn_index])
		return ""
	var turn_data = _turns_data[turn_index]
	var action_id = turn_data.get("ActionId", "")
	return action_id
	
func get_action_for_turn(turn_index : int)->PageItemAction:
	var action_id = get_action_id_for_turn(turn_index)
	if action_id == "":
		return null
	return _que_holder.actor.get_action_page(action_id)

func get_last_qued_action()->PageItemAction:
	var qued_actions = list_qued_actions()
	var index = 0
	while index < qued_actions.size():
		var action:PageItemAction = qued_actions[index]
		if action.ActionKey == "WaitToBeDeployed_ActionPage":
			qued_actions.remove_at(index)
		else:
			index += 1
			
	if qued_actions.size() > 0:
		return qued_actions[qued_actions.size()-1]
	return null

func get_current_qued_turns_count()->int:
	for index in range(_turns_data.size()):
		var turn_data = _turns_data[index]
		if is_turn_gap(index):
			continue
		var action_id = turn_data.get("ActionId", null)
		if !action_id:
			return index
	return _max_turn_count
	

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


##################################
##    Que Previewing
##################################

func get_preview_poses_per_turn(start_pos:MapPos)->Array:
	var out_list = []
	if !start_pos:
		return out_list
	var cur_pos = start_pos.duplicate()
	var actor = _que_holder.actor
	for turn_index in range(_max_turn_count):
		var action:PageItemAction = get_action_for_turn(turn_index)
		if action and action.has_preview_move_offset():
			var next_pos = MoveHandler.relative_pos_to_real(cur_pos, action.get_preview_move_offset())
			# Position not changeing (turning)
			if cur_pos.x == next_pos.x and cur_pos.y == next_pos.y:
				cur_pos = next_pos
				out_list.append(cur_pos)
			# Check if spot is open
			elif MoveHandler.is_spot_traversable(CombatRootControl.Instance.GameState, next_pos, actor):
				cur_pos = next_pos
				out_list.append(cur_pos)
		else:
			out_list.append(cur_pos)
			#print("Before: " + str(befor) + " | Prev: " + str(action.get_preview_move_offset() + " | After: " + str(current_pos))
	return out_list

##################################
##    Deployment
##################################

func que_for_transfer(to_carrier_id:String, on_turn_index:int):
	_qued_transfer_data[to_carrier_id] = on_turn_index

func is_qued_for_transfer()->bool:
	return _qued_transfer_data.size() > 0

func get_deployments_preview_data()->Dictionary:
	var out_data = {}
	for turn_index in range(_max_turn_count):
		var action:PageItemAction = get_action_for_turn(turn_index)
		if !action or action.ActionKey != "Deploy_ActionPage":
			continue
		var turn_data = get_data_for_turn(turn_index)
		
		var deploying_actor_ids = []
		var main_actor_id = turn_data.on_que_data.get("DeployingActorId", "")
		deploying_actor_ids.append(main_actor_id)
		var transfer_actor_ids = turn_data.on_que_data.get("TransferActorIds", [])
		for trans_id in transfer_actor_ids:
			deploying_actor_ids.append(trans_id)
			
		var deployment_pos = turn_data.on_que_data.get("DeploymentPos", null)
		for id in deploying_actor_ids:
			out_data[id] = {
				"Pos": deployment_pos,
				"TurnIndex": turn_index
			}
	return out_data

static func build_deployment_que(old_que:ActionQueData, deploy_on_turn:int)->ActionQueData:
	var new_que = ActionQueData.new(old_que._que_holder, old_que._que_holder._turn_padding)
	# Build new que with WaitForDeploy and BeDeploy actions
	for turn_index in range(new_que._max_turn_count):
		var turn_data = new_que._turns_data[turn_index]
		# Set BeDeployed Action
		if turn_index == deploy_on_turn:
			turn_data['ActionId'] = "BeDeployed_ActionPage"
			turn_data['TurnExecData'] = TurnExecutionData.new(old_que._que_holder.actor, {})
			break
		if turn_data.get("IsGap", false):
			continue
		# Add waiting pages
		turn_data['ActionId'] = "WaitToBeDeployed_ActionPage"
		turn_data['TurnExecData'] = TurnExecutionData.new(old_que._que_holder.actor, {})
	# Copy actions from old que
	for old_turn_index in range(old_que._max_que_size):
		var old_turn_action = old_que.get_action_for_turn(old_turn_index)
		var old_turn_data = old_que.get_data_for_turn(old_turn_index) 
		if not old_turn_action:
			continue
		if old_turn_action.ActionKey == "BeDeployed_ActionPage" or old_turn_action.ActionKey == "WaitToBeDeployed_ActionPage":
			continue
		new_que.que_action(old_turn_action, {}, old_turn_data)
	return new_que
