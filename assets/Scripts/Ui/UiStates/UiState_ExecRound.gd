class_name UiState_ExecRound
extends BaseUiState

func _get_debug_name()->String: 
	return "Execute Round"
	
func _init(controler:UiStateController, args:Dictionary) -> void:
	super(controler, args)

func start_state():
	if _logging: print("Start UiState: Exec Round")
	CombatRootControl.QueController.start_or_resume_execution()
	CombatRootControl.QueController.end_of_round.connect(_on_round_end)
	CombatRootControl.Instance.ui_control.que_input.showing = false
	
	#CombatRootControl.Instance.camera.lock_to_actor(CombatUiControl.Instance.que_input._actor)
	pass

func update(_delta:float):
	pass

func end_state():
	CombatRootControl.QueController.end_of_round.disconnect(_on_round_end)
	CombatRootControl.Instance.camera.following_actor_node = null
	pass
	
func _on_round_end():
	ui_controller.set_ui_state(UiStateController.UiStates.ActionInput)
