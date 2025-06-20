@tool
class_name QueInputControl
extends Control

const PADDING = 8
enum States {Hidden, Growing, Showing, Shrinking}

signal page_special_selected(action_key:String)

@export var showing:bool:
	set(val):
		showing = val
		if val:
			if state == States.Hidden or state == States.Shrinking:
				state = States.Growing
		else:
			if state == States.Showing or state == States.Growing:
				state = States.Shrinking

@export var _fill_button:Button
			
@export var nodes_container:Control
@export var que_display_control:QueDisplayControl
@export var que_display_patch:BackPatchContainer
#@export var on_que_options_menu:OptionSelectMenu
@export var back_patch:BackPatchContainer
@export var main_container:HBoxContainer 
@export var page_button_prefab:QueInputButtonControl
@export var start_label:Label
@export var side_start_button:QueInput_StartButton
@export var top_start_button:QueInput_StartButton
@export var slide_speed:float = 100
@export var page_Selection_container:HBoxContainer

@export var state:States:
	set(val):
		state = val
		if nodes_container:
			print(self.get_parent().size)
			nodes_container.position.x = (self.get_parent().size.x / 2) - (back_patch.size.x / 2)
			if state == States.Hidden:
				nodes_container.position.y = 0
			if state == States.Showing:
				nodes_container.position.y = -(back_patch.size.y + que_display_patch.size.y + 16)

var _actor:BaseActor
var _page_buttons:Dictionary = {} 
var _resize:bool = true
var _target_display_key
var _target_display_action_key

# Don't automatically show start button. Mainly for tutorial
var supress_start:bool = false

# When selecting pages for something other than queing
var selecetion_mode:bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	#super()
	#if Engine.is_editor_hint(): return
	CombatRootControl.QueController.start_of_round.connect(_round_start)
	CombatRootControl.QueController.end_of_round.connect(_round_ends)
	side_start_button.button.pressed.connect(_start_button_pressed)
	side_start_button.button.disabled = true
	top_start_button.button.pressed.connect(_start_button_pressed)
	top_start_button.button.disabled = true
	page_button_prefab.visible = false
	#on_que_options_menu.visible = false
	page_Selection_container.hide()
	_fill_button.pressed.connect(_fill_que_with_wait)
	pass # Replace with function body.

func _fill_que_with_wait():
	var wait = ItemLibrary.get_item("Wait")
	if wait:
		for r in range(_actor.Que.get_max_que_size()):
			_actor.Que.que_action(wait)
			if _actor.Que.is_ready():
				break

func hide_start_button():
	#var que_display_size = que_display_control.size.x
	#var self_size = back_patch.size.x
	#var use_top = (top_start_button.size.x > self_size - que_display_size)
	#printerr("SelfSize: %s | DisSize: %s" % [self_size, que_display_size])
	#if use_top:
		top_start_button.button.disabled = true
		top_start_button.state = QueInput_StartButton.States.Shrinking
	#else:
		side_start_button.button.disabled = true
		side_start_button.state = QueInput_StartButton.States.Shrinking

func show_start_button():
	if supress_start:
		return
	var all_ready = true
	for player:BaseActor in CombatRootControl.list_player_actors():
		if not player.Que.is_ready():
			all_ready = false
	var que_display_size = que_display_patch.size.x
	var self_size = back_patch.size.x #+ (back_patch.sides_padding * 2)
	var use_top = (top_start_button.size.x < self_size - que_display_size)
	#printerr("SelfSize: %s | DisSize: %s | UseTop: %s" % [self_size, que_display_size, use_top])
	if use_top:
		if all_ready:
			top_start_button.label.text = "Start"
		else:
			top_start_button.label.text = "Next"
		top_start_button.button.disabled = false
		top_start_button.state = QueInput_StartButton.States.Growing
	else:
		if all_ready:
			side_start_button.label.text = "Start"
		else:
			side_start_button.label.text = "Next"
		side_start_button.button.disabled = false
		side_start_button.state = QueInput_StartButton.States.Growing
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	nodes_container.position.x = (self.get_parent().size.x / 2) - (back_patch.size.x / 2)
	nodes_container.size.x = back_patch.size.x
	if state == States.Growing:
		var y_size = back_patch.size.y + que_display_patch.size.y + 16
		var move = delta * slide_speed
		if nodes_container.position.y - move < 0 - y_size:
			state = States.Showing
		else:
			nodes_container.position.y -= move
	if state == States.Shrinking:
		var move = delta * slide_speed
		if nodes_container.position.y + move > 0:
			state = States.Hidden
			if page_Selection_container.visible:
				page_Selection_container.hide()
		else:
			nodes_container.position.y += move
		
	#var hight = self.size.y
	#var box_hight = back_patch.size.y + que_display_control.size.y
	#var box_scale = hight / box_hight
	#back_patch.scale = Vector2(box_scale, box_scale)
	#var self_size = self.size
	#var box_size = back_patch.size * box_scale
	#back_patch.position = Vector2((self_size.x / 2) - (box_size.x / 2), (self_size.y / 2) - (box_size.y / 2))
	if Engine.is_editor_hint():
		return
	#super(delta)
	#if Engine.is_editor_hint(): return
	if _resize:
		_resize = false

