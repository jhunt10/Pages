class_name TurnExecutionData

var turn_index:int
var costs:Dictionary:
	get: return on_que_data.get("CostData", {})
var on_que_data:Dictionary = {}

# Mapping of TargetKey to target Id or MapPos
var _targets:Dictionary = {}
# Mapping of TargetKey to TargetParamKey that set it
var _targets_from_params:Dictionary = {}

var turn_failed:bool = false

func _init(on_que:Dictionary) -> void:
	on_que_data = on_que

func set_target_key(target_key:String, from_target_param_key:String, value):
	if value is String or value is MapPos:
		_targets[target_key] = value
		_targets_from_params[target_key] = from_target_param_key
	else:
		printerr("TurnExecutionData.set_target_key: Invalid object '%s' for key '%s'." % [value, target_key])

func has_target(target_key:String)->bool:
	return _targets.keys().has(target_key)

func get_target(target_key:String):
	var target_value = _targets.get(target_key, null)
	if !target_value:
		printerr("TurnExecutionData.get_target: No target with key '%s'." % [target_key])
		return null
	return target_value

func get_param_key_for_target(target_key:String):
	var target_param_key = _targets_from_params.get(target_key, null)
	if !target_param_key:
		printerr("TurnExecutionData.get_target: No target with key '%s'." % [target_key])
		return null
	return target_param_key
