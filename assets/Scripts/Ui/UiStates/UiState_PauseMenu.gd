class_name UiState_PauseMenu
extends BaseUiState

func _get_debug_name()->String: 
	return "PauseMenu"
	
func _init(controler:UiStateController, args:Dictionary) -> void:
	super(controler, args)
	pass
	
func start_state():
	print("Start UiState: PauseMenu")
	if CombatRootControl.Instance.QueController.execution_state == QueControllerNode.ActionStates.Running:
		CombatRootControl.Instance.QueController.pause_execution()
	CombatRootControl.Instance.ui_controller.pause_menu.visible = true
	pass

func update(delta:float):
	pass

func end_state():
	CombatRootControl.Instance.ui_controller.pause_menu.visible = false
	pass
	
