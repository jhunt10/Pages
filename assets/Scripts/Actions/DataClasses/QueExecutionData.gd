class_name QueExecutionData
# This dictionary holds meta data for execution of the que

var _que

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
		TurnExecutionData.new(data)
	)

func get_current_turn_data()->TurnExecutionData:
	var current_turn = _que.turn_to_que_index(CombatRootControl.QueController.action_index)
	if current_turn < 0:
		printerr("Faked Turn Data")
		return TurnExecutionData.new({})
	# If TurnDataList doesn't exist for this turn, back fill the list with new empty records
	if TurnDataList.size() < current_turn+1:
		for n in range(TurnDataList.size(), current_turn+2):
			TurnDataList.append(
				TurnExecutionData.new({})
			)
	return TurnDataList[current_turn]
