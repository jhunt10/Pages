class_name UiState_Deployment
extends BaseUiState

const LOGGING = false

enum States {Panning, Waiting, Placing, Dragging}

var wait_for_confirm:bool = true
var is_waiting_for_confirm:bool = false
var waiting_selection

var actor_placer_control:ActorPlacerControl
var spawn_area:Array#[Vector2i] 
var actor_positions:Dictionary = {}
var carrier_actor:CarrierActor
var state:States
var deploying_actor_id:String = ''
var mouse_down_spot
var deploying_actor_node:BaseActorNode
var spawn_map:TileMapLayer

func _get_debug_name()->String: 
	return "DeployingActor"
	
func _init(controler:UiStateController, args:Dictionary) -> void:
	super(controler, args)
	actor_placer_control = CombatRootControl.Instance.ui_control.actor_placer_control
	actor_placer_control.actor_selected.connect(_on_actor_selected)
	actor_placer_control.confirm_pressed.connect(_on_placement_confirmed)
	actor_placer_control._spawn_tile_map = CombatRootControl.Instance.MapController.player_spawn_area_tile_map
	deploying_actor_id = args.get("DeployingActor")
	if deploying_actor_id:
		state = States.Placing
		CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.SelectingActor)
	else:
		printerr("UiState_Deployment: No DeployingActor id provided")
	carrier_actor = CombatRootControl.list_player_actors()[0]
	deploying_actor_node = CombatRootControl.get_actor_node(deploying_actor_id)
	spawn_map = CombatRootControl.Instance.MapController.player_spawn_area_tile_map
	var center = CombatRootControl.Instance.GameState.get_actor_pos(carrier_actor)
	CombatRootControl.Instance.camera.snap_to_map_pos(center)
	
	var spawn_area_arg = args.get("SpawnArea", null)
	if spawn_area_arg is Array:
		spawn_area = spawn_area_arg
	else:
		spawn_area = []
		var center_vec = center.to_vector2i()
		spawn_area.append(center_vec + Vector2i(0,1))
		spawn_area.append(center_vec + Vector2i(0,-1))
		spawn_area.append(center_vec + Vector2i(1,0))
		spawn_area.append(center_vec + Vector2i(-1,0))
	
	if !deploying_actor_node:
		CombatRootControl.Instance.add_actor(ActorLibrary.get_actor(deploying_actor_id), center, true, false)
		deploying_actor_node = CombatRootControl.get_actor_node(deploying_actor_id)
	deploying_actor_node.set_facing_dir(MapPos.Directions.South)
	#deploying_actor_node.reparent(spawn_map)

func start_state():
	if _logging: print("Start UiState: PlaceActors")
	CombatRootControl.Instance.ui_control.combat_control_panel.set_status("Spawning")
	spawn_map.clear()
	var center = CombatRootControl.Instance.GameState.get_actor_pos(carrier_actor)
	for coor in spawn_area:
		spawn_map.set_cell(coor, 0, Vector2i(0,3))
	spawn_map.show()
	CombatRootControl.Instance.ui_control.active_combat_control.hide()
	CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.SelectingActor)
	
func end_state():
	if _logging: print("End UiState: PlaceActors")
	actor_placer_control.hide()
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
		elif mouse_button_event.button_index == 2:
			var actor_id = _get_actor_id_placed_in_spot(spot)
			if actor_id != '':
				actor_positions.erase(actor_id)
				actor_placer_control.unplace_actor(actor_id)
				actor_placer_control.set_placed_actor_count(actor_positions.size())

func ui_button_pressed():
	if _logging: print("Confrim button pressed")

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
		#actor_placer_control.put_actor_in_spot(deploying_actor_id, spot, is_spot_valid)
	
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
		actor_positions[deploying_actor_id].dir = dir
		deploying_actor_node.set_facing_dir(dir)
		#actor_placer_control.set_actor_rotation(deploying_actor_id, dir)
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
			actor_positions[deploying_actor_id] = MapPos.new(mouse_down_spot.x, mouse_down_spot.y, 0, MapPos.Directions.South)
			#actor_placer_control.put_actor_in_spot(deploying_actor_id, mouse_down_spot)
			state = States.Dragging
			CombatRootControl.Instance.camera.freeze_camera()
			CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.PlacingDragCenter)
			CombatRootControl.Instance.GridCursor.lock_position = true
	if state == States.Waiting:
		var actor_id = _get_actor_id_placed_in_spot(spot)
		if actor_id != '':
			actor_placer_control._on_actor_button_pressed(actor_id)


func _mouse_button_up_in_spot(spot):
	CombatRootControl.Instance.camera.unfreeze_camera()
	CombatRootControl.Instance.GridCursor.lock_position = false
	if state == States.Dragging:
		deploy_actor()
		#actor_placer_control.darken_actor(deploying_actor_id)
		#deploying_actor_id = ''
		#mouse_down_spot = null
		#state = States.Waiting
		#actor_placer_control.finish_placing()
		#actor_placer_control.set_placed_actor_count(actor_positions.size())

func deploy_actor():
	var deploy_pos = actor_positions[deploying_actor_id]
	CombatRootControl.Instance.deploy_actor(deploying_actor_id, deploy_pos)
	var actor_node = CombatRootControl.get_actor_node(deploying_actor_id)
	var start_pos = CombatRootControl.Instance.GameState.get_actor_pos(carrier_actor)
	start_pos.dir = MapHelper.get_direction_between_spots(start_pos, deploy_pos)
	# TODO: This assumes deploying to adjacent spot
	var scripted_moves = [{
			"Pos": start_pos,
			"Frames": 0,
			"Speed": 1
		}]
	scripted_moves.append({
			"Pos": MapPos.new(deploy_pos.x, deploy_pos.y, 0, start_pos.dir),
			"Frames": ActionQueController.FRAMES_PER_ACTION,
			"Speed": 1
		})
	scripted_moves.append({
			"Pos": deploy_pos,
			"Frames": ActionQueController.FRAMES_PER_ACTION,
			"Speed": 1,
			"End": true
		})
	actor_node.que_scripted_movement(scripted_moves)
	CombatRootControl.Instance.ui_control.ui_state_controller.set_ui_state(UiStateController.UiStates.ActionInput)

func _get_actor_id_placed_in_spot(spot)->String:
	for actor_id in actor_positions.keys():
		var pos = actor_positions[actor_id]
		if pos.x == spot.x and pos.y == spot.y:
			return actor_id
	return ''

func _is_spot_valid(spot):
	if not spawn_area.has(spot):
		return false
	var occ_act = _get_actor_id_placed_in_spot(spot)
	if occ_act != '' and occ_act != deploying_actor_id:
		return false
	return true

func _on_placement_confirmed():
	# TODO: Cleanup unplaced actor nodes
	for actor_id in actor_positions.keys():
		var actor = ActorLibrary.get_actor(actor_id)
		var pos = actor_positions[actor_id]
		CombatRootControl.Instance.add_actor(actor, pos, true)
		actor.on_combat_start()
	#CombatRootControl.Instance.ui_control.ui_state_controller.set_ui_state(UiStateController.UiStates.ActionInput)
	#CombatRootControl.Instance.start_combat_animation()
	CombatRootControl.Instance.start_next_phase()
	
