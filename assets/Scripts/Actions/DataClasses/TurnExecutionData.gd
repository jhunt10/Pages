class_name TurnExecutionData

var turn_index:int
var on_que_data:Dictionary = {}
var targets:Dictionary = {}

func _init(on_que:Dictionary) -> void:
	on_que_data = on_que
