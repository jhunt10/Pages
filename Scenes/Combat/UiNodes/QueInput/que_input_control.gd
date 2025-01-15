@tool
class_name QueInputControl
extends Control

const PADDING = 8

signal page_special_selected(action_key:String)

@export var que_display_control:QueDisplayControl
@export var on_que_options_menu:ItemSelectionInputDisplay
@export var back_patch:BackPatchContainer
@export var main_container:HBoxContainer 
@export var page_button_prefab:QueInputButtonControl
@export var start_label:Label
@export var side_start_button:QueInput_StartButton
@export var top_start_button:QueInput_StartButton

var _actor:BaseActor
var _page_buttons:Dictionary = {} 
var _resize:bool = true
var _target_display_key

# When selecting pages for something other than queing
var selecetion_mode:bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	#super()
	#if Engine.is_editor_hint(): return
	CombatRootControl.QueController.end_of_round.connect(_round_ends)
	side_start_button.button.pressed.connect(_start_button_pressed)
	side_start_button.button.disabled = true
	top_start_button.button.pressed.connect(_start_button_pressed)
	top_start_button.button.disabled = true
	page_button_prefab.visible = false
	on_que_options_menu.visible = false
	pass # Replace with function body.

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
	var que_display_size = que_display_control.size.x
	var self_size = back_patch.size.x #+ (back_patch.sides_padding * 2)
	var use_top = (top_start_button.size.x < self_size - que_display_size)
	printerr("SelfSize: %s | DisSize: %s | UseTop: %s" % [self_size, que_display_size, use_top])
	if use_top:
		top_start_button.button.disabled = false
		top_start_button.state = QueInput_StartButton.States.Growing
	else:
		side_start_button.button.disabled = false
		side_start_button.state = QueInput_StartButton.States.Growing
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var hight = self.size.y
	var box_hight = back_patch.size.y
	var box_scale = hight / box_hight
	back_patch.scale = Vector2(box_scale, box_scale)
	var self_size = self.size
	var box_size = back_patch.size * box_scale
	back_patch.position = Vector2((self_size.x / 2) - (box_size.x / 2), (self_size.y / 2) - (box_size.y / 2))
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
	que_display_control.set_actor(actor)
	

func _build_buttons():
	if _page_buttons.values().size() > 0:
		for but in _page_buttons.values():
			but.queue_free()
		_page_buttons.clear()
	var index = 0
	for action_key in _actor.get_action_key_list():
		if action_key == null:
			continue
		var new_button:QueInputButtonControl = page_button_prefab.duplicate()
		new_button.name = "PageSlot" + str(index)
		page_button_prefab.get_parent().add_child(new_button)
		new_button.visible = true
		var action = ActionLibrary.get_action(action_key)
		new_button.set_page(_actor, action)
		#if action == null:
			#new_button.get_child(0).texture = load(ActionLibrary.NO_ICON_SPRITE)
		#else:
			#new_button.get_child(0).texture = action.get_large_page_icon(_actor)
			#if not MainRootNode.is_mobile:
				#new_button.mouse_entered.connect(_mouse_entered_page_button.bind(index, action_key))
				#new_button.mouse_exited.connect(_mouse_exited_action_button.bind(index, action_key))
		new_button.button.pressed.connect(_page_button_pressed.bind(index, action_key))
		new_button.selection_button.pressed.connect(_on_page_special_selected.bind(action_key))
		
		_page_buttons[action_key] = new_button
		index += 1
	_on_que_change()
	
	#self.size = Vector2i(main_container.size.x + (2 * PADDING),
						#main_container.size.y + (2 * PADDING))

func _on_que_change():
	clear_preview_display()
	if _actor.Que.is_ready():# or CombatRootControl.QueController.SHORTCUT_QUE:
		show_start_button()
	else:
		hide_start_button()

func allow_input(_allow:bool):
	pass

