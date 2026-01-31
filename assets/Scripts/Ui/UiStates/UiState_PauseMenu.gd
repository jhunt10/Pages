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
	
	CombatRootControl.pause_combat()
	CombatUiControl.Instance.pause_menu.visible = true
	pass

func end_state():
	CombatRootControl.resume_combat()
	CombatUiControl.Instance.pause_menu.visible = false
	pass
	
