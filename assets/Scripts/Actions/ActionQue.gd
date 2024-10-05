class_name ActionQue

var Id : String = str(ResourceUID.create_id())
var QueExecData:QueExecutionData

var actor:BaseActor
var real_que : Array = []
var que_size : int = 0
var available_action_list:Array = []

signal action_que_changed

func _init(act) -> void:
	if act.Que:
		printerr("Actor already has que")
		return
	act.Que = self
	var que_data = act.ActorData['QueData']
	que_size = que_data['MaxSize']
	available_action_list = que_data.get('ActionList', [])
	actor = act
	QueExecData = QueExecutionData.new(self)
	
func list_qued_actions():
	return real_que

func get_action_for_turn(turn_index : int):
	if turn_index < 0:
		return null
	if turn_index >= real_que.size():
		return null
	return real_que[turn_index]
	
func que_action(action:BaseAction, data:Dictionary={}):
	if real_que.size() < que_size:
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
			if MoveHandler.spot_is_valid_and_open(CombatRootControl.Instance.GameState, next_pos):
				current_pos = next_pos
			#print("Before: " + str(befor) + " | Prev: " + str(action.PreviewMoveOffset) + " | After: " + str(current_pos))
	return current_pos
