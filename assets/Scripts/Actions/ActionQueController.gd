class_name ActionQueController

signal que_ordering_changed
signal que_marked_as_dead(que_id:String)

# End round early if no more actions are qued (for testing)
const SHORTCUT_QUE = true
const DEEP_LOGGING = false
const FRAMES_PER_ACTION = 24
const ACTION_TIME = 2.4 # Seconds
const SUB_ACTION_FRAME_TIME = ACTION_TIME / FRAMES_PER_ACTION

var scaled_sub_action_frame_time:float:
	get: return SUB_ACTION_FRAME_TIME / CombatRootControl.get_time_scale()

# Start of new Round
signal start_of_round()
signal start_of_round_with_state(game_state:GameStateData)
# Start of new Turn
signal start_of_turn()
signal start_of_turn_with_state(game_state:GameStateData)
# Start of new Frame
signal start_of_frame()
signal start_of_frame_with_state(game_state:GameStateData)
# End of current Frame
signal end_of_frame()
signal end_of_frame_with_state(game_state:GameStateData)
# End of current Turn
signal end_of_turn()
signal end_of_turn_with_state(game_state:GameStateData)
# End of current Round (before ques and execution_data have been cleared) 
signal end_of_round()
signal end_of_round_with_state(game_state:GameStateData)
# When the round has ended and all data has been cleaned up
signal after_round()

# Emitted any time the que switches to excuting action
signal execution_active
# Emitted any time the que stops executing actions
signal execution_suspended

enum ActionStates {
	Waiting, # Waiting for input
	Running, # Executing ques
	Paused, # Paused mid execution
}

var execution_state:ActionStates = ActionStates.Waiting
var sub_action_timer = 0
var sub_action_index = 0
var sub_sub_action_index = 0
var que_index = 0
var action_index = 0
var max_que_size = 0

var _action_ques:Dictionary = {}
var _que_order:Array = []
var subaction_script_cache:Dictionary = {}

# Ques that have been removed durring execution
# They will be deleted once the round finishes
var _dead_ques:Array = []

func _start_round():
	if DEEP_LOGGING: print("QueController: Start Round")
	action_index = 0
	sub_action_index = 0
	sub_sub_action_index = 0
	que_index = 0
	sub_action_timer = 0
	
	for actor:BaseActor in CombatRootControl.Instance.GameState.list_actors():
		if actor._allow_auto_que:
			actor.auto_build_que(0)
	
	execution_state = ActionStates.Running
	start_of_round.emit()
	start_of_round_with_state.emit(CombatRootControl.Instance.GameState)
	# Emit start of round for actors
	for que_id in _que_order:
		var que:ActionQue = _action_ques[que_id]
		que.actor.round_starting.emit()
	execution_active.emit()

func _end_round():
	if DEEP_LOGGING: print("QueController: End Round")
	#label.text = "Waiting"
	action_index = 0
	sub_action_index = 0
	que_index = 0
	sub_action_timer = 0
	execution_state = ActionStates.Waiting
	# Emit end of round for actors
	for que_id in _que_order:
		var que:ActionQue = _action_ques[que_id]
		que.actor.round_ended.emit()
	_cleanup_dead_ques()
	end_of_round.emit()
	end_of_round_with_state.emit(CombatRootControl.Instance.GameState)
			
	execution_suspended.emit()
	_clear_ques()
	after_round.emit()

func start_or_resume_execution():
	if execution_state == ActionStates.Waiting:
		_start_round()
	else:
		execution_state = ActionStates.Running
		execution_active.emit()

func pause_execution():
	execution_state = ActionStates.Paused
	execution_suspended.emit()

func get_paused_on_que()->ActionQue:
	return _action_ques[_que_order[que_index]]

func get_active_action_ques()->Array:
	var out_list = []
	for que in _action_ques.values():
		if not _dead_ques.has(que.Id):
			out_list.append(que)
	return out_list

# Add an action que to the controller
func add_action_que(new_que:ActionQue):
	if _action_ques.has(new_que.Id):
		return
	_action_ques[new_que.Id] = new_que
	new_que.max_que_size_changed.connect(_organize_ques)
	_organize_ques()

