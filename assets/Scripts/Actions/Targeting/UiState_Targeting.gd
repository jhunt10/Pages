class_name UiState_Targeting
extends BaseUiState

var target_display_key:String
var target_params:TargetParameters
var que_metadata:QueExecutionData
var actor_pos:MapPos
var setting_target_key:String

var target_area_dislay_node:TargetAreaDisplayNode:
	get: return CombatRootControl.Instance.MapController.target_area_display

func _get_debug_name()->String: 
	return "Targeting"
	
func _init(controler:UiStateController, args:Dictionary) -> void:
	super(controler, args)
	setting_target_key = args['SetTargetKey']
	actor_pos = args['Position']
	target_params = args['TargetParameters']
	que_metadata = args['MetaData']
	pass
	
func start_state():
	if _logging: print("Start UiState: Targeting")
	target_display_key = target_area_dislay_node.set_target_parameters(actor_pos, target_params, true)
	CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.Targeting)
	var tile_map:TileMapLayer = target_area_dislay_node.get_target_tile_map_layer(target_display_key)
	var target_spots = find_selectable_actor_spots()
	tile_map.set_cells_terrain_connect(target_spots, 0, 2)
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
	if event is InputEventMouseButton and not (event as InputEventMouseButton).pressed:
		var spot = CombatRootControl.Instance.GridCursor.current_spot
		select_target(spot)

func select_target(coord:Vector2i):
	if _logging: print("Setting Target: " + str(coord))
	var turndata = que_metadata.get_current_turn_data()
	if target_params.is_spot_target_type():
		var map_spot = MapPos.new(coord.x, coord.y, actor_pos.z, actor_pos.dir)
		turndata.set_target_key(setting_target_key, target_params.target_param_key, map_spot)
	elif target_params.is_actor_target_type():
		var actors = CombatRootControl.Instance.GameState.MapState.get_actors_at_pos(coord)
		if actors.size() > 1:
			printerr("Multiple Actors on targeted spot not supported")
			return
		if actors.size() == 0:
			return
		turndata.set_target_key(setting_target_key, target_params.target_param_key, actors[0].Id)
	CombatUiControl.ui_state_controller.set_ui_state(UiStateController.UiStates.ExecRound)

func find_selectable_actor_spots()->Array:
	var out_list = []
	var target_area = target_params.get_valid_target_area(actor_pos)
	for spot:Vector2i in target_area.keys():
		var val = target_area[spot]
		var actors_on_spot = CombatRootControl.Instance.GameState.MapState.get_actors_at_pos(spot)
		if actors_on_spot.size() > 0:
			out_list.append(spot)
	return out_list
	