func set_actor(actor:BaseActor):
	if _actor:
		_actor.pages.items_changed.disconnect(_build_buttons)
		_actor.Que.action_que_changed.disconnect(_on_que_change)
		_actor.Que.ammo_changed.disconnect(_on_ammo_change)
	_actor = actor
	_actor.pages.items_changed.connect(_build_buttons)
	_actor.Que.action_que_changed.connect(_on_que_change)
	_actor.Que.ammo_changed.connect(_on_ammo_change)
	_build_buttons()
	clear_preview_display()
	show_last_qued_target_area()
	que_display_control.set_actor(actor)
	

func _build_buttons():
	if _page_buttons.values().size() > 0:
		for but in _page_buttons.values():
			but.queue_free()
		_page_buttons.clear()
	var index = 0
	var action_keys = _actor.get_action_key_list()
	for action_key in action_keys:
		if action_key == null:
			continue
		var action = ItemLibrary.get_item(action_key)
		if !action:
			printerr("que_input_control._build_buttons: Failed to find Action '%s'." % [action_key])
			continue
		var new_button:QueInputButtonControl = page_button_prefab.duplicate()
		new_button.name = "PageSlot" + str(index)
		page_button_prefab.get_parent().add_child(new_button)
		new_button.visible = true
		new_button.set_page(_actor, action)
		#if action == null:
			#new_button.get_child(0).texture = load(ActionLibrary.NO_ICON_SPRITE)
		#else:
			#new_button.get_child(0).texture = action.get_large_page_icon(_actor)
			#if not MainRootNode.is_mobile:
				#new_button.mouse_entered.connect(_mouse_entered_page_button.bind(index, action_key))
				#new_button.mouse_exited.connect(_mouse_exited_action_button.bind(index, action_key))
		new_button.button.pressed.connect(_page_button_pressed.bind(index, action_key))
		#new_button.selection_button.pressed.connect(_on_page_special_selected.bind(action_key))
		
		_page_buttons[action_key] = new_button
		index += 1
	_on_que_change()
	
	#self.size = Vector2i(main_container.size.x + (2 * PADDING),
						#main_container.size.y + (2 * PADDING))

func _on_que_change():
	if CombatRootControl.Instance.QueController.execution_state != ActionQueController.ActionStates.Waiting:
		return
	clear_preview_display()
	show_last_qued_target_area()
	if _actor.Que.is_ready():# or CombatRootControl.QueController.SHORTCUT_QUE:
		show_start_button()
	else:
		hide_start_button()

func allow_input(_allow:bool):
	pass

func clear_preview_display():
	if _target_display_key:
		CombatRootControl.Instance.MapController.target_area_display.clear_display(_target_display_key, false)
		_target_display_key = null
		_target_display_action_key = null

func show_preview_target_area(action:PageItemAction):
	if _target_display_action_key == action.ActionKey:
		return
	var target_parms = action.get_preview_target_params(_actor)
	if !target_parms:
		printerr("QueInputControl._mouse_entered_page_button: %s Failed to find preview TargetParams ." % [action.ActionKey])
	else:
		clear_preview_display()
		var preview_pos = _actor.Que.get_movement_preview_pos()
		#if action.PreviewMoveOffset:
			#preview_pos = MoveHandler.relative_pos_to_real(preview_pos, action.PreviewMoveOffset)
		var target_selection_data = TargetSelectionData.new(target_parms, 'Preview', _actor, CombatRootControl.Instance.GameState, [], preview_pos)
		_target_display_action_key = action.ActionKey
		_target_display_key = CombatRootControl.Instance.MapController.target_area_display.build_from_target_selection_data(target_selection_data)

