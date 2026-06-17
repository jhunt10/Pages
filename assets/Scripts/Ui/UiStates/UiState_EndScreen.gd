class_name UiState_EndScreen
extends BaseUiState

func _init(controler:UiStateController, args:Dictionary) -> void:
	super(controler, args)
	
	

func start_state():
	CombatRootControl.Instance.camera.freeze_camera()
	CombatRootControl.pause_combat()
	CombatRootControl.Instance.ui_control.victory_screen.show_game_result()

func end_state():
	CombatRootControl.Instance.camera.unfreeze_camera()
	CombatRootControl.resume_combat()
	pass

func handle_input(_event):
	pass

func allow_pause_menu()->bool:
	return false
