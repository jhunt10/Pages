class_name QueInputControl
extends Control

const PADDING = 8

@export var que_display_control:QueDisplayControl
@export var on_que_options_menu:OnQueOptionsMenu
@export var main_container:HBoxContainer 
@export var page_button_prefab:TextureButton
@export var start_label:Label
@export var start_button:TextureButton

var _actor:BaseActor
var _buttons = []
var _resize:bool = true
var _target_display_key


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#super()
	#if Engine.is_editor_hint(): return
	CombatRootControl.QueController.end_of_round.connect(_round_ends)
	start_button.pressed.connect(_start_button_pressed)
	start_button.disabled = true
	page_button_prefab.visible = false
	on_que_options_menu.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#super(delta)
	#if Engine.is_editor_hint(): return
	if _resize:
		_resize = false

func set_actor(actor:BaseActor):
	if _actor:
		_actor.pages.items_changed.disconnect(_build_buttons)
		_actor.Que.action_que_changed.disconnect(_on_que_change)
	_actor = actor
	_actor.pages.items_changed.connect(_build_buttons)
	_actor.Que.action_que_changed.connect(_on_que_change)
	_build_buttons()
	

func _build_buttons():
	if _buttons.size() > 0:
		for but in _buttons:
			but.queue_free()
		_buttons.clear()
	var index = 0
	for action_key in _actor.get_action_list():
		if action_key == null:
			continue
		var new_button:TextureButton = page_button_prefab.duplicate()
		new_button.name = "PageSlot" + str(index)
		page_button_prefab.get_parent().add_child(new_button)
		new_button.visible = true
		var action = ActionLibrary.get_action(action_key)
		if action == null:
			new_button.get_child(0).texture = load(ActionLibrary.NO_ICON_SPRITE)
		else:
			new_button.get_child(0).texture = action.get_large_page_icon(_actor)
			if not MainRootNode.is_mobile:
				new_button.mouse_entered.connect(_mouse_entered_page_button.bind(index, action_key))
				new_button.mouse_exited.connect(_mouse_exited_action_button.bind(index, action_key))
			new_button.pressed.connect(_page_button_pressed.bind(index, action_key))
		
		_buttons.append(new_button)
		index += 1
	_on_que_change()
	#self.size = Vector2i(main_container.size.x + (2 * PADDING),
						#main_container.size.y + (2 * PADDING))

func _on_que_change():
	clear_preview_display()
	if _actor.Que.is_ready() or CombatRootControl.QueController.SHORTCUT_QUE:
		start_button.disabled = false
		start_label.text = "Start"
	else:
		start_button.disabled = true
		start_label.text = "Queue"

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
	var action:BaseAction = ActionLibrary.get_action(key_name)
	var on_que_options = action.get_on_que_options(_actor, CombatRootControl.Instance.GameState)
	if on_que_options.size() > 0:
		on_que_options_menu.visible = true
		on_que_options_menu.position = get_local_mouse_position()# _buttons[index].position + Vector2(_buttons[index].size.x,0)
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
	start_button.disabled = true
	start_button.get_child(0).text = "Wait"

func _round_ends():
	start_button.disabled = false
	start_button.get_child(0).text = "Start"
