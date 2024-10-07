class_name UiState_Targeting
extends BaseUiState

var target_display_key:String
var target_params:TargetParameters
var que_metadata:QueExecutionData
var actor_pos:MapPos

var target_area_dislay_node:TargetAreaDisplayNode:
	get: return CombatRootControl.Instance.MapController.target_area_display

var last_mouse_spot
var last_last_mouse_spot

func _get_debug_name()->String: 
	return "Targeting"
	
func _init(controler:UiStateController, args:Dictionary) -> void:
	super(controler, args)
	actor_pos = args['Position']
	target_params = args['TargetParameters']
	que_metadata = args['MetaData']
	pass
	
func start_state():
	print("Start UiState: Targeting")
	target_display_key = target_area_dislay_node.set_target_parameters(actor_pos, target_params)
	CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.Targeting)
	pass
	
func end_state():
	target_area_dislay_node.clear_display(target_display_key)
	
func update(_delta:float):
	if last_mouse_spot != last_last_mouse_spot:
		target_area_dislay_node.clear_display(target_display_key)
		var area_dict = {}
		var los = TargetParameters.get_line_of_sight_for_spots(actor_pos, last_mouse_spot, 
								CombatRootControl.Instance.GameState.MapState, area_dict)
		target_display_key = target_area_dislay_node.set_target_area(area_dict.keys())
		last_last_mouse_spot = last_mouse_spot
		

	
func handle_input(event):
	if event is InputEventMouseMotion:
		var spot = CombatRootControl.Instance.GridCursor.current_spot
		last_mouse_spot = spot
		if target_params.is_point_in_area(actor_pos, spot):
			CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.Targeting)
		else:
			CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.Default)
		
		
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		var spot = CombatRootControl.Instance.GridCursor.current_spot
		select_target(spot)

func select_target(coord:Vector2i):
	print("Setting Target: " + str(coord))
	var turndata = que_metadata.get_current_turn_data()
	turndata.targets[target_params.target_key] = coord
	CombatRootControl.Instance.ui_controller.set_ui_state(UiStateController.UiStates.ExecRound)
