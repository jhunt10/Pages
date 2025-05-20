class_name TurnExecutionData

var turn_index:int
var costs:Dictionary:
	get: return on_que_data.get("CostData", {})
var on_que_data:Dictionary = {}
var data_cache:Dictionary = {}
var condition_flags:Dictionary = {}

# Mapping of TargetKey to Array<Target_Id> or Array<MapPos>
var _targets:Dictionary = {}
# Mapping of TargetKey to TargetParamKey that set it
var _targets_from_params:Dictionary = {}

var turn_failed:bool = false
var _actor:BaseActor
func _init(actor:BaseActor, on_que:Dictionary) -> void:
	_actor = actor
	on_que_data = on_que

func add_target_for_key(target_key:String, from_target_param_key:String, value):
	if value is String or value is MapPos:
		if not _targets.keys().has(target_key):
			_targets[target_key] = [] 
		_targets[target_key].append(value)
		_targets_from_params[target_key] = from_target_param_key
	else:
		printerr("TurnExecutionData.set_target_key: Invalid object '%s' for key '%s'." % [value, target_key])

func has_target(target_key:String)->bool:
	return _targets.keys().has(target_key)
func has_target_value(target_value)->bool:
	return _targets.values().has(target_value)

func list_targets()->Array:
	var out_list = []
	for val in _targets.values():
		if not out_list.has(val):
			out_list.append_array(val)
	return out_list

func has_targets(target_key:String)->bool:
	if target_key == "Self":
		return true
	return _targets.has(target_key)

## Returns Array<Actor_Id> or Array<Coor>
func get_targets(target_key:String):
	if target_key == "Self":
		return _actor.Id
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
