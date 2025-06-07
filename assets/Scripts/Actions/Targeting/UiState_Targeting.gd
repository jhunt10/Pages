class_name UiState_Targeting
extends BaseUiState

const LOGGING = false

var selection_data:TargetSelectionData
var _target_display_key:String
var target_area_dislay_node:TargetAreaDisplayNode:
	get: return CombatRootControl.Instance.MapController.target_area_display

var target_confirm_button:TargetInputControl:
	get: return CombatUiControl.Instance.target_input_display

var wait_for_confirm:bool = true
var is_waiting_for_confirm:bool = false
var waiting_selection

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
		selection_data.focused_actor.Que.fail_turn()
		CombatUiControl.ui_state_controller.back_to_last_state()
	
	if wait_for_confirm:
		target_confirm_button.visible = true
		if selection_data.target_params.is_actor_target_type():
			target_confirm_button.set_title_text("Select target Creature")
		elif selection_data.target_params.is_spot_target_type():
			target_confirm_button.set_title_text("Select target Spot")
		target_confirm_button.set_button_text("Skip")
		target_confirm_button.on_pressed_func = ui_button_pressed
	
	_target_display_key = target_area_dislay_node.build_from_target_selection_data(selection_data, true)
	target_area_dislay_node.hide_area_effect(_target_display_key)
	var mouse_spot = CombatRootControl.Instance.GridCursor.current_spot
	if selection_data.is_coor_selectable(mouse_spot):
		CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.Targeting)
	else:
		CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.Default)
	CombatRootControl.Instance.camera.freeze = false
	var center = selection_data.get_center_of_area()
	CombatRootControl.Instance.camera.start_auto_pan_to_map_pos(center)
	
func end_state():
	CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.Default)
	CombatRootControl.Instance.GridCursor.lock_position = false
	target_area_dislay_node.clear_display(_target_display_key)
	target_confirm_button.visible = false
	target_confirm_button.on_pressed_func = null
	
func handle_input(event):
	if !is_waiting_for_confirm and event is InputEventMouseMotion:
		var spot = CombatRootControl.Instance.GridCursor.current_spot
		if selection_data.is_coor_selectable(spot):
			CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.Targeting)
			target_area_dislay_node.show_area_effect(_target_display_key)
		else:
			CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.Default)
			target_area_dislay_node.hide_area_effect(_target_display_key)
		target_area_dislay_node.set_area_effect_coor(_target_display_key, spot)
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton and not (event as InputEventMouseButton).pressed:
		if _logging: print("Button Pressed")
		var mouse_pos = CombatRootControl.Instance.MapController.actor_tile_map.get_local_mouse_position()
		var spot = CombatRootControl.Instance.MapController.actor_tile_map.local_to_map(mouse_pos)
		if selection_data.is_coor_selectable(spot):
			select_target(spot, false)

func select_target(coord:Vector2i, confirmed:bool):
	if (wait_for_confirm and not confirmed) or coord != waiting_selection:
		if _logging: print("Started Waiting for comfirm")
		is_waiting_for_confirm = true
		waiting_selection = coord
		target_area_dislay_node.set_area_effect_coor(_target_display_key, coord)
		target_confirm_button.set_button_text("Confirm")
		CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.Targeting)
		CombatRootControl.Instance.GridCursor.position = CombatRootControl.Instance.MapController.actor_tile_map.map_to_local(coord)
		CombatRootControl.Instance.GridCursor.lock_position = true
		return
		
	is_waiting_for_confirm = false
	waiting_selection = null
	if _logging: print("Setting Target: " + str(coord))
	var turndata = selection_data.focused_actor.Que.QueExecData.get_current_turn_data()
	if selection_data.target_params.is_spot_target_type():
		var map_spot = MapPos.new(coord.x, coord.y, selection_data.actor_pos.z, selection_data.actor_pos.dir)
		turndata.add_target_for_key(selection_data.setting_target_key, selection_data.target_params.target_param_key, map_spot)
	elif selection_data.target_params.is_actor_target_type():
		var include_dead = selection_data.target_params.target_type == TargetParameters.TargetTypes.Corpse
		var actors = CombatRootControl.Instance.GameState.get_actors_at_pos(coord, include_dead)
		if actors.size() > 1:
			printerr("Multiple Actors on targeted spot not supported")
			return
		if actors.size() == 0:
			printerr("No Actors on targeted spot when looking for Actor target")
			return
		turndata.add_target_for_key(selection_data.setting_target_key, selection_data.target_params.target_param_key, actors[0].Id)
	CombatUiControl.ui_state_controller.set_ui_state(UiStateController.UiStates.ExecRound)

func ui_button_pressed():
	if _logging: print("Confrim button pressed")
	if not is_waiting_for_confirm:
		selection_data.focused_actor.Que.fail_turn()
		CombatUiControl.ui_state_controller.set_ui_state(UiStateController.UiStates.ExecRound)
	elif waiting_selection != null:
		select_target(waiting_selection, true)
	
