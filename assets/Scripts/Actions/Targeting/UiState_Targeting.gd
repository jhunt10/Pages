class_name UiState_Targeting
extends BaseUiState

const LOGGING = false

var selection_data:TargetSelectionData
var _target_display_key:String
var target_area_dislay_node:TargetAreaDisplayNode:
	get: return CombatRootControl.Instance.MapController.target_area_display

var target_input_display:TargetInputControl:
	get: return CombatUiControl.Instance.target_input_display

var allow_lockon:bool = true
var wait_for_confirm:bool = MainRootNode.is_mobile
var is_waiting_for_confirm:bool = false
var waiting_selection

func _get_debug_name()->String: 
	return "Targeting"
	
func _init(controler:UiStateController, args:Dictionary) -> void:
	super(controler, args)
	selection_data = args['TargetSelectionData']
	allow_lockon = args.get("AllowLockon")
	pass
	
func start_state():
	if _logging: print("Start UiState: Targeting")
	var game_state = CombatRootControl.Instance.GameState
	var selectable_spots = selection_data.get_selectable_coords()
	if selectable_spots.size() == 0:
		printerr("No Valid Selectable Target Spots")
		selection_data.focused_actor.Que.fail_turn()
		CombatUiControl.ui_state_controller.back_to_last_state()
	
	#if wait_for_confirm:
	target_input_display.visible = true
	target_input_display.set_target_type(selection_data.target_params.target_type, allow_lockon)
	target_input_display.set_button_text("Skip")
	target_input_display.on_pressed_func = ui_button_pressed
	
	_target_display_key = target_area_dislay_node.build_from_target_selection_data(selection_data, true)
	target_area_dislay_node.hide_area_effect(_target_display_key)
	
	target_input_display.set_actor(selection_data.focused_actor)
	
	var mouse_spot = CombatRootControl.Instance.GridCursor.current_spot
	if selection_data.is_coor_selectable(mouse_spot):
		CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.Targeting)
	else:
		CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.Default)
	CombatRootControl.Instance.camera.freeze = false
	var center = selection_data.get_center_of_area()
	CombatRootControl.Instance.camera.start_auto_pan_to_map_pos(center)
	
	if selection_data.target_params.is_actor_target_type():
		var last_target_record = CombatRootControl.Instance.last_target_records.get(selection_data.focused_actor.Id, {})
		var last_target_actor_id = last_target_record.get("ActorId", null)
		if last_target_actor_id and selection_data.list_potential_targets().has(last_target_actor_id):
			var map_pos = game_state.get_actor_pos(last_target_actor_id)
			select_target(map_pos.to_vector2i(), false, true)
	var actor_node = CombatRootControl.get_actor_node(selection_data.focused_actor.Id)
	actor_node.reset_path_arrow()
	actor_node.show_path_arrow()
	
func end_state():
	CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.Default)
	CombatRootControl.Instance.GridCursor.lock_position = false
	target_area_dislay_node.clear_display(_target_display_key)
	target_input_display.visible = false
	target_input_display.on_pressed_func = null
	var actor_node = CombatRootControl.get_actor_node(selection_data.focused_actor.Id)
	actor_node.reset_path_arrow()
	actor_node.hide_path_arrow()
	
func handle_input(event):
	if event is InputEventMouseMotion:
		
		var mouse_pos = CombatRootControl.Instance.MapController.get_local_mouse_position()
		var mouse_over_spot = CombatRootControl.Instance.MapController.actor_tile_map.local_to_map(mouse_pos)
		if selection_data.is_coor_selectable(mouse_over_spot):
			CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.Targeting)
			CombatRootControl.Instance.GridCursor.lock_position = false
			target_area_dislay_node.show_area_effect(_target_display_key)
			target_input_display.set_target_coord(mouse_over_spot)
			target_area_dislay_node.set_area_effect_coor(_target_display_key, mouse_over_spot)
		elif waiting_selection:
			CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.Targeting)
			CombatRootControl.Instance.GridCursor.position = CombatRootControl.Instance.MapController.actor_tile_map.map_to_local(waiting_selection)
			CombatRootControl.Instance.GridCursor.lock_position = true
			target_area_dislay_node.show_area_effect(_target_display_key)
			target_input_display.set_target_coord(waiting_selection)
			target_area_dislay_node.set_area_effect_coor(_target_display_key, waiting_selection)
		else:
			CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.Default)
			CombatRootControl.Instance.GridCursor.lock_position = false
			target_area_dislay_node.hide_area_effect(_target_display_key)
			target_input_display.set_invalid_target_coord(mouse_over_spot)
			target_area_dislay_node.set_area_effect_coor(_target_display_key, mouse_over_spot)
		
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton and not (event as InputEventMouseButton).pressed:
		if _logging: print("Button Pressed")
		var mouse_pos = CombatRootControl.Instance.MapController.actor_tile_map.get_local_mouse_position()
		var spot = CombatRootControl.Instance.MapController.actor_tile_map.local_to_map(mouse_pos)
		if selection_data.is_coor_selectable(spot):
			select_target(spot, false)
		else:
			clear_target(spot)

func clear_target(coord:Vector2i):
	is_waiting_for_confirm = false
	waiting_selection = null
	target_area_dislay_node.hide_area_effect(_target_display_key)
	target_input_display.set_button_text("Skip")
	target_input_display.set_invalid_target_coord(coord)
	CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.Targeting)
	CombatRootControl.Instance.GridCursor.position = CombatRootControl.Instance.MapController.actor_tile_map.map_to_local(coord)
	CombatRootControl.Instance.GridCursor.lock_position = false

func select_target(coord:Vector2i, confirmed:bool, soft_select=false):
	# Highlight target, but wait for Comfirm button
	if (wait_for_confirm or soft_select) and (not confirmed or coord != waiting_selection):
		if _logging: print("Started Waiting for comfirm")
		is_waiting_for_confirm = true
		waiting_selection = coord
		target_area_dislay_node.set_area_effect_coor(_target_display_key, coord)
		target_input_display.set_button_text("Confirm")
		target_input_display.set_target_coord(coord)
		CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.Targeting)
		CombatRootControl.Instance.GridCursor.position = CombatRootControl.Instance.MapController.actor_tile_map.map_to_local(coord)
		CombatRootControl.Instance.GridCursor.lock_position = true
		return
		
	is_waiting_for_confirm = false
	waiting_selection = null
	
	if _logging: print("Setting Target: " + str(coord))
	# Add selected target to Turn Data
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
		
		var lock_target = target_input_display.lock_on_box.button_pressed
		CombatRootControl.Instance.last_target_records[selection_data.focused_actor.Id] = {"ActorId": actors[0].Id, "LockOn": lock_target}
	# Resume Round
	CombatUiControl.ui_state_controller.set_ui_state(UiStateController.UiStates.ExecRound)

func ui_button_pressed():
	if _logging: print("Confrim button pressed")
	if not is_waiting_for_confirm:
		selection_data.focused_actor.Que.fail_turn()
		CombatUiControl.ui_state_controller.set_ui_state(UiStateController.UiStates.ExecRound)
	elif waiting_selection != null:
		select_target(waiting_selection, true)
	
