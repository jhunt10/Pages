class_name UiState_SelectActionOption
extends BaseUiState

func _get_debug_name()->String: 
	return "SelectActionOption"

## Keyed off Option Id, has 'Icon'
var _option_sets:Array = []
var _selection_key:String
var _queing_action_key:String
var _selecting_for_actor_id:String
var finished_selecting:bool
	
func _init(controler:UiStateController, args:Dictionary) -> void:
	super(controler, args)
	_selecting_for_actor_id = args.get("ActorId", "")
	_queing_action_key = args.get("ActionKey", "")
	_selection_key = args.get("SelectionKey", "")
	_option_sets = args.get("OptionSets", [])
	
func start_state():
	var option_menu = CombatRootControl.Instance.ui_control.option_select_menu
	finished_selecting = false
	option_menu.set_options(_selection_key, _option_sets, _on_all_que_options_selected)
	option_menu.menu_closed.connect(on_option_menu_closed)
	CombatRootControl.Instance.camera.freeze = true

func _on_all_que_options_selected(selection_key:String, options_data:Dictionary):
	var actor = ActorLibrary.get_actor(_selecting_for_actor_id)
	if _queing_action_key:
		var action = ItemLibrary.get_item(_queing_action_key)
		actor.Que.que_action(action, options_data)
	else:
		var turn_data:TurnExecutionData = actor.Que.QueExecData.get_current_turn_data()
		turn_data.on_que_data[_selection_key] = options_data[_selection_key]
	var option_menu = CombatRootControl.Instance.ui_control.option_select_menu
	option_menu.menu_closed.disconnect(on_option_menu_closed)
	finished_selecting = true
	CombatUiControl.ui_state_controller.back_to_last_state()

func on_option_menu_closed():
	var option_menu = CombatRootControl.Instance.ui_control.option_select_menu
	option_menu.menu_closed.disconnect(on_option_menu_closed)
	CombatUiControl.ui_state_controller.back_to_last_state()
	CombatRootControl.Instance.camera.freeze = false

func end_state():
	pass
	
func handle_input(event):
	pass

	#CombatUiControl.ui_state_controller.set_ui_state(UiStateController.UiStates.ExecRound)
