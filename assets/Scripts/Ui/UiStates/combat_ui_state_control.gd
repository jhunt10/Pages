class_name UiStateController
extends Control


@onready var menu_button:TextureButton = $MenuButton
@onready var pause_menu:Control = $PauseMenuControl
@onready var item_select_menu:ItemSelectMenuControl = $ItemSelectMenuControl

enum UiStates {ActionInput, ExecRound, PauseMenu, SelectItem}

var _state_scripts = {
	UiStates.ActionInput: "res://assets/Scripts/Ui/UiStates/UiState_ActionInput.gd",
	UiStates.ExecRound: "res://assets/Scripts/Ui/UiStates/UiState_ExecRound.gd",
	UiStates.PauseMenu: "res://assets/Scripts/Ui/UiStates/UiState_PauseMenu.gd",
	UiStates.SelectItem: "res://assets/Scripts/Ui/UiStates/UiState_ItemSelection.gd",
}

var current_ui_state:BaseUiState
var last_state:BaseUiState

func _ready():
	menu_button.pressed.connect(_on_menu_pressed)
	pass

func _process(delta):
	if current_ui_state:
		current_ui_state.update(delta)
	pass

func set_ui_state(state:UiStates):
	var path = _state_scripts[state]
	var args = {}
	set_ui_state_from_path(path, args)

func set_ui_state_from_path(path, args):
	if current_ui_state:
		current_ui_state.end_state()
		last_state = current_ui_state
		#print("Last UiState set to: " + last_state._get_debug_name())
		current_ui_state = null
	var script = load(path)
	current_ui_state = script.new(self, args)
	current_ui_state.start_state()

func back_to_last_state():
	if !last_state:
		printerr("Last UiState Lost")
		return
	#print("Returning to state: " + last_state._get_debug_name())
	if current_ui_state:
		current_ui_state.end_state()
		current_ui_state = null
	current_ui_state = last_state
	last_state = null
	current_ui_state.start_state()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and (event as InputEventKey).keycode == KEY_ESCAPE and (event as InputEventKey).pressed:
		pause_menu.visible = not pause_menu.visible

func _unhandled_input(event: InputEvent) -> void:
	if current_ui_state:
		current_ui_state.handle_input(event)
		
func _on_menu_pressed():
	set_ui_state(UiStates.PauseMenu)
	pass
