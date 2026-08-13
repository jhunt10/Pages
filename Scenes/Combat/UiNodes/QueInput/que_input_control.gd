class_name QueInputControl
extends BoxContainer

const PADDING = 8
const MAX_INPUT_BUTTON_WIDTH = 8
enum States {Hidden, Growing, Showing, Shrinking}

signal page_special_selected(action_key:String)
signal page_selection_closed

@export var showing:bool:
	set(val):
		showing = val
		if val:
			self.show()
		else:
			self.hide()

@export var _fill_button:Button

@export var que_display_control:QueInputDisplayControl
@export var page_button_prefab:QueInputButtonControl
@export var start_label:Label
@export var side_start_button:QueInput_StartButton
@export var top_start_button:QueInput_StartButton
@export var slide_speed:float = 100
@export var input_buttons_container:GridContainer

@export var page_selection_container:Container
@export var page_selection_container_cancel_button:Button
@export var page_selection_container_close_button:TextureButton

@export var hover_box:QuePageHoverBox
@export var tab_bar:TabBar

@export var state:States
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
	CombatRootControl.QueController.start_of_round.connect(_round_start)
	CombatRootControl.QueController.end_of_round.connect(_round_ends)
	side_start_button.button.pressed.connect(_start_button_pressed)
	side_start_button.button.disabled = true
	top_start_button.button.pressed.connect(_start_button_pressed)
	top_start_button.button.disabled = true
	page_button_prefab.visible = false
	page_selection_container.hide()
	_fill_button.pressed.connect(_fill_que_with_wait)
	hover_box.hide()
	page_selection_container_cancel_button.pressed.connect(_on_page_selection_cancle_pressed)
	page_selection_container_close_button.pressed.connect(_on_page_selection_cancle_pressed)
	tab_bar.tab_changed.connect(on_tab_selected)
	

func _fill_que_with_wait():
	var wait = ItemLibrary.get_item("Wait")
	if wait and _actor:
		for r in range(_actor.Que.get_max_que_size()):
			_actor.Que.que_action(wait)
			if _actor.Que.is_ready():
				break

func hide_start_button():
	top_start_button.button.disabled = true
	top_start_button.state = QueInput_StartButton.States.Shrinking
	side_start_button.button.disabled = true
	side_start_button.state = QueInput_StartButton.States.Shrinking

func show_start_button():
	if supress_start:
		return
	var all_ready = true
	for player:BaseActor in CombatRootControl.list_player_actors(false):
		if not player.Que.is_ready():
			all_ready = false
	var que_display_size = que_display_control.size.x
	var self_size = self.size.x # back_patch.size.x #+ (back_patch.sides_padding * 2)
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

func set_actor(actor:BaseActor):
	if _actor:
		_actor.page_list_changed.disconnect(_build_buttons)
		_actor.Que.action_que_changed.disconnect(_on_que_change)
		if _actor is CarrierActor: 
			_actor.carried_actors_changed.disconnect(on_carried_actor_change)
	_actor = actor
	_actor.page_list_changed.connect(_build_buttons)
	_actor.Que.action_que_changed.connect(_on_que_change)
	hover_box.hide()
	_build_tab_bar()
	_build_buttons()
	clear_preview_display()
	show_last_qued_target_area()
	que_display_control.set_actor(_actor)

var _filtered_actor_id

func on_tab_selected(tab_index):
	var selected_tab = tab_bar.get_tab_metadata(tab_index)
	_filtered_actor_id = selected_tab
	_build_buttons()

func on_carried_actor_change():
	if _filtered_actor_id:
		if not (_filtered_actor_id == _actor.Id or (_actor as CarrierActor).is_carrying_actor(_filtered_actor_id)):
			_filtered_actor_id = null
	_build_tab_bar()
	_build_buttons()

func _build_tab_bar():
	if _actor is CarrierActor: 
		_actor.carried_actors_changed.connect(on_carried_actor_change)
		if _actor.list_carried_actor_ids().size() > 0:
			tab_bar.clear_tabs()
			tab_bar.add_tab("All")
			tab_bar.set_tab_metadata(0, null)
			tab_bar.add_tab(_actor.get_display_name())
			tab_bar.set_tab_metadata(1, _actor.Id)
			var index = 2
			for sub_actor:BaseActor in _actor.list_carried_actors():
				tab_bar.add_tab(sub_actor.get_display_name())
				tab_bar.set_tab_metadata(index, sub_actor.Id)
				index += 1
		else:
			_filtered_actor_id = null
			tab_bar.hide()
	else:
		_filtered_actor_id = null
		tab_bar.hide()

