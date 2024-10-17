class_name UiState_ActionInput
extends BaseUiState

func _init(controler:UiStateController, args:Dictionary) -> void:
	super(controler, args)
	pass
	

func start_state():
	if _logging: print("Start UiState: Action Input")
	CombatRootControl.Instance.QueInput.allow_input(true)
	
	
	#var action:BaseAction = MainRootNode.action_libary.get_action('SpawnTotem')
	#var targ = action.TargetParams['SpawnSpot']
	#CombatRootControl.Instance.MapController.target_area_display \
		#.set_target_parameters(MapPos.new(5,5), targ)
	
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


#var last_spot
#var last_last_spot
#var target_display_key
#func handle_input(event):
	#if event is InputEventMouseMotion:
		#last_spot = CombatRootControl.Instance.GridCursor.current_spot
#
#func update(_delta:float):
	#if last_spot != last_last_spot:
		#if target_display_key:
			#CombatRootControl.Instance.MapController.target_area_display.clear_display(target_display_key)
		##var action:BaseAction = MainRootNode.action_libary.get_action('SpawnTotem')
		##var targ = action.TargetParams['SpawnSpot']
		#var pos =CombatRootControl.Instance.QueDisplay._actor.Que.get_movement_preview_pos()
		#var data = TargetParameters.trace_los(pos, last_spot, CombatRootControl.Instance.GameState.MapState)
		#target_display_key = CombatRootControl.Instance.MapController.target_area_display.set_target_area(data)
		#last_last_spot = last_spot
	#pass
