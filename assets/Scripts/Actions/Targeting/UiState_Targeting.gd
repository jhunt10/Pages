class_name UiState_Targeting
extends BaseUiState

var selection_data:TargetSelectionData
var _target_display_key:String
var target_area_dislay_node:TargetAreaDisplayNode:
	get: return CombatRootControl.Instance.MapController.target_area_display

func _get_debug_name()->String: 
	return "Targeting"
	
func _init(controler:UiStateController, args:Dictionary) -> void:
	super(controler, args)
	selection_data = args['TargetSelectionData']
	pass
	
func start_state():
	if _logging: print("Start UiState: Targeting")
	var game_state = CombatRootControl.Instance.GameState
	
	var selectable_spots = selection_data.get_selectable_coords()
	if selectable_spots.size() == 0:
		printerr("No Valid Selectable Target Spots")
		selection_data.focused_actor.Que.QueExecData.get_current_turn_data().turn_failed = true
		CombatUiControl.ui_state_controller.back_to_last_state()
		
	_target_display_key = target_area_dislay_node.build_from_target_selection_data(selection_data, true)
	
	var mouse_spot = CombatRootControl.Instance.GridCursor.current_spot
	if selection_data.is_coor_selectable(mouse_spot):
		CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.Targeting)
	else:
		CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.Default)
	
func end_state():
	CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.Default)
	target_area_dislay_node.clear_display(_target_display_key)
	
func handle_input(event):
	if event is InputEventMouseMotion:
		var spot = CombatRootControl.Instance.GridCursor.current_spot
		if selection_data.is_coor_selectable(spot):
			CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.Targeting)
			target_area_dislay_node.show_area_effect(_target_display_key)
		else:
			CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.Default)
			target_area_dislay_node.hide_area_effect(_target_display_key)
		
		
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton and not (event as InputEventMouseButton).pressed:
		var spot = CombatRootControl.Instance.GridCursor.current_spot
		select_target(spot)

func select_target(coord:Vector2i):
	if _logging: print("Setting Target: " + str(coord))
	var turndata = selection_data.focused_actor.Que.QueExecData.get_current_turn_data()
	if selection_data.target_params.is_spot_target_type():
		var map_spot = MapPos.new(coord.x, coord.y, selection_data.actor_pos.z, selection_data.actor_pos.dir)
		turndata.set_target_key(selection_data.setting_target_key, selection_data.target_params.target_param_key, map_spot)
	elif selection_data.target_params.is_actor_target_type():
		var actors = CombatRootControl.Instance.GameState.MapState.get_actors_at_pos(coord)
		if actors.size() > 1:
			printerr("Multiple Actors on targeted spot not supported")
			return
		if actors.size() == 0:
			return
		turndata.set_target_key(selection_data.setting_target_key, selection_data.target_params.target_param_key, actors[0].Id)
	CombatUiControl.ui_state_controller.set_ui_state(UiStateController.UiStates.ExecRound)
