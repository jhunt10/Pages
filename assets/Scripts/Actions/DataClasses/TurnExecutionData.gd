class_name TurnExecutionData

var turn_index:int
var costs:Dictionary:
	get: return on_que_data.get("CostData", {})
var on_que_data:Dictionary = {}
var targets:Dictionary = {}
var turn_failed:bool = false

func _init(on_que:Dictionary) -> void:
	on_que_data = on_que
