class_name UiState_PauseMenu
extends BaseUiState

func _get_debug_name()->String: 
	return "PauseMenu"
	
func _init(controler:UiStateController, args:Dictionary) -> void:
	super(controler, args)
	pass
	
func start_state():
	#if not CombatUiControl.Instance.visible:
		#CombatUiControl.Instance.show()
	if _logging: print("Start UiState: PauseMenu")
	if CombatRootControl.Instance.QueController.execution_state == ActionQueController.ActionStates.Running:
		CombatRootControl.Instance.QueController.pause_execution()
	CombatUiControl.Instance.pause_menu.visible = true
	pass

func end_state():
	CombatUiControl.Instance.pause_menu.visible = false
	pass
	
