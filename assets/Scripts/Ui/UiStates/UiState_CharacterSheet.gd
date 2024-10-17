class_name UiState_CharacterSheet
extends BaseUiState

var character_sheet:CharacterSheetControl

func _init(controler:UiStateController, args:Dictionary) -> void:
	super(controler, args)
	character_sheet = load("res://Scenes/character_edit_control.tscn").instantiate()
	CombatRootControl.Instance.ui_controller.add_child(character_sheet)
	character_sheet.tree_exited.connect(on_menu_closed)
	var actor_id = args.get("ActorId", null)
	if not actor_id:
		return
	var actor = CombatRootControl.Instance.GameState.get_actor(actor_id)
	if not actor:
		return
	character_sheet.set_actor(actor)
	

func start_state():
	pass

func on_menu_closed():
	CombatRootControl.Instance.ui_controller.back_to_last_state()

func end_state():
	CombatRootControl.Instance.QueInput.allow_input(false)
	pass

func handle_input(event):
	pass

func allow_pause_menu()->bool:
	return false
