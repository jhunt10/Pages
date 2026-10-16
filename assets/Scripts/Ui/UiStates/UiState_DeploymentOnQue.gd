class_name UiState_DeploymentOnQue
extends BaseUiState

const LOGGING = false

enum States {Panning, Waiting, Placing, Dragging}

var deployment_control:ActorDeploymentControl:
	get:
		return CombatRootControl.Instance.ui_control.actor_deploy_control

var wait_for_confirm:bool = true
var is_waiting_for_confirm:bool = false
var waiting_selection

var spawn_area:Array # Raw relative vec2 matrix
var spawn_poses:Array # Real coors
var carrier_actor:CarrierActor
var carrier_actor_node:BaseActorNode
var state:States
var carrier_actor_id:String = ""
var queing_page_id:String = ""
#var deploying_actor_id:String = ''
var deploying_position
var mouse_down_spot
#var deploying_actor_node:BaseActorNode
var spawn_map:TileMapLayer

var pre_selected_actor_ids:Array = []

func _get_debug_name()->String: 
	return "DeployingActor"
	
func _init(controler:UiStateController, args:Dictionary) -> void:
	super(controler, args)
	carrier_actor_id = args.get("CarrierActor")
	queing_page_id = args.get("ActionId", "Deploy_ActionPage")
	pre_selected_actor_ids = args.get("DeployingActorIds", [])
	carrier_actor = ActorLibrary.get_actor(carrier_actor_id)
	if carrier_actor_id:
		state = States.Placing
		CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.SelectingActor)
	else:
		printerr("UiState_Deployment: No DeployingActor id provided")
	
	
	
	
	#deploying_actor_node = CombatRootControl.create_temp_actor_node(deploying_actor_id)
	carrier_actor_node = CombatRootControl.get_actor_node(carrier_actor_id)
	spawn_map = CombatRootControl.Instance.MapController.player_spawn_area_tile_map
	var center = carrier_actor.Que.get_movement_preview_final_pos()
	CombatRootControl.Instance.camera.snap_to_map_pos(center)
	
	var spawn_area_arg = args.get("SpawnArea", null)
	if spawn_area_arg is Array:
		spawn_area = spawn_area_arg
	else:
		var deploy_range = carrier_actor.stats.get_stat("DeployRange", 0)
		if deploy_range == 1:
			spawn_area = [	[0,-2],
							[-1,-1],[0,-1],[1,-1],
							[-2,0],[-1,0],	[1,0],[2,0],
							[-1,1],[0,1],[1,1],
							[0,2]]
		
		if deploy_range >= 2:
			spawn_area = [	[0,-3],
							[-1,-2],[0,-2],[1,-2],
							[-2,-1],[-1,-1],[0,-1],[1,-1],[2,-1],
							[-3,0],[-2,0],[-1,0],	[1,0],[2,0],[3,0],
							[-2,1],[-1,1],[0,1],[1,1],[2,1],
							[-1,2],[0,2],[1,2],
							[0,3]]
		
		if deploy_range == 0 or not spawn_area or spawn_area.size() == 0:
			spawn_area = [[0,1],[0,-1],[-1,0],[1,0]]
			
	_build_spawn_area()
	#if !deploying_actor_node:
		#CombatRootControl.Instance.add_actor(ActorLibrary.get_actor(deploying_actor_id), center, true, false)
		#deploying_actor_node = CombatRootControl.create_temp_actor_node(deploying_actor_id)
	#deploying_actor_node.set_facing_dir(MapPos.Directions.South)
	#spawn_map.add_child(deploying_actor_node)

var _extra_path_arrow:Sprite2D
func get_extra_path_arrow()->Sprite2D:
	if _extra_path_arrow:
		return _extra_path_arrow
	_extra_path_arrow = carrier_actor_node.path_arrow.duplicate()
	_extra_path_arrow.modulate = Color(1,1,1,0.5)
	_extra_path_arrow.rotation_degrees = 0
	carrier_actor_node.add_child(_extra_path_arrow)
	_extra_path_arrow.show()
	return _extra_path_arrow

