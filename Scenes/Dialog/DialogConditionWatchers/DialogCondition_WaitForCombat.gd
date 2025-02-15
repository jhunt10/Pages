class_name DialogCondition_WaitForCombat
extends BaseDialogConditionWatcher

func _on_create():
	var combat_control = CombatRootControl.Instance
	if not combat_control:
		printerr("DialogCondition_WaitForCombat._oncreate: No CombatRootControl.Instance found.")
		_is_finished = true
		return
	combat_control.supress_win_conditions = true
	combat_control.ui_control.que_input.supress_start = false
	if not combat_control.combat_started:
		combat_control.start_combat_animation()
	combat_control.QueController.end_of_round_with_state.connect(on_round_finish)
	

func is_finished()->bool:
	return _is_finished

func _check_condition(data:Dictionary, game_state:GameStateData, delta:float)->bool:
	return _is_finished

func on_round_finish(game_state:GameStateData):
	var ignore_actors_lilst = _data.get("IgnoreEnemieIds", [])
	var is_combat_done = true
	for actor:BaseActor in game_state.list_actors(false):
		if actor.FactionIndex != 0 and not ignore_actors_lilst.has(actor.Id):
			is_combat_done = false
			break
	if is_combat_done:
		_is_finished = true
		CombatRootControl.Instance.QueController.end_of_round_with_state.disconnect(on_round_finish)
		if _data.get("ShowVictoryScreenOnFinish", false):
			CombatRootControl.Instance.trigger_end_condition(true)
	