func _build_buttons():
	if _page_buttons.values().size() > 0:
		for but in _page_buttons.values():
			but.queue_free()
		_page_buttons.clear()
	var index = 0
	var known_keys = []
	for action:PageItemAction in _actor.get_action_list():
		var action_key = action.ItemKey
		var action_id = action.Id
		
		if _filtered_actor_id and action.holding_actor_id != _filtered_actor_id:
			continue 
		
		if known_keys.has(action_key) and not action.is_duplicated_when_merged():
			continue
		known_keys.append(action_key)
			
		var new_button:QueInputButtonControl = page_button_prefab.duplicate()
		new_button.name = "PageSlot" + str(index)
		input_buttons_container.add_child(new_button)
		new_button.visible = true
		new_button.set_page(_actor, action)
		if not MainRootNode.is_mobile:
			new_button.button.mouse_entered.connect(_mouse_entered_page_button.bind(index, action_id))
			new_button.button.mouse_exited.connect(_mouse_exited_page_button.bind(index, action_id))
		new_button.button.pressed.connect(_page_button_pressed.bind(index, action_id))
		
		_page_buttons[action_id] = new_button
		index += 1
	input_buttons_container.columns = min(MAX_INPUT_BUTTON_WIDTH, index)
	_on_que_change()

func _on_que_change():
	var execution_state = CombatRootControl.Instance.QueController.execution_state
	if CombatRootControl.Instance.QueController.execution_state != ActionQueController.ActionStates.Waiting:
		return
	clear_preview_display()
	show_last_qued_target_area()
	resync_ammo_pages()
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
		var target_selection_data = TargetSelectionData.new(target_parms, 'Preview', _actor, CombatRootControl.Instance.GameState, [], preview_pos)
		_target_display_action_key = action.ActionKey
		_target_display_key = CombatRootControl.Instance.MapController.target_area_display.build_from_target_selection_data(target_selection_data)

func show_last_qued_target_area():
	# Display last page's target area for mobile
	if _actor and _actor.Que:
		var last_page:PageItemAction = _actor.Que.get_last_qued_action()
		if last_page and last_page.has_preview_target():
			show_preview_target_area(last_page)

func _mouse_entered_page_button(_index, key_name):
	var action:PageItemAction = _actor.pages.get_action_page(key_name)
	hover_box.set_action(_actor, action)
	hover_box.show()
	pass

func _mouse_exited_page_button(_index, _key_name):
	hover_box.hide()
	pass

func _page_button_pressed(_index, key_name):
	if selecetion_mode:
		page_special_selected.emit(key_name)
		hide_page_selection()
		return
	print("DCX: PageButtonPressed: " + key_name)
	var action:PageItemAction = _actor.get_action_page(key_name)
	var on_que_options = action.get_on_que_options(_actor, CombatRootControl.Instance.GameState)
	if on_que_options and on_que_options.size() > 0:
		CombatUiControl.Instance.ui_state_controller.open_options_menu(_actor, "OnQueOption", on_que_options, action.Id)
	else:
		_actor.Que.que_action(action)

func _start_button_pressed():
	for player_actor:BaseActor in CombatRootControl.list_player_actors(false):
		if not player_actor.Que.is_ready() and CombatRootControl.Instance.is_deployed(player_actor) and not player_actor.is_dead:
			CombatRootControl.Instance.set_current_player_actor(player_actor)
			hide_start_button()
			return
	CombatUiControl.ui_state_controller.set_ui_state(UiStateController.UiStates.ExecRound, {}, true)

func _round_start():
	hide_start_button()
	clear_preview_display()

func _round_ends():
	que_display_control.show()

func resync_ammo_pages():
	for page_id in _page_buttons.keys():
		var button:QueInputButtonControl = _page_buttons[page_id]
		var page:PageItemAction = ItemLibrary.get_item(page_id)
		if page.has_ammo():
			button.ammo_display.current_val = floori(page.get_ammo_current())
	

func _on_ammo_change(page_id):
	if _page_buttons.has(page_id):
		var button:QueInputButtonControl = _page_buttons[page_id]
		var page:PageItemAction = ItemLibrary.get_item(page_id)
		button.ammo_display.current_val = floori(page.get_ammo_current())
	pass

func hide_page_selection():
	for button:QueInputButtonControl in _page_buttons.values():
		button.selection_display.hide()
		button.modulate = Color.WHITE
	selecetion_mode = false
	page_selection_container.hide()

func show_page_selection(action_ids:Array):
	var grey_out_color = Color(0.5,0.5,0.5, 0.7)
	for page_id in _page_buttons.keys():
		var button:QueInputButtonControl = _page_buttons[page_id]
		if action_ids.has(page_id):
			button.selection_display.show()
		else:
			button.selection_display.hide()
			button.modulate = grey_out_color
	selecetion_mode = true
	page_selection_container.show()
	que_display_control.hide()

func _on_page_selection_cancle_pressed():
	hide_page_selection()
	page_selection_closed.emit()
