class_name BaseDialogConditionWatcher

var _dialog_controller:DialogController
var _data:Dictionary
var _is_finished:bool

func set_data(controller:DialogController, data:Dictionary):
	_dialog_controller = controller
	_data = data
	_on_create()

func _on_create():
	pass

func update(delta:float):
	if not _is_finished:
		var game_state = null
		if CombatRootControl.Instance:
			game_state = CombatRootControl.Instance.GameState
		if _check_condition(_data, game_state, delta):
			_is_finished = true

func is_finished()->bool:
	return _is_finished

func _check_condition(data:Dictionary, game_state:GameStateData, delta:float)->bool:
	return is_finished()

func get_next_part_key()->String:
	return ''
