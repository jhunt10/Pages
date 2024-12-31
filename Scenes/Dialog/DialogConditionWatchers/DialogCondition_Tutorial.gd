class_name DialogCondition_Tutorial
extends  BaseDialogConditionWatcher

func _on_create():
	if _data.has("RequiredActionQue"):
		var player_actor = StoryState.get_player_actor()
		player_actor.Que.action_que_changed.connect(_on_que_change.bind(player_actor))

func _is_condition(data:Dictionary, game_state:GameStateData, delta:float)->bool:
	#var player_actor = StoryState.get_player_actor()
	#if player_actor.Que.
	return false

func _on_que_change(actor:BaseActor):
	if not actor.Que.is_ready():
		return
	var required_que = _data.get("RequiredActionQue", [])
	var que_matches = true
	for i in range(required_que.size()):
		var qued_page = actor.Que.get_action_for_turn(i)
		if not qued_page or qued_page.ActionKey != required_que[i]:
			que_matches = false
			break
	if not que_matches:
		_dialog_controller._condition_flags['FailedTutorial_1'] = \
			_dialog_controller._condition_flags.get("FailedTutorial_1", 0) + 1
	_is_finished = true
	actor.Que.action_que_changed.disconnect(_on_que_change)

func get_next_part_key()->String:
	var condition_key = _data.get("ConditionKey", null)
	if condition_key == "WalkTutorial":
		var failed_count = _dialog_controller._condition_flags.get("FailedTutorial_1", 0)
		if failed_count == 0:
			return "Tutorial_Part2"
		if failed_count == 1:
			return "Tutorial_Walk_Fail1" 
	return ''