var que_was_displaying_target:bool = false
func clear_preview_display():
	if _target_display_key:
		CombatRootControl.Instance.MapController.target_area_display.clear_display(_target_display_key, false)
		_target_display_key = null
	if que_was_displaying_target:
		que_display_control.show_last_qued_target_area()
		que_was_displaying_target = false

func show_preview_target_area(action:BaseAction):
	if que_display_control._target_display_key:
		que_was_displaying_target = true
		que_display_control.clear_preview()
	else:
		que_was_displaying_target = false
	var target_parms = action.get_preview_target_params(_actor)
	if !target_parms:
		printerr("QueInputControl._mouse_entered_page_button: %s Failed to find preview TargetParams ." % [action.ActionKey])
	else:
		var preview_pos = _actor.Que.get_movement_preview_pos()
		if action.PreviewMoveOffset:
			preview_pos = MoveHandler.relative_pos_to_real(preview_pos, action.PreviewMoveOffset)
		var target_selection_data = TargetSelectionData.new(target_parms, 'Preview', _actor, CombatRootControl.Instance.GameState, [], preview_pos)
		_target_display_key = CombatRootControl.Instance.MapController.target_area_display.build_from_target_selection_data(target_selection_data)

func _mouse_entered_page_button(_index, key_name):
	if CombatRootControl.Instance.QueController.execution_state != ActionQueController.ActionStates.Waiting:
		return
	var action:BaseAction = ActionLibrary.get_action(key_name)
	if action.PreviewMoveOffset:
		que_display_control.preview_que_path(action.PreviewMoveOffset)
	if action.has_preview_target():
		show_preview_target_area(action)
	if action.CostData.size() > 0:
		CombatUiControl.Instance.stat_panel_control.preview_stat_cost(action.CostData)
	#ui_controler.mouse_entered_action_button(key_name)
	pass

func _mouse_exited_action_button(_index, _key_name):
	clear_preview_display()
	CombatUiControl.Instance.stat_panel_control.stop_preview_stat_cost()
	que_display_control.preview_que_path()
	#ui_controler.mouse_exited_action_button(key_name)
	pass

func _page_button_pressed(index, key_name):
	if selecetion_mode:
		return
	var action:BaseAction = ActionLibrary.get_action(key_name)
	var on_que_options = action.get_on_que_options(_actor, CombatRootControl.Instance.GameState)
	if on_que_options.size() > 0:
		on_que_options_menu.visible = true
		#on_que_options_menu.position = get_local_mouse_position()# _buttons[index].position + Vector2(_buttons[index].size.x,0)
		for opt:OnQueOptionsData in on_que_options:
			on_que_options_menu.load_options(key_name, on_que_options, _on_all_que_options_selected)
	else:
		_actor.Que.que_action(action)

func _on_all_que_options_selected(action_key:String, options_data:Dictionary):
	var action:BaseAction = MainRootNode.action_library.get_action(action_key)
	_actor.Que.que_action(action, options_data)
	on_que_options_menu.visible = false

func _start_button_pressed():
	CombatUiControl.ui_state_controller.set_ui_state(UiStateController.UiStates.ExecRound)
	hide_start_button()

func _round_ends():
	hide_start_button()

func _on_ammo_change(page_key):
	if _page_buttons.has(page_key):
		var button:QueInputButtonControl = _page_buttons[page_key]
		button.ammo_display.current_val = _actor.Que.get_page_ammo(page_key)
	pass

func hide_page_selection():
	for button:QueInputButtonControl in _page_buttons.values():
		button.selection_display.hide()
	selecetion_mode = false

func show_page_selection(action_keys:Array):
	for action_key in _page_buttons.keys():
		var button:QueInputButtonControl = _page_buttons[action_key]
		if action_keys.has(action_key):
			button.selection_display.show()
		else:
			button.selection_display.hide()
	selecetion_mode = true

func _on_page_special_selected(action_key):
	if not selecetion_mode:
		return
	page_special_selected.emit(action_key)
	hide_page_selection()
