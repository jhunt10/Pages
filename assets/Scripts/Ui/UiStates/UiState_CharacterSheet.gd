class_name UiState_CharacterSheet
extends BaseUiState

var character_sheet#:CharacterSheetControl

func _init(controler:UiStateController, args:Dictionary) -> void:
	super(controler, args)
	var actor_id = args.get("ActorId", null)
	if not actor_id:
		return
	var actor = CombatRootControl.Instance.GameState.get_actor(actor_id)
	if not actor:
		return
	main
	

func start_state():
	pass

func on_menu_closed():
	CombatUiControl.ui_state_controller.back_to_last_state()

func end_state():
	CombatUiControl.Instance.que_input.allow_input(false)
	pass

func handle_input(event):
	pass

func allow_pause_menu()->bool:
	return false
