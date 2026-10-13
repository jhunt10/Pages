class_name ActionQueHolder

signal action_que_changed

var Id : String :
	get: return actor.Id

var actor:BaseActor
var _current_que:ActionQueData
## List corisponding to turns, 1 when Action, 0 when Gap
var _turn_padding:Array

func _init(act) -> void:
	if act.Que:
		printerr("Actor already has que")
		return
	actor = act
	actor.Que = self
	_current_que = ActionQueData.new(self, [true])

func fail_turn():
	var turn_data = get_current_turn_data()
	if !turn_data:
		return
	if turn_data.turn_failed:
		return
	turn_data.turn_failed = true
	turn_data.turn_executed = true
	actor.action_failed.emit()

func fail_round():
	var current_turn = CombatRootControl.QueController.action_index
	for turn_index in range(_current_que._max_turn_count):
		if turn_index < current_turn:
			continue
		var turn_data = _current_que.get_data_for_turn(turn_index)
		if !turn_data:
			continue
		if turn_data.turn_failed:
			continue
		turn_data.turn_failed = true
		turn_data.turn_executed = true
	actor.action_failed.emit()
		

func get_max_que_size()->int:
	if CombatRootControl.is_valid():
		if CombatRootControl.Instance.QueController._cached_que_ppr.keys().has(self.Id):
			return CombatRootControl.Instance.QueController._cached_que_ppr[self.Id]
	var que_size = actor.stats.get_stat("PPR", -1)
	return que_size

func list_qued_actions(include_actions_on_gaps:bool=true):
	return _current_que.list_qued_actions(include_actions_on_gaps)

func is_turn_gap(turn_index:int)->bool:
	var max_size = _current_que._max_que_size
	if max_size == 0:
		return true
	return _current_que.is_turn_gap(turn_index)

func is_ready()->bool:
	return _current_que.is_ready()

func get_action_for_turn(turn_index : int)->PageItemAction:
	return _current_que.get_action_for_turn(turn_index)

func get_last_qued_action()->PageItemAction:
	return _current_que.get_last_qued_action()

func que_action(action:PageItemAction, data:Dictionary={}):
	if action == null:
		return
	if _current_que.que_action(action, data):
		action_que_changed.emit()
		action.ammo_changed.emit()

func que_to_deploy_other_actor(page:PageItemAction, deploying_actor_id:String, relative_pos:MapPos, transfer_actor_ids:Array=[]):
	var deploy_on_turn = _current_que.get_current_qued_turns_count()
	if self.que_action(page, {
			"DeploymentPos": relative_pos,
			"DeployingActorId": deploying_actor_id,
			"TransferActorIds": transfer_actor_ids
		}):
			return
	var deploying_actor = ActorLibrary.get_actor(deploying_actor_id)
	deploying_actor.Que.build_deployment_que(deploy_on_turn)
	for transfer_actor_id in transfer_actor_ids:
		var transfer_actor = ActorLibrary.get_actor(transfer_actor_id)
		transfer_actor.Que.que_for_transfer(deploying_actor_id, deploy_on_turn)
		
	actor.page_list_changed.emit()
	action_que_changed.emit()

func build_deployment_que(deploy_on_turn):
	_current_que = ActionQueData.build_deployment_que(_current_que, deploy_on_turn)
	action_que_changed.emit()


func que_for_transfer(to_carrier_id:String, on_turn_index:int):
	_current_que.que_for_transfer(to_carrier_id, on_turn_index)
	
func is_qued_for_transfer()->bool:
	return _current_que.is_qued_for_transfer()

func is_tansfering_away_from(actor_id)->bool:
	var transfer_to_actor_ids = _current_que._qued_transfer_data.keys()
	return not transfer_to_actor_ids.has(actor_id)
	
func is_qued_for_deploy()->bool:
	var qued_actions = _current_que.list_qued_action_ids()
	return qued_actions.has("BeDeployed_ActionPage")

func get_turn_index_of_deploy()->int:
	for index in range(_current_que._max_turn_count):
		if _current_que.get_action_id_for_turn(index) == "BeDeployed_ActionPage":
			return index
	return -1

func count_qued_page_uses(page:PageItemAction)->int:
	var qued_page_ids = _current_que.list_qued_action_ids()
	return qued_page_ids.count(page.Id)

func clear_que(supress_signals:bool=false):
	for turn_index in range(_current_que._max_que_size):
		var turn_data = get_data_for_turn(turn_index)
		if !turn_data or turn_data.turn_executed:
			continue
		var check_action_id = _current_que.get_action_id_for_turn(turn_index)
		if check_action_id.begins_with("Deploy_ActionPage"):
			_delete_qued_deploy_action(turn_index)
		
	_current_que = ActionQueData.new(self, _turn_padding)
	if not supress_signals:
		action_que_changed.emit()

func delete_at_index(que_index):
	var turn_index = _current_que.que_index_to_turn_index(que_index)
	self.delete_at_turn_index(turn_index)

