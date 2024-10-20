class_name UiState_ActionInput
extends BaseUiState

func _init(controler:UiStateController, args:Dictionary) -> void:
	super(controler, args)
	pass
	

func start_state():
	if _logging: print("Start UiState: Action Input")
	CombatRootControl.Instance.QueInput.allow_input(true)
	pass

func end_state():
	CombatRootControl.Instance.QueInput.allow_input(false)
	pass

func handle_input(event):
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		var mouse_spot = CombatRootControl.Instance.GridCursor.current_spot
		var mouse_over_actors = CombatRootControl.Instance.GameState.MapState.get_actors_at_pos(mouse_spot, null, true)
		if mouse_over_actors.size() > 0:
			var actor:BaseActor = mouse_over_actors[0]
			ui_controller.set_ui_state(UiStateController.UiStates.CharacterSheet, {"ActorId":actor.Id})
			var charsheet = load("res://Scenes/character_edit_control.tscn").instantiate()
			CombatRootControl.Instance.ui_controller.add_child(charsheet)
			charsheet.set_actor(actor)