func remove_action_que(que:ActionQue):
	if not _dead_ques.has(que.Id):
		_dead_ques.append(que.Id)
		que_marked_as_dead.emit(que.Id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(delta: float) -> void:
	if execution_state == ActionStates.Running:
		sub_action_timer += delta
		if sub_action_timer > scaled_sub_action_frame_time:
			if DEEP_LOGGING: 
				print("") 
				print("")
				print("Doing Action: " + str(action_index) + ":" + str(sub_action_index))# + " | delta: " + str(delta))
			sub_action_timer -= scaled_sub_action_frame_time
			
			#TODO: GameState
			var game_state:GameStateData = CombatRootControl.Instance.GameState
			
			# Emit starting signals
			if sub_action_index == 0:
				start_of_turn.emit()
				start_of_turn_with_state.emit(game_state)
				_pay_turn_costs()
				# Emit start of turn for actors
				for que_id in _que_order:
					var que:ActionQue = _action_ques[que_id]
					if not que.is_turn_gap(action_index):
						que.actor.turn_starting.emit()
			
			# Start Frame
			start_of_frame.emit()
			start_of_frame_with_state.emit(game_state)
			#label.text = str(action_index) + ":" + str(sub_action_index)
			
			# Do all actions for frame
			for q_index in range(que_index, _action_ques.size()):
				var que = _action_ques[_que_order[q_index]]
				_execute_turn_frames(game_state, que, action_index, sub_action_index)
				
				# Check if the last action stopped execution
				if execution_state != ActionStates.Running:
					end_of_frame.emit()
					end_of_frame_with_state.emit(game_state)
					return
					
			# Resolve all missiles that have reached thier target
			for missile:BaseMissile in game_state.Missiles.values():
				if missile.has_reached_target():
					missile.do_thing(game_state)
					game_state.delete_missile(missile)
			
			end_of_frame.emit()
			end_of_frame_with_state.emit(game_state)
			que_index = 0
			sub_action_index += 1
			
			# All subactions for turn have finished
			if sub_action_index >= BaseAction.SUB_ACTIONS_PER_ACTION:
				end_of_turn.emit()
				end_of_turn_with_state.emit(game_state)
				# Emit end of turn for actors
				for que_id in _que_order:
					var que:ActionQue = _action_ques[que_id]
					if not que.is_turn_gap(action_index):
						que.actor.turn_ended.emit()
						
				# Reset / Increment values
				sub_action_index = 0
				que_index = 0
				action_index += 1
				
				if SHORTCUT_QUE and action_index < max_que_size:
					var any_left = false
					for q:ActionQue in get_active_action_ques():
						if q.get_action_for_turn(action_index):
							any_left = true
					if not any_left:
						if DEEP_LOGGING: print("\tShort Cutting Que")
						_end_round()
						return
				
			# All actions for que have finished
			if action_index >= max_que_size:
				if DEEP_LOGGING: print("\taction_index reach max_que_size")
				_end_round()

func _clear_ques():
	for que:ActionQue in _action_ques.values():
		que.clear_que()
		que.QueExecData.clear()

func _cleanup_dead_ques():
	if _dead_ques.size() == 0:
		return
	for dead_que_id in _dead_ques:
		_action_ques.erase(dead_que_id)
	_dead_ques.clear()
	_organize_ques()

func _execute_turn_frames(game_state:GameStateData, que:ActionQue, turn_index:int, subaction_index:int):
	if DEEP_LOGGING: print("\tChecking Que: %s(%s)" %[que.actor.ActorKey, que.Id])
	if que.is_turn_gap(turn_index):
		if DEEP_LOGGING: print("\t\tGap action")
		return
		
	# Check if Que is dead
	if _dead_ques.has(que.Id):
		if DEEP_LOGGING: print("\t\tQue is dead")
		return
		
	# Get the action for this turn
	var action:BaseAction = que.get_action_for_turn(turn_index)
	# If no action, skip. Ussually caused by smaller ques.
	if !action:
		if DEEP_LOGGING: print("\t\tNo action")
		return
	
	var turn_data = que.QueExecData.TurnDataList[que.turn_to_que_index(turn_index)]
	
	
	# Get subaction for this frame
	var sub_action_list = action.SubActionData[subaction_index]
	if !sub_action_list:
		if DEEP_LOGGING: print("\t\tNo SubAction List on action: %s" % [action.ActionKey])
		return
		
	
	if DEEP_LOGGING: print("Starting SubAction Index: %s of  %s" % [sub_sub_action_index, sub_action_list.size()])
	while sub_sub_action_index < sub_action_list.size():
		if DEEP_LOGGING: print("Executing SubAction Index: %s " % [sub_sub_action_index])
		if turn_data.turn_failed:
			if DEEP_LOGGING: print("\t\tTurn Failed")
			sub_sub_action_index = 0
			return
		var sub_action_data = sub_action_list[sub_sub_action_index]
			
		var script_key = sub_action_data['SubActionScript']
		var subaction = _get_subaction(script_key)
		if !subaction:
			printerr("No script found for subaction " + script_key)
			return
		
		if DEEP_LOGGING: print("\t\tExecuting SubAction: " + script_key)
		# Finnaly do subaction
		var result = subaction.do_thing(
			action, # Parent Action
			sub_action_data, # SubAction configuration
			que.QueExecData, # Metadata for action execution
			game_state, # GameState
			que.actor # Actor
		)
		if DEEP_LOGGING: print("SubAction finished: %s " % [result])
		if result == BaseSubAction.Failed:
			que.fail_turn()
		
		# Check if the last sub action stopped execution
		if execution_state != ActionStates.Running:
			if DEEP_LOGGING: print("\t\tExecution no loger running")
			return
		sub_sub_action_index += 1
	if DEEP_LOGGING: print("SubSubActions finished")
	# All sub actions completed
	sub_sub_action_index = 0

# Get script either load script or retreave from cache 
func _get_subaction(script_key:String)->BaseSubAction:
	if !subaction_script_cache.keys().has(script_key):
		if ResourceLoader.exists(script_key):
			var script = load(script_key)
			if script:
				var new_subaction = script.new()
				subaction_script_cache[script_key] = new_subaction
			else:
				printerr("Failed to load subaction script: " + script_key)
				subaction_script_cache[script_key] = null
		else:
			printerr("Failed to find subaction script: " + script_key)
			subaction_script_cache[script_key] = null
	return subaction_script_cache[script_key]

func _pay_turn_costs():
	pass
	#for que:ActionQue in get_active_action_ques():
		#var actor = que.actor
		#var turn_data = que.QueExecData.get_current_turn_data()
		#for stat_name in turn_data.costs.keys():
			#if not actor.stats.reduce_bar_stat_value(stat_name, turn_data.costs[stat_name], false):
				#CombatRootControl.Instance.create_flash_text_on_actor(actor, "-"+stat_name, Color.ORANGE)
				#que.fail_turn()
				#return

func _organize_ques():
	_sort_ques_by_speed()
	_calc_turn_padding()

## Sort ques in order of Actor.Speed desc
func _sort_ques_by_speed():
	var speeds = []
	var speed_to_ques = {}
	for que:ActionQue in _action_ques.values():
		var actor:BaseActor = que.actor
		var speed = actor.stats.get_stat("Speed", 0)
		if not speeds.has(speed):
			speed_to_ques[speed] = []
			speeds.append(speed)
		speed_to_ques[speed].append(que.Id)
	speeds.sort()
	speeds.reverse()
	_que_order.clear()
	for spd in speeds:
		var spd_ques = speed_to_ques[spd]
		for que_id in spd_ques:
			_que_order.append(que_id)
	

## Add padding to make shorter ques match the longest
# To solve this, think of each que as a bar cut into sections
# A sider moves across all the bars and adds a action slot every time it reaches a new section
# when it reaches a new section in the longest que a gap is added to all other ques
func _calc_turn_padding():
	var que_section_sizes = {}
	var que_section_indexes = {}
	var ques_to_slots = {}
	max_que_size = -1
	var max_que_last_key = ''
	for que_id in _que_order:
		var que:ActionQue = _action_ques[que_id]
		if que.get_max_que_size() >= max_que_size:	
			max_que_size = que.get_max_que_size()
			max_que_last_key = que_id
		ques_to_slots[que_id] = []
		que_section_indexes[que_id] = 0
		que_section_sizes[que_id] = floori(120 / maxi(que.get_max_que_size(), 1))
	
	# Add slots up front, or only as thier section is passed
	# changes behavior in way I can't exomplain right now
	var pre_offset = 0.5 # 0
	
	var natural_index = 0
	var had_increase = false
	var increased_cache = []
	# 120 is a common multiple of most numbers
	for index in range(121):
		increased_cache.clear()
		had_increase = false
		# Check if any ques entered new section
		for key in que_section_sizes.keys():
			var section_size = que_section_sizes[key]
			var section_index = que_section_indexes[key]
			var next_section = (section_index + pre_offset) * section_size
			# Has entered new section
			if index >= next_section and _action_ques[key].get_max_que_size() > 0:
				had_increase = true
				increased_cache.append(key)
		
		# If we had an increase on the max que, go through all the ques and record gap or not
		if had_increase and increased_cache.has(max_que_last_key):
			for key in que_section_sizes.keys():
				if increased_cache.has(key):
					que_section_indexes[key] += 1
					ques_to_slots[key].append(true)
				else:
					ques_to_slots[key].append(false)
	
	if DEEP_LOGGING: printerr("Que Padding Results")
	
	var shift_forward = true
	for que_id in _que_order:
		var que:ActionQue = _action_ques[que_id]
		if que.Id == max_que_last_key:
			shift_forward = false
			
		var slots:Array = ques_to_slots[que_id]
		if shift_forward and slots.size() > 0 and slots[0] == false:
			slots.remove_at(0)
			slots.append(false)
		if DEEP_LOGGING: printerr("Key: %s | Sec: %s | Shift: %s | %s" % [que_id, que_section_sizes[que_id], shift_forward, slots])
			
		que._set_turn_mapping(slots)
	que_ordering_changed.emit()