func delete_at_turn_index(turn_index):
	var available_action_pages_changed = false
	var action_id = _current_que.get_action_id_for_turn(turn_index)
	
	# Check if deployment action is being deleted
	if action_id.begins_with("Deploy_ActionPage"):
		_delete_qued_deploy_action(turn_index)
		# Unqueing deploy action changes actions available to carrier
		available_action_pages_changed = true
	
	# Delete Action
	_current_que.delete_at_turn_index(turn_index)
	
	# Check for shifted deploy_actions
	for offset in range(_current_que._max_que_size - turn_index):
		var check_index = turn_index + offset
		var check_action_id = _current_que.get_action_id_for_turn(check_index)
		if check_action_id.begins_with("Deploy_ActionPage"):
			var turn_data = _current_que.get_data_for_turn(check_index)
			# Rebuild deployment que for actors that will be deployed
			var deploying_actor_id = turn_data.on_que_data.get("DeployingActorId", "")
			var deploying_actor = ActorLibrary.get_actor(deploying_actor_id)
			if deploying_actor:
				deploying_actor.Que.build_deployment_que(check_index)
			# Update transer data for actors that will be transfered
			var transfer_actor_ids = turn_data.on_que_data.get("TransferActorIds", "")
			for transfer_actor_id in transfer_actor_ids:
				var transfer_actor = ActorLibrary.get_actor(transfer_actor_id)
				if transfer_actor:
					transfer_actor.Que.que_for_transfer(deploying_actor_id, check_index)
	if available_action_pages_changed:
		actor.page_list_changed.emit()
	action_que_changed.emit()

func _delete_qued_deploy_action(turn_index:int):
	var turn_data = _current_que.get_data_for_turn(turn_index)
	# Clear que for actors that will be deployed
	var deploying_actor_id = turn_data.on_que_data.get("DeployingActorId", "")
	var deploying_actor = ActorLibrary.get_actor(deploying_actor_id)
	if deploying_actor:
		
		deploying_actor.Que.clear_que()
		DeploymentHelper.un_deploy_preview(deploying_actor)
	# Clear que for actors that will be transfered
	var transfer_actor_ids = turn_data.on_que_data.get("TransferActorIds", "")
	for transfer_actor_id in transfer_actor_ids:
		var transfer_actor = ActorLibrary.get_actor(transfer_actor_id)
		if transfer_actor:
			transfer_actor.Que.clear_que()


func turn_index_to_que_index(turn_index)->int:
	return _current_que._turn_to_que_index(turn_index)
	
func que_index_to_turn_index(que_index)->int:
	return _current_que._que_index_to_turn_mapping[que_index]

func get_data_for_turn(turn_index:int)->TurnExecutionData:
	return _current_que.get_data_for_turn(turn_index)

func get_current_turn_data()->TurnExecutionData:
	return _current_que.get_current_turn_data()

func get_on_qued_prop_values(prop_key:String)->Array:
	var out_list = []
	for turn_index in range(_turn_padding.size()):
		var turn_data = _current_que.get_data_for_turn(turn_index)
		if turn_data and turn_data.on_que_data.keys().has(prop_key):
			out_list.append(turn_data.on_que_data[prop_key])
	return out_list

func get_preview_start_pos():
	if actor.Que.is_qued_for_deploy():
		if actor.is_being_carried():
			var carrier = actor.get_carrier_actor()
			var deploy_on_turn = actor.Que.get_turn_index_of_deploy()
			var carrier_pos = carrier.Que.get_preview_pos_for_turn(deploy_on_turn)
			var turn_data = carrier.Que.get_data_for_turn(deploy_on_turn)
			var deploy_pos = turn_data.on_que_data.get("DeploymentPos")
			if deploy_pos:
				return MapPos.new(
					carrier_pos.x + deploy_pos.x,
					carrier_pos.y + deploy_pos.y,
					carrier_pos.z,
					deploy_pos.dir)
			return carrier_pos
		else:
			var actor_node = CombatRootControl.get_actor_node(actor)
			if actor_node:
				return actor_node.cur_map_pos
	return CombatRootControl.Instance.GameState.get_actor_pos(actor)
		

func get_preview_pos_for_turn(turn_index:int, start_pos:MapPos = null):
	if !start_pos:
		start_pos = get_preview_start_pos()
	var poses = _current_que.get_preview_poses_per_turn(start_pos)
	if poses.size() == 0:
		return start_pos
	if poses.size() > turn_index:
		return poses[turn_index]
	else:
		return poses[-1]

# Get the end position if all qued movement actions were resolved
func get_movement_preview_final_pos(start_pos:MapPos = null)->MapPos:
	if !start_pos:
		start_pos = get_preview_start_pos()
	var path = _current_que.get_preview_poses_per_turn(start_pos)
	if path.size() > 0:
		return path[-1]
	return null
	
# Called by ActionQurControl._pad_ques()
func _set_turn_padding(gap_or_nots:Array):
	var is_match = true
	if not _turn_padding or _turn_padding.size() != gap_or_nots.size():
		is_match = false
	if is_match:
		for index in range(_turn_padding.size()):
			if _turn_padding[index] != gap_or_nots[index]:
				is_match = false
				break
	if is_match:
		return
	_turn_padding = gap_or_nots
	var new_que = ActionQueData.new(self, gap_or_nots)
	new_que.copy_from_que(_current_que)
	_current_que = new_que
	action_que_changed.emit()
