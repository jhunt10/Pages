extends Node2D

@onready var que_controller:QueControllerNode = $"../QueController"
@onready var background = $NinePatchRect
@onready var start_button = $StartButton
@onready var start_button_text = $StartButton/Label 

const BUTTON_WIDTH = 32
const BUTTON_HIGHT = 32
const BUTTON_BETWEEN_PADDING = 8
const TOPBOT_PADDING = 8
const SIDE_PADDING = 8

var actor:BaseActor
var buttons = []
var button_count = 1

var target_display_key:String

func _ready():
	que_controller.end_of_round.connect(_round_ends)
	start_button.button_down.connect(_start_button_pressed)
	disenable_buttons(false)

func disenable_buttons(enabled:bool):
	for but:TextureButton in buttons:
		but.disabled = !enabled
		if !enabled:
			but.modulate = Color.GRAY
		else:
			but.modulate = Color.WHITE

func set_actor(new_actor:BaseActor):
	actor = new_actor
	var action_list = actor.ActorData['QueData']['ActionList']
	button_count = action_list.size()
	_build_buttons()
		
func _build_buttons():
	# Delete existing buttons
	while buttons.size() > 0:
		buttons[buttons.size()-1].queue_free()
		buttons.remove_at(buttons.size()-1)
	var action_list = actor.ActorData['QueData']['ActionList']
	for i in range(0, action_list.size()):
		var key_name = action_list[i]
		var action = MainRootNode.action_libary.get_action(key_name)
		var new_button:TextureButton = TextureButton.new()
		new_button.position = Vector2(SIDE_PADDING 
			+ (BUTTON_WIDTH + BUTTON_BETWEEN_PADDING) * i
			, TOPBOT_PADDING)
		add_child(new_button)
#			new_button.button_down.connect(_button_pressed.bind(i))
		new_button.visible = true
		new_button.stretch_mode = TextureButton.STRETCH_SCALE
		new_button.size.x = BUTTON_WIDTH
		new_button.size.y = BUTTON_HIGHT
		
		new_button.texture_normal = action.get_large_sprite()
		new_button.button_down.connect(_action_button_pressed.bind(i, key_name))
		new_button.mouse_entered.connect(_mouse_entered_action_button.bind(i, key_name))
		new_button.mouse_exited.connect(_mouse_exited_action_button.bind(i, key_name))
		
		buttons.append(new_button)
			
	start_button.position = Vector2(SIDE_PADDING 
			+ (BUTTON_WIDTH + BUTTON_BETWEEN_PADDING) * action_list.size()
			, TOPBOT_PADDING)
	background.size.x = (SIDE_PADDING + (BUTTON_WIDTH * button_count) 
									+ (BUTTON_BETWEEN_PADDING * (button_count - 1)) 
									+ SIDE_PADDING + SIDE_PADDING
									+ start_button.size.x)
	background.size.y = TOPBOT_PADDING + BUTTON_HIGHT + TOPBOT_PADDING
	#
#
func _action_button_pressed(_index, key_name):
	var action:BaseAction = MainRootNode.action_libary.get_action(key_name)
	if action.OnQueUiState:
		CombatRootControl.Instance.ui_controller.set_ui_state_from_path(
			action.OnQueUiState,
			{
				"Actor": actor,
				"ActionKey": action.ActionKey,
				
			})
	else:
		actor.Que.que_action(action)

func _mouse_entered_action_button(index, key_name):
	if buttons[index].disabled:
		return
		
	var action = MainRootNode.action_libary.get_action(key_name)
	if action.PreviewTargetKey:
		var target_parms = action.TargetParams[action.PreviewTargetKey]
		var preview_pos = actor.Que.get_movement_preview_pos()
		target_display_key = CombatRootControl.Instance.MapController.target_area_display \
			.set_target_parameters(preview_pos, target_parms)
	#ui_controler.mouse_entered_action_button(key_name)
	pass
	
func _mouse_exited_action_button(_index, _key_name):
	CombatRootControl.Instance.MapController.target_area_display.clear_display(target_display_key, false)
	#ui_controler.mouse_exited_action_button(key_name)
	pass
	
func _start_button_pressed():
	CombatRootControl.Instance.ui_controller.set_ui_state(UiStateController.UiStates.ExecRound)
	start_button.disabled = true
	start_button_text.text = " XXX"

func _round_ends():
	start_button.disabled = false
	start_button_text.text = "Start"