func _build_spawn_area():
	var center = carrier_actor.Que.get_movement_preview_final_pos()
	var center_vec = center.to_vector2i()
	var spawn_spot = center_vec
	spawn_map.clear()
	spawn_poses.clear()
	var game_state = CombatRootControl.Instance.GameState
	for coor in spawn_area:
		if coor is Array:
			coor = Vector2i(coor[0], coor[1])
		spawn_spot = center_vec + coor
		if game_state.is_spot_open(spawn_spot):
			spawn_map.set_cell(spawn_spot, 0, Vector2i(0,3))
			spawn_poses.append(spawn_spot)
		var other_actors = game_state.get_actors_at_pos(spawn_spot)
		if other_actors.size() > 0:
			for other_actor:BaseActor in other_actors:
				if other_actor is CarrierActor and other_actor.TeamKey == carrier_actor.TeamKey:
					spawn_poses.append(spawn_spot)
					spawn_map.set_cell(spawn_spot, 0, Vector2i(0,6))
	

func start_state():
	if _logging: print("Start UiState: DeployingActor")
	CombatRootControl.Instance.ui_control.combat_control_panel.set_status("Que Deploy")
	if spawn_map:
		spawn_map.show()
	CombatRootControl.Instance.ui_control.active_combat_control.hide()
	deployment_control.deployment_ui_state = self
	#deployment_control.set_deploying_actor(carrier_actor, ActorLibrary.get_actor(deploying_actor_id))
	deployment_control.actor_buttons_control.set_carrier(carrier_actor, pre_selected_actor_ids)
	deployment_control.show()
	if not deployment_control.cancled.is_connected(_on_canceled):
		deployment_control.cancled.connect(_on_canceled)
	if not deployment_control.confirmed.is_connected(_on_confirm):
		deployment_control.confirmed.connect(_on_confirm)
	if not deployment_control.actor_buttons_control.button_states_changed.is_connected(_on_selected_deploying_actors_change):
		deployment_control.actor_buttons_control.button_states_changed.connect(_on_selected_deploying_actors_change)
	_on_selected_deploying_actors_change(deployment_control.actor_buttons_control.get_select_deploy_actor_ids())
	CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.SelectingActor)
	deployment_control.check_comfirm_button_enabled()
	
func end_state():
	if _logging: print("End UiState: DeployingActor")
	deployment_control.hide()
	if _extra_path_arrow:
		_extra_path_arrow.queue_free()
	CombatRootControl.Instance.MapController.player_spawn_area_tile_map.hide()
	CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.Default)
	
func handle_input(event):
	# Escape Key Pressed
	if event is InputEventKey:
		if (event as InputEventKey).keycode == KEY_ESCAPE and (event as InputEventKey).pressed:
			_on_canceled()
	
	if event is InputEventMouseMotion:
		var spot = CombatRootControl.Instance.GridCursor.mouse_spot
		_mouse_moved_into_spot(spot)
			
	
	if event is InputEventMouseButton:
		var spot = CombatRootControl.Instance.GridCursor.mouse_spot
		var mouse_button_event = (event as InputEventMouseButton)
		if mouse_button_event.button_index == 1:
			if mouse_button_event.pressed:
				_mouse_button_down_in_spot(spot)
			else:
				_mouse_button_up_in_spot(spot)

func ui_button_pressed():
	if _logging: print("Confrim button pressed")

func _on_canceled():
	CombatRootControl.Instance.ui_control.ui_state_controller.back_to_last_state()

