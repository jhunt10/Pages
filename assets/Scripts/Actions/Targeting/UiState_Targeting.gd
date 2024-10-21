class_name UiState_Targeting
extends BaseUiState

var target_display_key:String
var target_params:TargetParameters
var que_metadata:QueExecutionData
var actor_pos:MapPos

var target_area_dislay_node:TargetAreaDisplayNode:
	get: return CombatRootControl.Instance.MapController.target_area_display

func _get_debug_name()->String: 
	return "Targeting"
	
func _init(controler:UiStateController, args:Dictionary) -> void:
	super(controler, args)
	actor_pos = args['Position']
	target_params = args['TargetParameters']
	que_metadata = args['MetaData']
	pass
	
func start_state():
	if _logging: print("Start UiState: Targeting")
	target_display_key = target_area_dislay_node.set_target_parameters(actor_pos, target_params, true)
	CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.Targeting)
	pass
	
func end_state():
	target_area_dislay_node.clear_display(target_display_key)
	
func handle_input(event):
	if event is InputEventMouseMotion:
		var spot = CombatRootControl.Instance.GridCursor.current_spot
		if target_params.is_point_in_area(actor_pos, spot):
			CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.Targeting)
			target_area_dislay_node.show_area_effect(target_display_key)
		else:
			CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.Default)
			target_area_dislay_node.hide_area_effect(target_display_key)
		
		
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		var spot = CombatRootControl.Instance.GridCursor.current_spot
		select_target(spot)

func select_target(coord:Vector2i):
	if _logging: print("Setting Target: " + str(coord))
	var turndata = que_metadata.get_current_turn_data()
	if target_params.is_spot_target_type():
		turndata.targets[target_params.target_key] = coord
	elif target_params.is_actor_target_type():
		var actors = CombatRootControl.Instance.GameState.MapState.get_actors_at_pos(coord)
		if actors.size() > 1:
			printerr("Multiple Actors on targeted spot not supported")
			return
		if actors.size() == 0:
			return
		turndata.targets[target_params.target_key] = actors[0].Id
	CombatUiControl.ui_state_controller.set_ui_state(UiStateController.UiStates.ExecRound)
