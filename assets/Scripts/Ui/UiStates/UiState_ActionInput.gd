class_name UiState_ActionInput
extends BaseUiState

func _init(controler:UiStateController, args:Dictionary) -> void:
	super(controler, args)
	pass
	
func _get_debug_name()->String: 
	return "Action Input State"


func start_state():
	if _logging: print("Start UiState: Action Input")
	CombatUiControl.Instance.que_input.allow_input(true)
	CombatUiControl.Instance.stat_panel_control.force_preview_mode()
	#CombatRootControl.Instance.camera.freeze = false
	pass

func end_state():
	CombatUiControl.Instance.que_input.allow_input(false)
	pass

func handle_input(event):
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		var mouse_spot = CombatRootControl.Instance.GridCursor.current_spot
		
		## Show Character Sheet on clicking an actor
		#var mouse_over_actors = CombatRootControl.Instance.GameState.MapState.get_actors_at_pos(mouse_spot, null, true)
		#if mouse_over_actors.size() > 0:
			#var actor:BaseActor = mouse_over_actors[0]
			#ui_controller.set_ui_state(UiStateController.UiStates.CharacterSheet, {"ActorId":actor.Id})
			
			#MainRootNode.Instance.open_character_sheet(actor)
			#var charsheet = load("res://Scenes/character_edit_control.tscn").instantiate()
			#CombatUiControl.Instance.add_child(charsheet)
			#charsheet.set_actor(actor)