func show_last_qued_target_area():
	# Display last page's target area for mobile
	if _actor and _actor.Que and _actor.Que.real_que and _actor.Que.real_que.size() > 0:
		var last_page:PageItemAction = _actor.Que.real_que[-1]
		if last_page.has_preview_target():
			show_preview_target_area(last_page)

#func _mouse_entered_page_button(_index, key_name):
	#if CombatRootControl.Instance.QueController.execution_state != ActionQueController.ActionStates.Waiting:
		#return
	#var action:PageItemAction = ItemLibrary.get_item(key_name)
	#if action.PreviewMoveOffset:
		#que_display_control.preview_que_path(action.PreviewMoveOffset)
	#if action.has_preview_target():
		#show_preview_target_area(action)
	#if action.CostData.size() > 0:
		#CombatUiControl.Instance.stat_panel_control.preview_stat_cost(action.CostData)
	##ui_controler.mouse_entered_action_button(key_name)
	#pass
#
#func _mouse_exited_action_button(_index, _key_name):
	#clear_preview_display()
	#CombatUiControl.Instance.stat_panel_control.stop_preview_stat_cost()
	#que_display_control.preview_que_path()
	##ui_controler.mouse_exited_action_button(key_name)
	#pass

func _page_button_pressed(_index, key_name):
	if selecetion_mode:
		page_special_selected.emit(key_name)
		hide_page_selection()
		return
	var action:PageItemAction = _actor.pages.get_action_page(key_name)
	var on_que_options = action.get_on_que_options(_actor, CombatRootControl.Instance.GameState)
	if on_que_options.size() > 0:
		CombatUiControl.Instance.ui_state_controller.open_options_menu(_actor, "OnQueOption", on_que_options, action.ActionKey)
		#on_que_options_menu.visible = true
		##on_que_options_menu.position = get_local_mouse_position()# _buttons[index].position + Vector2(_buttons[index].size.x,0)
		#for opt:OnQueOptionsData in on_que_options:
			#on_que_options_menu.set_options(key_name, on_que_options, _on_all_que_options_selected)
	else:
		_actor.Que.que_action(action)

#func _on_all_que_options_selected(action_key:String, options_data:Dictionary):
	#var action:PageItemAction = ItemLibrary.get_item(action_key)
	#_actor.Que.que_action(action, options_data)
	#on_que_options_menu.visible = false

func _start_button_pressed():
	var all_ready = true
	for player:BaseActor in CombatRootControl.list_player_actors():
		if not player.Que.is_ready():
			all_ready = false
	if all_ready:
		CombatUiControl.ui_state_controller.set_ui_state(UiStateController.UiStates.ExecRound)
	else:
		var next_index = CombatRootControl.Instance.get_next_player_index()
		CombatRootControl.Instance.set_player_index(next_index)
	hide_start_button()

func _round_start():
	hide_start_button()
	clear_preview_display()

func _round_ends():
	que_display_patch.show()
	#hide_start_button()
	pass

func _on_ammo_change(page_key):
	if _page_buttons.has(page_key):
		var button:QueInputButtonControl = _page_buttons[page_key]
		button.ammo_display.current_val = _actor.Que.get_page_ammo_current_value(page_key)
	pass

func hide_page_selection():
	for button:QueInputButtonControl in _page_buttons.values():
		button.selection_display.hide()
		button.modulate = Color.WHITE
	selecetion_mode = false

func show_page_selection(action_keys:Array):
	for action_key in _page_buttons.keys():
		var button:QueInputButtonControl = _page_buttons[action_key]
		if action_keys.has(action_key):
			button.selection_display.show()
		else:
			button.selection_display.hide()
			button.modulate = Color.LIGHT_GRAY
	selecetion_mode = true
	page_Selection_container.show()
	que_display_patch.hide()
