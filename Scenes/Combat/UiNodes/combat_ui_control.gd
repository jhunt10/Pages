class_name CombatUiControl
extends Control


var camera:MoveableCamera2D:
	get: return CombatRootControl.Instance.camera

@export var game_over_screen:GameOverScreen
@export var victory_screen:GameVictoryScreen
@export var menu_container:CenterContainer
@export var menu_button:TextureButton 
@export var book_button:TextureButton 
@export var pause_menu:PauseMenuControl 

@export var target_input_display:TargetInputControl
@export var player_stats_panels_container:BoxContainer
@export var que_input:QueInputControl
var que_display:QueDisplayControl:
	get:
		if que_input:
			return que_input.que_display_control
		return null
@export var que_collection_display:QueCollectionControl
@export var stats_collection_display:StatCollectionDisplayControl
@export var option_select_menu:OptionSelectMenu
@export var drop_message_control:DropMessageControl
@export var actor_placer_control:ActorPlacerControl


static var Instance:CombatUiControl
static var ui_state_controller:UiStateController = UiStateController.new()
var actor_ids_to_stat_panels:Dictionary={}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#if !Instance: Instance = self
	#elif Instance != self:
		#printerr(("Multiple UiStateController created."))
		#self.queue_free()
		#return
	Instance = self
	menu_button.pressed.connect(_on_menu_pressed)
	book_button.pressed.connect(_on_book_pressed)
	target_input_display.hide()
	game_over_screen.hide()
	victory_screen.hide()

#func do_test():
	#var current_actor_id = stat_panel_control.actor.Id
	#var cur_index = CombatRootControl.Instance.GameState._actors.keys().find(current_actor_id)
	#var next_index = (cur_index + 1) % CombatRootControl.Instance.GameState._actors.size()
	#set_player_actor(CombatRootControl.Instance.GameState._actors.values()[next_index])

func build_player_stats_panels():
	var player_ids = CombatRootControl.Instance.list_player_actor_ids()
	for child in player_stats_panels_container.get_children():
		if child is StatPanelControl:
			if actor_ids_to_stat_panels.values().has(actor_ids_to_stat_panels):
				if player_ids.has((child as StatPanelControl).actor.Id):
					continue
		child.queue_free()
	
	for actor in CombatRootControl.Instance.list_player_actors():
		var index = CombatRootControl.Instance.get_player_index_of_actor(actor)
		if actor_ids_to_stat_panels.keys().has(actor.Id):
			continue
		var new_panel:StatPanelControl = load("res://Scenes/Combat/UiNodes/StatsPanel/combat_stat_panel_control.tscn").instantiate()
		new_panel.set_actor(actor)
		player_stats_panels_container.add_child(new_panel)
		new_panel.button.pressed.connect(on_player_stat_clicked.bind(index))
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	ui_state_controller.update(delta)

func on_player_stat_clicked(index):
	CombatRootControl.Instance.set_player_index(index)

# Should only be called by CombatRootControl
func set_player_actor_index(index):
	var player_actor = CombatRootControl.Instance.get_player_actor(index)
	if player_actor:
		que_input.set_actor(player_actor)

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

func _on_book_pressed():
	ui_state_controller.set_ui_state(UiStateController.UiStates.CharacterSheet)
	
