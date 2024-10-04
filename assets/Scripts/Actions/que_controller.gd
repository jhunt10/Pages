class_name QueControllerNode
extends Node2D

@onready var map_controller:MapControllerNode = $"../MapControlerNode"
@onready var label:Label = $Label

# End round early if no more actions are qued (for testing)
const SHORTCUT_QUE = true
const DEEP_LOGGING = false
const FRAMES_PER_ACTION = 24
const SUB_ACTION_FRAME_TIME = 0.05

# Start of new Round
signal start_of_round
# Start of new Turn
signal start_of_turn
# Start of new Frame
signal start_of_frame
# End of current Frame
signal end_of_frame
# End of current Turn
signal end_of_turn
# End of current Round
signal end_of_round

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
var que_index = 0
var action_index = 0
var max_que_size = 0

var action_ques:Dictionary = {}
var que_order:Array = []
var que_turn_to_step_mapping:Dictionary = {}
var subaction_script_cache:Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _start_round():
	print("QueController: Start Round")
	action_index = 0
	sub_action_index = 0
	que_index = 0
	sub_action_timer = 0
	execution_state = ActionStates.Running
	start_of_round.emit()
	execution_active.emit()

func _end_round():
	print("QueController: End Round")
	label.text = "Waiting"
	action_index = 0
	sub_action_index = 0
	que_index = 0
	sub_action_timer = 0
	execution_state = ActionStates.Waiting
	end_of_round.emit()
	execution_suspended.emit()
	_clear_ques()
	
	
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
	return action_ques[que_order[que_index]]
	
func get_current_turn_for_que(que_id:String)->int:
	var current_turn = action_index
	var que_order_index = que_order.find(que_id)
	if que_order_index > que_index:
		return current_turn -1
	return current_turn

# Add an action que to the controller
func add_action_que(new_que:ActionQue):
	if action_ques.has(new_que.Id):
		return
	action_ques[new_que.Id] = new_que
	#TODO: Que padding
	var arr = {}
	if new_que.que_size > max_que_size:
		max_que_size = new_que.que_size
	for n in range(new_que.que_size):
		arr[n] = n
	que_turn_to_step_mapping[new_que.Id] = arr
	que_order.append(new_que.Id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if execution_state == ActionStates.Running:
		sub_action_timer += delta
		if sub_action_timer > SUB_ACTION_FRAME_TIME:
			if DEEP_LOGGING: print("Doing Action: " + str(action_index) + ":" + str(sub_action_index))# + " | delta: " + str(delta))
			sub_action_timer = 0
			
			#TODO: GameState
			var game_state:GameStateData = CombatRootControl.Instance.GameState
			
			# Emit starting signals
			if sub_action_index == 0:
				start_of_turn.emit()
				_pay_turn_costs()
			start_of_frame.emit()
			label.text = str(action_index) + ":" + str(sub_action_index)
			
			# Do all actions for frame
			for q_index in range(que_index, action_ques.size()):
				var que = action_ques[que_order[q_index]]
				_execute_turn_frames(game_state, que, action_index, sub_action_index)
				
				# Check if the last action stopped execution
				if execution_state != ActionStates.Running:
					end_of_frame.emit()
					return
					
			# Resolve all missiles that have reached thier target
			for missile:BaseMissile in game_state.Missiles.values():
				if missile.has_reached_target():
					missile.do_thing(game_state)
					game_state.delete_missile(missile)
			
			end_of_frame.emit()
			que_index = 0
			sub_action_index += 1
			
			# All subactions for turn have finished
			if sub_action_index >= BaseAction.SUB_ACTIONS_PER_ACTION:
				end_of_turn.emit()
				sub_action_index = 0
				que_index = 0
				action_index += 1
				
				if SHORTCUT_QUE:
					var any_left = false
					for q:ActionQue in action_ques.values():
						if q.get_action_for_turn(action_index):
							any_left = true
					if not any_left:
						end_of_round.emit()
						_end_round()
						return
				
			# All actions for que have finished
			if action_index >= max_que_size:
				end_of_round.emit()
				_end_round()

func _clear_ques():
	for que:ActionQue in action_ques.values():
		que.clear_que()
		que.QueExecData.clear()
	

func _execute_turn_frames(game_state:GameStateData, que:ActionQue, turn_index:int, subaction_index:int):
	if DEEP_LOGGING: print("\tChecking Que: " + que.Id)
	var turn_data = que.QueExecData.TurnDataList[turn_index]
	if turn_data.turn_failed:
		return
	# Get the action for this turn
	var action:BaseAction = que.get_action_for_turn(turn_index)
	# If no action, skip. Ussually caused by smaller ques.
	if !action:
		if DEEP_LOGGING: print("\t\tNo action")
		return
		
	# Get subaction for this frame
	var subaction_data = action.SubActionData[subaction_index]
	if !subaction_data:
		return
		
	var script_key = subaction_data['SubActionScript']
	var subaction = _get_subaction(script_key)
	if !subaction:
		printerr("No script found for subaction " + script_key)
		return
	
	# Finnaly do subaction
	subaction.do_thing(
		action, # Parent Action
		subaction_data, # SubAction configuration
		que.QueExecData, # Metadata for action execution
		game_state, # GameState
		que.actor # Actor
	)

# Get script either load script or retreave from cache 
func _get_subaction(script_key:String)->BaseSubAction:
	var subaction:BaseSubAction = subaction_script_cache.get(script_key, null)
	if !subaction and FileAccess.file_exists(script_key):
		var script = load(script_key)
		if script:
			var new_subaction = script.new()
			subaction_script_cache[script_key] = new_subaction
			subaction = subaction_script_cache[script_key]
		else:
			printerr("Failed to find subaction script: " + script_key)
	return subaction

## Get local action index for a que. This accounts for miss matched que sizes 
##	and inserts gaps for smaller ques.
func _get_step_from_turn(que:ActionQue, turn_index:int)->int:
	var mapping = que_turn_to_step_mapping.get(que.Id, null)
	if !mapping:
		printerr("No turn mapping found for que: "+que.Id)
		return -1
	if mapping.has(turn_index):
		return mapping[turn_index]
	return -1

func _pay_turn_costs():
	for que:ActionQue in action_ques.values():
		var actor = que.actor
		var turn_data = que.QueExecData.get_current_turn_data()
		for stat_name in turn_data.costs.keys():
			if not actor.stats.reduce_bar_stat_value(stat_name, turn_data.costs[stat_name], false):
				CombatRootControl.Instance.create_flash_text(actor, "-"+stat_name, Color.ORANGE)
				turn_data.turn_failed = true
				#TODO: Can't Pay
				return
				
