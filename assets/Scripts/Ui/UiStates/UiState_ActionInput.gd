class_name UiState_ActionInput
extends BaseUiState

var first_actor_index:int

func _init(controler:UiStateController, args:Dictionary) -> void:
	super(controler, args)
	first_actor_index = -1
	
func _get_debug_name()->String: 
	return "Action Input State"


func start_state():
	if _logging: print("Start UiState: Action Input")
	CombatRootControl.Instance.ui_control.combat_control_panel.set_status("Action Input")
	CombatRootControl.Instance.ui_control.active_combat_control.show()
	CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.Default)
	if first_actor_index < 0:
		var living_actors = CombatRootControl.list_player_actors()
		if living_actors.size() > 0:
			first_actor_index = CombatRootControl.get_player_index_of_actor(living_actors[0])
			CombatRootControl.Instance.set_player_index(first_actor_index)
			CombatRootControl.Instance.ui_control.que_input.showing = true

func end_state():
	#CombatUiControl.Instance.que_input.allow_input(false)
	pass

func handle_input(event):
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		if (event as InputEventMouseButton).button_index == 1:
			## Select player actor on click
			var mouse_spot = CombatRootControl.Instance.GridCursor.current_spot
			var mouse_over_actors = CombatRootControl.Instance.GameState.get_actors_at_pos(mouse_spot)
			if mouse_over_actors.size() > 0:
				for actor:BaseActor in mouse_over_actors:
					if actor.is_player:
						var index = CombatRootControl.get_player_index_of_actor(actor)
						if index >= 0:
							CombatRootControl.Instance.set_player_index(index)
					else:
						CombatRootControl.Instance.set_non_player_actor(actor)
