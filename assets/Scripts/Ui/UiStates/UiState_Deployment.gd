class_name UiState_Deployment
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
var state:States
var deploying_actor_id:String = ''
var deploying_position
var mouse_down_spot
var deploying_actor_node:BaseActorNode
var spawn_map:TileMapLayer

func _get_debug_name()->String: 
	return "DeployingActor"
	
func _init(controler:UiStateController, args:Dictionary) -> void:
	super(controler, args)
	deploying_actor_id = args.get("DeployingActor")
	if deploying_actor_id:
		state = States.Placing
		CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.SelectingActor)
	else:
		printerr("UiState_Deployment: No DeployingActor id provided")
	deploying_actor_node = CombatRootControl.create_temp_actor_node(deploying_actor_id)
	carrier_actor = deploying_actor_node.Actor.get_carrier_actor()
	spawn_map = CombatRootControl.Instance.MapController.player_spawn_area_tile_map
	var center = CombatRootControl.Instance.GameState.get_actor_pos(carrier_actor)
	CombatRootControl.Instance.camera.snap_to_map_pos(center)
	
	var spawn_area_arg = args.get("SpawnArea", null)
	if spawn_area_arg is Array:
		spawn_area = spawn_area_arg
	else:
		var deploy_range = deploying_actor_node.Actor.stats.get_stat("DeployRange", 0)
		deploy_range += carrier_actor.stats.get_stat("DeployRange", 0)
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
	if !deploying_actor_node:
		CombatRootControl.Instance.add_actor(ActorLibrary.get_actor(deploying_actor_id), center, true, false)
		deploying_actor_node = CombatRootControl.create_temp_actor_node(deploying_actor_id)
	deploying_actor_node.set_facing_dir(MapPos.Directions.South)
	spawn_map.add_child(deploying_actor_node)

func _build_spawn_area():
	var center = CombatRootControl.Instance.GameState.get_actor_pos(carrier_actor)
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
	CombatRootControl.Instance.ui_control.combat_control_panel.set_status("Spawning")
	spawn_map.show()
	CombatRootControl.Instance.ui_control.active_combat_control.hide()
	deployment_control.set_deploying_actor(carrier_actor, ActorLibrary.get_actor(deploying_actor_id))
	deployment_control.show()
	if not deployment_control.cancled.is_connected(_on_canceled):
		deployment_control.cancled.connect(_on_canceled)
	CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.SelectingActor)
	
func end_state():
	if _logging: print("End UiState: DeployingActor")
	deployment_control.hide()
	deploying_actor_node.queue_free()
	CombatRootControl.Instance.MapController.player_spawn_area_tile_map.hide()
	CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.Default)
	
func handle_input(event):
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

func _on_actor_selected(actor_id):
	deploying_actor_id = actor_id
	state = States.Placing
	CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.SelectingActor)
	pass

func _mouse_moved_into_spot(spot):
	if state == States.Placing:
		var is_spot_valid = _is_spot_valid(spot)
		if is_spot_valid:
			deploying_actor_node.position = spawn_map.map_to_local(spot)
			deploying_actor_node.show()
		else:
			deploying_actor_node.hide()
	
	elif state == States.Dragging:
		var dir = MapPos.Directions.North
		var x_diff = mouse_down_spot.x - spot.x
		var y_diff = mouse_down_spot.y - spot.y
		if abs(x_diff) > abs(y_diff):
			if x_diff < 0:
				dir = MapPos.Directions.East
			else:
				dir = MapPos.Directions.West
		else:
			if y_diff < 0:
				dir = MapPos.Directions.South
			else:
				dir = MapPos.Directions.North
		deploying_position.dir = dir
		deploying_actor_node.set_facing_dir(dir)
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
	if state == States.Placing:
		if _is_spot_valid(spot):
			mouse_down_spot = spot
			deploying_position = MapPos.new(
				mouse_down_spot.x, 
				mouse_down_spot.y, 
				0, 
				MapPos.Directions.South)
			state = States.Dragging
			CombatRootControl.Instance.camera.freeze_camera()
			CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.PlacingDragCenter)
			CombatRootControl.Instance.GridCursor.lock_position = true

func _mouse_button_up_in_spot(_spot):
	CombatRootControl.Instance.camera.unfreeze_camera()
	CombatRootControl.Instance.GridCursor.lock_position = false
	if state == States.Dragging:
		deploy_actor()

func deploy_actor():
	var sub_actors = deployment_control.list_selected_sub_actor_ids()
	var game_state = CombatRootControl.Instance.GameState
	
	var transfer_to_actor:CarrierActor = null
	var other_actors = game_state.get_actors_at_pos(deploying_position)
	if other_actors.size() > 0:
		for other_actor:BaseActor in other_actors:
			if other_actor is CarrierActor and other_actor.TeamKey == carrier_actor.TeamKey:
				transfer_to_actor = other_actor
				break
	# Transfering to another carrier
	if transfer_to_actor:
		CombatRootControl.Instance.transfer_actor(deploying_actor_id, transfer_to_actor)
	# Deploying to open spot
	else:
		CombatRootControl.Instance.deploy_actor(deploying_actor_id, deploying_position, sub_actors)
		var actor_node = CombatRootControl.get_actor_node(deploying_actor_id)
		VfxHelper.create_vfx_on_actor(actor_node.Actor, "DeployActorVfx", {}, carrier_actor)
	CombatRootControl.Instance.ui_control.ui_state_controller.back_to_last_state()

func _is_spot_valid(spot):
	if not spawn_poses.has(spot):
		return false
	#var occ_act = _get_actor_id_placed_in_spot(spot)
	#if occ_act != '' and occ_act != deploying_actor_id:
		#return false
	return true
