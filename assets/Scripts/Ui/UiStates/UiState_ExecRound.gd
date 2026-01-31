class_name UiState_ExecRound
extends BaseUiState

func _get_debug_name()->String: 
	return "Execute Round"
	
func _init(controler:UiStateController, args:Dictionary) -> void:
	super(controler, args)

var _round_ended

func start_state():
	if _logging: print("Start UiState: Exec Round")
	if CombatRootControl.is_paused:
		CombatRootControl.resume_combat()
	else:
		CombatRootControl.Instance.QueController.start_or_resume_execution()
	CombatRootControl.QueController.end_of_round.connect(_on_round_end)
	CombatRootControl.Instance.ui_control.que_input.showing = false
	CombatRootControl.Instance.ui_control.que_input.hide_start_button()
	
	var current_actor = CombatRootControl.Instance.get_current_player_actor()
	CombatRootControl.Instance.camera.lock_to_actor(current_actor, true)
	pass

func update(_delta:float):
	pass

func end_state():
	if not _round_ended:
		CombatRootControl.pause_combat()
	CombatRootControl.QueController.end_of_round.disconnect(_on_round_end)
	CombatRootControl.Instance.camera.clear_following_actor()
	pass
	
func _on_round_end():
	_round_ended = true
	ui_controller.set_ui_state(UiStateController.UiStates.ActionInput)
