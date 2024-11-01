class_name QueInputControl
extends Control

const PADDING = 8

@export var on_que_options_menu:OnQueOptionsMenu

@onready var main_container:HBoxContainer = $HBoxContainer
@onready var page_button_prefab:TextureButton = $HBoxContainer/HBoxContainer/PageButtonPrefab
@onready var start_button = $HBoxContainer/StartButton

var _actor:BaseActor
var _buttons = []
var _resize:bool = true
var _target_display_key


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CombatRootControl.QueController.end_of_round.connect(_round_ends)
	start_button.pressed.connect(_start_button_pressed)
	page_button_prefab.visible = false
	on_que_options_menu.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if _resize:
		self.size = Vector2i(main_container.size.x + (2 * PADDING),
							main_container.size.y + (2 * PADDING))
		_resize = false

func set_actor(actor:BaseActor):
	_actor = actor
	if _buttons.size() > 0:
		for but in _buttons:
			but.queue_free()
	var index = 0
	for action_key in actor.get_action_list():
		var new_button:TextureButton = page_button_prefab.duplicate()
		page_button_prefab.get_parent().add_child(new_button)
		new_button.visible = true
		
		var action = MainRootNode.action_library.get_action(action_key)
		if action == null:
			new_button.get_child(0).texture = load(ActionLibrary.NO_ICON_SPRITE)
		else:
			new_button.get_child(0).texture = action.get_large_page_icon()
			new_button.mouse_entered.connect(_mouse_entered_page_button.bind(index, action_key))
			new_button.mouse_exited.connect(_mouse_exited_action_button.bind(index, action_key))
			new_button.pressed.connect(_page_button_pressed.bind(index, action_key))
		
		_buttons.append(new_button)
		index += 1
	_resize = true

func allow_input(_allow:bool):
	pass


func _mouse_entered_page_button(_index, key_name):
	if CombatRootControl.Instance.QueController.execution_state != ActionQueController.ActionStates.Waiting:
		return
	var action:BaseAction = MainRootNode.action_library.get_action(key_name)
	if action.PreviewTargetKey:
		var target_parms = TargetingHelper.get_target_params(action.PreviewTargetKey, _actor, action)
		if !target_parms:
			printerr("QueInputControl._mouse_entered_page_button: %s Failed to find TargetParams with key: '%s'." % [action.ActionKey, action.PreviewTargetKey])
		else:
			var preview_pos = _actor.Que.get_movement_preview_pos()
			_target_display_key = CombatRootControl.Instance.MapController.target_area_display \
				.set_target_parameters(preview_pos, target_parms)
	if action.CostData.size() > 0:
		CombatUiControl.Instance.stat_panel_control.preview_stat_cost(action.CostData)
	#ui_controler.mouse_entered_action_button(key_name)
	pass
	
func _mouse_exited_action_button(_index, _key_name):
	if _target_display_key:
		CombatRootControl.Instance.MapController.target_area_display.clear_display(_target_display_key, false)
	CombatUiControl.Instance.stat_panel_control.stop_preview_stat_cost()
	#ui_controler.mouse_exited_action_button(key_name)
	pass

func _page_button_pressed(index, key_name):
	var action:BaseAction = MainRootNode.action_library.get_action(key_name)
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
	start_button.get_child(0).text = " XXX"

func _round_ends():
	start_button.disabled = false
	start_button.get_child(0).text = "Start"
