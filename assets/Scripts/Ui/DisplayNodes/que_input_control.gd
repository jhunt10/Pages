class_name QueInputControl
extends Control

const PADDING = 8

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
	for action_key in actor.ActorData['QueData']['ActionList']:
		var action = MainRootNode.action_libary.get_action(action_key)
		var new_button:TextureButton = page_button_prefab.duplicate()
		page_button_prefab.get_parent().add_child(new_button)
		new_button.get_child(0).texture = action.get_large_sprite()
		new_button.visible = true
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
	var action:BaseAction = MainRootNode.action_libary.get_action(key_name)
	if action.PreviewTargetKey:
		var target_parms = action.TargetParams[action.PreviewTargetKey]
		var preview_pos = _actor.Que.get_movement_preview_pos()
		_target_display_key = CombatRootControl.Instance.MapController.target_area_display \
			.set_target_parameters(preview_pos, target_parms)
	if action.CostData.size() > 0:
		CombatRootControl.Instance.StatDisplay.preview_stat_cost(action.CostData)
	#ui_controler.mouse_entered_action_button(key_name)
	pass
	
func _mouse_exited_action_button(_index, _key_name):
	if _target_display_key:
		CombatRootControl.Instance.MapController.target_area_display.clear_display(_target_display_key, false)
	CombatRootControl.Instance.StatDisplay.stop_preview_stat_cost()
	#ui_controler.mouse_exited_action_button(key_name)
	pass

func _page_button_pressed(_index, key_name):
	var action:BaseAction = MainRootNode.action_libary.get_action(key_name)
	if action.OnQueUiState:
		CombatRootControl.Instance.ui_controller.set_ui_state_from_path(
			action.OnQueUiState,
			{
				"Actor": _actor,
				"ActionKey": action.ActionKey,
				
			})
	else:
		_actor.Que.que_action(action)

func _start_button_pressed():
	CombatRootControl.Instance.ui_controller.set_ui_state(UiStateController.UiStates.ExecRound)
	start_button.disabled = true
	start_button.get_child(0).text = " XXX"

func _round_ends():
	start_button.disabled = false
	start_button.get_child(0).text = "Start"
