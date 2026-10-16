class_name UiState_CharacterSheet
extends BaseUiState

var _character_menu:CharacterMenu

func _init(controler:UiStateController, args:Dictionary) -> void:
	super(controler, args)
	var actor = CombatRootControl.Instance.get_current_player_actor()
	_character_menu = MainRootNode.Instance.open_character_sheet(actor, CombatUiControl.Instance.camera.canvas_layer)
	_character_menu.closed.connect(on_menu_closed)
	
	

func start_state():
	CombatRootControl.Instance.camera.freeze_camera()
	CombatRootControl.pause_combat()
	pass

func on_menu_closed():
	CombatUiControl.ui_state_controller.back_to_last_state()

func end_state():
	CombatRootControl.Instance.camera.unfreeze_camera()
	CombatRootControl.resume_combat()

func handle_input(event):
	# Escape Key Pressed
	if event is InputEventKey:
		if (event as InputEventKey).keycode == KEY_ESCAPE and (event as InputEventKey).pressed:
			_character_menu._on_close()
