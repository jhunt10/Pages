class_name QueExecutionData
# This dictionary holds meta data for execution of the que

var _que:ActionQue

func _init(que) -> void:
	_que = que

# Data that perists for full round
var RoundData:Dictionary = {}

# Data for each Turn of current Round
var TurnDataList:Array = []

func clear():
	RoundData.clear()
	TurnDataList.clear()
	
func que_data(data:Dictionary):
	TurnDataList.append(
		TurnExecutionData.new(_que.actor, data)
	)

func get_data_for_turn(turn_index:int)->TurnExecutionData:
	if turn_index < 0:
		printerr("Faked Turn Data")
		return TurnExecutionData.new(_que.actor, {})
	# If TurnDataList doesn't exist for this turn, back fill the list with new empty records
	if TurnDataList.size() < turn_index+1:
		for n in range(TurnDataList.size(), turn_index+2):
			TurnDataList.append(
				TurnExecutionData.new(_que.actor, {})
			)
	return TurnDataList[turn_index]

func get_current_turn_data()->TurnExecutionData:
	var current_turn = _que.turn_to_que_index(CombatRootControl.QueController.action_index)
	return get_data_for_turn(current_turn)
