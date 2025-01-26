class_name DialogCondition_Tutorial
extends  BaseDialogConditionWatcher

func _on_create():
	var condition_key = _data.get("ConditionKey", null)
	if !condition_key:
		self._is_finished = true
		return
	if condition_key == "SaveTutorial":
		if SaveLoadMenu.Instance:
			SaveLoadMenu.Instance.menu_closed.connect(_on_save_menu_closed)
			return
	if _data.has("RequiredActionQue"):
		var player_actor = StoryState.get_player_actor()
		player_actor.Que.action_que_changed.connect(_on_que_change.bind(player_actor))
		return
	if (condition_key as String).begins_with("Playing"):
		#_dialog_controller.hide()
		CombatRootControl.QueController.end_of_round.connect(on_round_finish)
		if condition_key != "PlayingCombat":
			CombatUiControl.ui_state_controller.set_ui_state(UiStateController.UiStates.ExecRound)
		return

func on_round_finish():
	var condition_key = _data.get("ConditionKey", null)
	if condition_key == "PlayingCombat":
		var squirrel_left = false
		var living_actors = CombatRootControl.Instance.GameState.list_actors(false)
		for actor:BaseActor in living_actors:
			if actor.Tags.has("Squirrel") and actor.FactionIndex != 0:
				squirrel_left = true
		if not squirrel_left:
			_is_finished = true
	else:
		CombatRootControl.QueController.end_of_round.disconnect(on_round_finish)
		_is_finished = true
	
	

func _is_condition(data:Dictionary, game_state:GameStateData, delta:float)->bool:
	#var player_actor = StoryState.get_player_actor()
	#if player_actor.Que.
	return _is_finished

func _on_save_menu_closed():
	_is_finished = true
	

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
		_dialog_controller._condition_flags['FailedTutorial'] = \
			_dialog_controller._condition_flags.get("FailedTutorial", 0) + 1
	else:
		var condition_key = _data.get("ConditionKey", null)
		if condition_key == "Condition_WalkInput":
			_dialog_controller._condition_flags['PassedTutorial_Walk'] = true
		if condition_key == "Condition_AttackInput":
			_dialog_controller._condition_flags['PassedTutorial_Attack'] = true
		if condition_key == "Condition_RangeInput":
			_dialog_controller._condition_flags['PassedTutorial_Range'] = true
			
	_is_finished = true
	actor.Que.action_que_changed.disconnect(_on_que_change)

func get_next_part_key()->String:
	var condition_key = _data.get("ConditionKey", null)
	if condition_key == "SaveTutorial":
		if StoryState.save_id:
			return "ScribeTutorialEnd"
		else:
			return "NoSave_ScribeTutorialEnd"
	if condition_key == "Condition_WalkInput":
		if _dialog_controller._condition_flags.get('PassedTutorial_Walk', false):
			return "Tutorial_Part2"
	if condition_key == "Condition_AttackInput":
		if _dialog_controller._condition_flags.get('PassedTutorial_Attack', false):
			return "Tutorial_Part4"
	if condition_key == "Condition_RangeInput":
		if _dialog_controller._condition_flags.get('PassedTutorial_Range', false):
			return "Tutorial_Part7"
	
	if condition_key == "PlayingWalk":
		return "Tutorial_Part3"
	elif condition_key == "PlayingAttack":
		return "Tutorial_Part5"
	elif condition_key == "PlayingRange":
		var roof_shroom = CombatRootControl.Instance.GameState.get_actor("RoofShroom_1", true)
		if not roof_shroom or roof_shroom.is_dead:
			return "Tutorial_Part8"
		else:
			return "Tutorial_MissedRange"
	elif condition_key == "PlayingCombat":
		return "AfterCombat"
		
		
	var failed_count = _dialog_controller._condition_flags.get("FailedTutorial", 0)
	if failed_count == 1:
		return "Tutorial_Walk_Fail1" 
	if failed_count == 2:
		return "Tutorial_Walk_Fail2" 
	if failed_count == 3:
		return "Tutorial_Walk_Fail3" 
	if failed_count == 4:
		return "Tutorial_Walk_Fail4"
	if failed_count == 5:
		return "Tutorial_Walk_Fail5"
	return ''
