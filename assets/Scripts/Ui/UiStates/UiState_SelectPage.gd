class_name UiState_SelectPage
extends BaseUiState

func _get_debug_name()->String: 
	return "Targeting"
	
var _selectable_action_keys:Array = []
var _actor_index:int = 0
	
func _init(controler:UiStateController, args:Dictionary) -> void:
	super(controler, args)
	_selectable_action_keys = args.get("SelectablePages", [])
	_actor_index = args.get("PlayerActorIndex", 0)
	pass
	
func start_state():
	if _logging: print("Start UiState: Refill Ammo")
	CombatRootControl.Instance.set_player_index(_actor_index)
	var que_input = CombatRootControl.Instance.ui_control.que_input
	que_input.showing = true
	que_input.show_page_selection(_selectable_action_keys)
	que_input.page_special_selected.connect(on_page_selected)
	#var game_state = CombatRootControl.Instance.GameState
	#var selectable_spots = selection_data.get_selectable_coords()
	#if selectable_spots.size() == 0:
		#printerr("No Valid Selectable Target Spots")
		#selection_data.focused_actor.Que.fail_turn()
		#CombatUiControl.ui_state_controller.back_to_last_state()
	#

func on_page_selected(action_key):
	# TODO: Want class to be generic, can't call back to SubAct_Reload because it shouldn't exist any more
	print("Page Selected: " + action_key)
	var que_input = CombatRootControl.Instance.ui_control.que_input
	que_input.page_special_selected.disconnect(on_page_selected)
	var actor = que_input._actor
	actor.Que.fill_page_ammo(action_key)
	CombatUiControl.ui_state_controller.back_to_last_state()
	
	
func end_state():
	pass
	
func handle_input(event):
	pass

	#CombatUiControl.ui_state_controller.set_ui_state(UiStateController.UiStates.ExecRound)
