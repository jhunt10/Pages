class_name UiState_CharacterSheet
extends BaseUiState

func _init(controler:UiStateController, args:Dictionary) -> void:
	super(controler, args)
	var actor = CombatRootControl.Instance.get_current_player_actor()
	var menu:CharacterMenuControl = MainRootNode.Instance.open_character_sheet(actor, CombatUiControl.Instance.camera.canvas_layer)
	menu.close_button.pressed.connect(on_menu_closed)
	
	

func start_state():
	CombatRootControl.Instance.camera.freeze_camera()
	pass

func on_menu_closed():
	CombatUiControl.ui_state_controller.back_to_last_state()

func end_state():
	CombatRootControl.Instance.camera.unfreeze_camera()
	CombatUiControl.Instance.que_input.allow_input(false)
	if CombatRootControl.QueController.execution_state == ActionQueController.ActionStates.Paused:
		CombatRootControl.Instance.QueController.start_or_resume_execution()
	pass

func handle_input(event):
	pass

func allow_pause_menu()->bool:
	return false
