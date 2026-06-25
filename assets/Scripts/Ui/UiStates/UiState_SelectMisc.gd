class_name UiState_SelectMisc
extends BaseUiState

func _get_debug_name()->String: 
	return "SelectMisc"

## Keyed off Option Id, has 'Icon'
var _option_sets:Array = []
var _selection_key:String
var finished_selecting:bool
	
func _init(controler:UiStateController, args:Dictionary) -> void:
	super(controler, args)
	_option_sets = args.get("OptionSets", [])
	
func start_state():
	var option_menu = CombatRootControl.Instance.ui_control.option_select_menu
	finished_selecting = false
	option_menu.menu_closed.connect(on_option_menu_closed)
	CombatRootControl.Instance.camera.freeze_camera()

func on_option_menu_closed():
	var option_menu = CombatRootControl.Instance.ui_control.option_select_menu
	option_menu.menu_closed.disconnect(on_option_menu_closed)
	CombatUiControl.ui_state_controller.back_to_last_state()
	CombatRootControl.Instance.camera.unfreeze_camera()

func end_state():
	pass
	
func handle_input(event):
	pass

	#CombatUiControl.ui_state_controller.set_ui_state(UiStateController.UiStates.ExecRound)
