class_name UiState_PlaceActors
extends BaseUiState

const LOGGING = false

signal mouse_over_spot_changed()

var wait_for_confirm:bool = true
var is_waiting_for_confirm:bool = false
var waiting_selection

var actor_placer_control:ActorPlacerControl

func _get_debug_name()->String: 
	return "PlaceActors"
	
func _init(controler:UiStateController, args:Dictionary) -> void:
	super(controler, args)
	actor_placer_control = CombatRootControl.Instance.ui_control.actor_placer_control
	pass
	
func start_state():
	if _logging: print("Start UiState: PlaceActors")
	actor_placer_control.load_and_show()
	
func end_state():
	if _logging: print("End UiState: PlaceActors")
	actor_placer_control.hide()
	
func handle_input(event):
	if !is_waiting_for_confirm and event is InputEventMouseMotion:
		var spot = CombatRootControl.Instance.GridCursor.current_spot
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton and not (event as InputEventMouseButton).pressed:
		if _logging: print("Button Pressed")
		var mouse_pos = CombatRootControl.Instance.MapController.actor_tile_map.get_local_mouse_position()
		var spot = CombatRootControl.Instance.MapController.actor_tile_map.local_to_map(mouse_pos)

func ui_button_pressed():
	if _logging: print("Confrim button pressed")
