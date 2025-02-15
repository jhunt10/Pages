class_name CombatUiControl
extends Control


var camera:MoveableCamera2D:
	get: return CombatRootControl.Instance.camera

@export var game_over_screen:GameOverScreen
@export var victory_screen:GameVictoryScreen
@export var menu_container:CenterContainer
@export var menu_button:TextureButton 
@export var pause_menu:PauseMenuControl 

@export var target_input_display:TargetInputControl
@export var p1_stat_panel_control:StatPanelControl
@export var p2_stat_panel_control:StatPanelControl
@export var p3_stat_panel_control:StatPanelControl
@export var p4_stat_panel_control:StatPanelControl
@export var que_input:QueInputControl
var que_display:QueDisplayControl:
	get:
		if que_input:
			return que_input.que_display_control
		return null
@export var que_collection_display:QueCollectionControl
@export var stats_collection_display:StatCollectionDisplayControl
@export var item_select_menu:ItemSelectionInputDisplay
@export var drop_message_control:DropMessageControl


static var Instance:CombatUiControl
static var ui_state_controller:UiStateController = UiStateController.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#if !Instance: Instance = self
	#elif Instance != self:
		#printerr(("Multiple UiStateController created."))
		#self.queue_free()
		#return
	Instance = self
	menu_button.pressed.connect(_on_menu_pressed)
	#test_button.pressed.connect(do_test)
	target_input_display.visible = false
	game_over_screen.hide()
	victory_screen.hide()
	var player_1 = StoryState.get_player_actor(0)
	if player_1: 
		p1_stat_panel_control.set_actor(player_1)
		p1_stat_panel_control.button.pressed.connect(on_player_stat_clicked.bind(0))
	else: 
		p1_stat_panel_control.hide()
		
	var player_2 = StoryState.get_player_actor(1)
	if player_2: 
		p2_stat_panel_control.set_actor(player_2)
		p2_stat_panel_control.button.pressed.connect(on_player_stat_clicked.bind(1))
	else: 
		p2_stat_panel_control.hide()
		
	var player_3 = StoryState.get_player_actor(2)
	if player_3: 
		p3_stat_panel_control.set_actor(player_3)
		p3_stat_panel_control.button.pressed.connect(on_player_stat_clicked.bind(2))
	else: 
		p3_stat_panel_control.hide()
		
	var player_4 = StoryState.get_player_actor(3)
	if player_4: 
		p4_stat_panel_control.set_actor(player_4)
		p4_stat_panel_control.button.pressed.connect(on_player_stat_clicked.bind(3))
	else: 
		p4_stat_panel_control.hide()
	
	pass # Replace with function body.

#func do_test():
	#var current_actor_id = stat_panel_control.actor.Id
	#var cur_index = CombatRootControl.Instance.GameState._actors.keys().find(current_actor_id)
	#var next_index = (cur_index + 1) % CombatRootControl.Instance.GameState._actors.size()
	#set_player_actor(CombatRootControl.Instance.GameState._actors.values()[next_index])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	ui_state_controller.update(delta)

func on_player_stat_clicked(index):
	CombatRootControl.Instance.set_player_index(index)

func set_player_actor_index(index, move_camera:bool=true):
	var player_actor = StoryState.get_player_actor(index)
	if player_actor:
		set_player_actor(player_actor)
	if move_camera:
		CombatRootControl.Instance.camera.start_auto_pan_to_actor(player_actor)

func set_player_actor(actor:BaseActor):
	
	que_input.set_actor(actor)
	#CombatRootControl.Instance.camera.start_auto_pan_to_actor(actor)


func _input(event: InputEvent) -> void:
	# Escape Key Pressed
	if event is InputEventKey and (event as InputEventKey).keycode == KEY_ESCAPE and (event as InputEventKey).pressed:
		if not pause_menu.visible:
			if ui_state_controller.current_ui_state and ui_state_controller.current_ui_state.allow_pause_menu():
				ui_state_controller.set_ui_state(UiStateController.UiStates.PauseMenu)
		else:
			ui_state_controller.back_to_last_state()

var dragging = false
var mouse_drag_start:Vector2 
var camera_drag_start:Vector2 
func _unhandled_input(event: InputEvent) -> void:
	ui_state_controller.handle_input(event)
	#if event is InputEventMouseButton:
		#var mouse_button_event = event as InputEventMouseButton
		#if mouse_button_event.button_index == MOUSE_BUTTON_LEFT:
			#if mouse_button_event.pressed:
				#dragging = true
				#mouse_drag_start = get_global_mouse_position()
				#camera_drag_start = camera.position
			#else:
				#dragging = false
				#camera_drag_start = Vector2.ZERO
			#print("Mouse EVent: Dragging:%s | cam_pos: %s | Scale: %s" % [dragging, camera_drag_start, camera.zoom])
	#if dragging and event is InputEventMouseMotion:
		#var new_mouse_pos = get_global_mouse_position()
		#var diff = mouse_drag_start - new_mouse_pos
		#var cam_diff = (diff / camera.zoom)
		#camera.position = camera_drag_start + cam_diff
		#print("MouseMove: start: %s | cur: %s | diff: %s | cam_scale: %s | cam_move:%s" % [mouse_drag_start, new_mouse_pos, diff, camera.zoom, cam_diff])
		
		#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			#if event is InputEventMouseMotion:
				#var mouse_pos = 
		
func _on_menu_pressed():
	ui_state_controller.set_ui_state(UiStateController.UiStates.PauseMenu)
