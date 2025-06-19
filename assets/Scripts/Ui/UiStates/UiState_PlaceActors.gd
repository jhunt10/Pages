class_name UiState_PlaceActors
extends BaseUiState

const LOGGING = false

signal mouse_over_spot_changed()

enum States {Waiting, Placing, Dragging}

var wait_for_confirm:bool = true
var is_waiting_for_confirm:bool = false
var waiting_selection

var actor_placer_control:ActorPlacerControl
var spawn_area:Array#[Vector2i] 
var actor_positions:Dictionary = {}

var state:States
var placing_actor_id:String = ''
var mouse_down_spot

func _get_debug_name()->String: 
	return "PlaceActors"
	
func _init(controler:UiStateController, args:Dictionary) -> void:
	super(controler, args)
	actor_placer_control = CombatRootControl.Instance.ui_control.actor_placer_control
	actor_placer_control.actor_selected.connect(_on_actor_selected)
	actor_placer_control.confirm_pressed.connect(_on_placement_confirmed)
	spawn_area = args.get("SpawnArea", [Vector2i.ZERO])
	var center = MapHelper.get_center_of_points(spawn_area)
	CombatRootControl.Instance.camera.snap_to_map_pos(center)
	state = States.Waiting
	pass
	
func start_state():
	if _logging: print("Start UiState: PlaceActors")
	actor_placer_control.load_and_show()
	actor_placer_control.show()
	CombatRootControl.Instance.ui_control.hide()
	
func end_state():
	if _logging: print("End UiState: PlaceActors")
	actor_placer_control.hide()
	CombatRootControl.Instance.ui_control.show()
	CombatRootControl.Instance.MapController.player_spawn_area_tile_map.hide()
	
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
	placing_actor_id = actor_id
	state = States.Placing
	CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.SelectingActor)
	pass

func _mouse_moved_into_spot(spot):
	if state == States.Placing:
		var is_spot_valid = _is_spot_valid(spot)
		actor_placer_control.put_actor_in_spot(placing_actor_id, spot, is_spot_valid)
	
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
		actor_positions[placing_actor_id].dir = dir
		actor_placer_control.set_actor_rotation(placing_actor_id, dir)
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
			actor_positions[placing_actor_id] = MapPos.new(mouse_down_spot.x, mouse_down_spot.y, 0, 0)
			actor_placer_control.put_actor_in_spot(placing_actor_id, mouse_down_spot)
			state = States.Dragging
			CombatRootControl.Instance.camera.freeze = true
			CombatRootControl.Instance.GridCursor.set_cursor(GridCursorNode.Cursors.PlacingDragCenter)
			CombatRootControl.Instance.GridCursor.lock_position = true
	if state == States.Waiting:
		var actor_id = _get_actor_id_placed_in_spot(spot)
		if actor_id != '':
			actor_placer_control._on_actor_button_pressed(actor_id)


func _mouse_button_up_in_spot(spot):
	CombatRootControl.Instance.camera.freeze = false
	CombatRootControl.Instance.GridCursor.lock_position = false
	if state == States.Dragging:
		actor_placer_control.darken_actor(placing_actor_id)
		placing_actor_id = ''
		mouse_down_spot = null
		state = States.Waiting
		actor_placer_control.finish_placing()
		actor_placer_control.set_placed_actor_count(actor_positions.size())

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
	if occ_act != '' and occ_act != placing_actor_id:
		return false
	return true

func _on_placement_confirmed():
	# TODO: Cleanup unplaced actor nodes
	for actor_id in actor_positions.keys():
		var actor = ActorLibrary.get_actor(actor_id)
		var pos = actor_positions[actor_id]
		CombatRootControl.Instance.add_actor(actor, pos)
		actor.on_combat_start()
	CombatRootControl.Instance.ui_control.ui_state_controller.set_ui_state(UiStateController.UiStates.ActionInput)
	CombatRootControl.Instance.start_combat_animation()
	