func _on_confirm():
	if !deploying_position:
		return
	var page = ItemLibrary.get_item(queing_page_id)
	var deploying_actor_ids = deployment_control.actor_buttons_control.get_select_deploy_actor_ids()
	if deploying_actor_ids.size() > 0:
		var main_deploy_id = deploying_actor_ids[0]
		var transfer_actor_ids:Array = deploying_actor_ids
		transfer_actor_ids.erase(main_deploy_id)
		var center = carrier_actor.Que.get_movement_preview_final_pos()
		var relative_pos = MapPos.new(
			deploying_position.x - center.x,
			deploying_position.y - center.y,
			center.z,
			deploying_position.dir
		)
		DeploymentHelper.deploy_actor(main_deploy_id, deploying_position, transfer_actor_ids, true)
		carrier_actor.Que.que_to_deploy_other_actor(page, main_deploy_id, relative_pos, transfer_actor_ids)
	CombatRootControl.Instance.ui_control.ui_state_controller.back_to_last_state()
	pass

func _on_selected_deploying_actors_change(selected_actor_ids:Array):
	var path_arrow = get_extra_path_arrow()
	var player_actors = StoryState.list_party_actors_ids()
	if selected_actor_ids.size() > 0 and player_actors.has(selected_actor_ids[0]):
		path_arrow.modulate = StoryState.get_player_color(selected_actor_ids[0])
	else:
		path_arrow.modulate = Color(1,1,1,0.5)
	deployment_control.check_comfirm_button_enabled()

func _mouse_moved_into_spot(spot):
	if state == States.Placing:
		var is_spot_valid = _is_spot_valid(spot)
		if is_spot_valid:
			var path_arrow = get_extra_path_arrow()
			path_arrow.global_position = spawn_map.map_to_local(spot)
			deploying_position = MapPos.Parse(spot)
			deployment_control.check_comfirm_button_enabled()
			
	
	elif state == States.Dragging:
		var dir = MapPos.Directions.North
		var x_diff = mouse_down_spot.x - spot.x
		var y_diff = mouse_down_spot.y - spot.y
		var path_arrow = get_extra_path_arrow()
		if abs(x_diff) > abs(y_diff):
			if x_diff < 0:
				dir = MapPos.Directions.East
				path_arrow.rotation_degrees = 90
			else:
				dir = MapPos.Directions.West
				path_arrow.rotation_degrees = 270
		else:
			if y_diff < 0:
				dir = MapPos.Directions.South
				path_arrow.rotation_degrees = 180
			else:
				dir = MapPos.Directions.North
				path_arrow.rotation_degrees = 0
		deploying_position.dir = dir
		if x_diff == 0 and y_diff == 0:
			CombatRootControl.Instance.GridCursor.lock_position = true
			CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.PlacingDragCenter)
		else:
			CombatRootControl.Instance.GridCursor.lock_position = false
			CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.PlacingDraging, dir)
	
	else:
		if spawn_area.has(spot):
			CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.SelectingTile)
		else:
			CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.Default)

func _mouse_button_down_in_spot(spot):
	if state == States.Placing || state == States.Waiting:
		if _is_spot_valid(spot):
			mouse_down_spot = spot
			deploying_position = MapPos.new(
				mouse_down_spot.x, 
				mouse_down_spot.y, 
				0, 
				MapPos.Directions.North)
			state = States.Dragging
			CombatRootControl.Instance.camera.freeze_camera()
			CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.PlacingDragCenter)
			CombatRootControl.Instance.GridCursor.lock_position = true
			
			var path_arrow = get_extra_path_arrow()
			path_arrow.global_position = spawn_map.map_to_local(spot)
			path_arrow.rotation_degrees = 0

func _mouse_button_up_in_spot(_spot):
	CombatRootControl.Instance.camera.unfreeze_camera()
	CombatRootControl.Instance.GridCursor.lock_position = false
	if state == States.Dragging:
		state = States.Waiting

func _is_spot_valid(spot):
	if not spawn_poses.has(spot):
		return false
	#var occ_act = _get_actor_id_placed_in_spot(spot)
	#if occ_act != '' and occ_act != deploying_actor_id:
		#return false
	return true
