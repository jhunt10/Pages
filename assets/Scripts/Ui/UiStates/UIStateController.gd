class_name UiStateController

enum UiStates {ActionInput, ExecRound, PauseMenu, SelectItem, CharacterSheet}

var _state_scripts = {
	UiStates.ActionInput: "res://assets/Scripts/Ui/UiStates/UiState_ActionInput.gd",
	UiStates.ExecRound: "res://assets/Scripts/Ui/UiStates/UiState_ExecRound.gd",
	UiStates.PauseMenu: "res://assets/Scripts/Ui/UiStates/UiState_PauseMenu.gd",
	UiStates.SelectItem: "res://assets/Scripts/Ui/UiStates/UiState_ItemSelection.gd",
	UiStates.CharacterSheet: "res://assets/Scripts/Ui/UiStates/UiState_CharacterSheet.gd",
}

var current_ui_state:BaseUiState
var last_state:BaseUiState

func update(delta):
	if current_ui_state:
		current_ui_state.update(delta)
	pass

func handle_input(event:InputEvent):
	if current_ui_state:
		current_ui_state.handle_input(event)

func set_ui_state(state:UiStates, args:Dictionary={}):
	#print("Setting UI State: %s" %[state])
	var path = _state_scripts[state]
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
