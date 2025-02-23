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
	combat_control.camera.locked_for_cut_scene = false
	if not combat_control.combat_started:
		combat_control.start_combat_animation()
	combat_control.QueController.end_of_round_with_state.connect(on_round_finish)
	

func is_finished()->bool:
	return _is_finished

func _check_condition(data:Dictionary, game_state:GameStateData, delta:float)->bool:
	#on_round_finish(game_state)
	return _is_finished

func on_round_finish(game_state:GameStateData):
	var ignore_actors_lilst = _data.get("IgnoreEnemieIds", [])
	var all_enemies_dead = true
	var all_players_dead = true
	for actor:BaseActor in game_state.list_actors(false):
		if actor.FactionIndex != 0 and not ignore_actors_lilst.has(actor.Id):
			all_enemies_dead = false
		if actor.is_player:
			all_players_dead = false
	if all_enemies_dead:
		_is_finished = true
		CombatRootControl.Instance.QueController.end_of_round_with_state.disconnect(on_round_finish)
		if _data.get("ShowVictoryScreenOnFinish", false):
			CombatRootControl.Instance.trigger_end_condition(true)
	elif all_players_dead:
		CombatRootControl.Instance.QueController.end_of_round_with_state.disconnect(on_round_finish)
		if _data.get("ShowVictoryScreenOnFinish", false):
			CombatRootControl.Instance.trigger_end_condition(false)
	
