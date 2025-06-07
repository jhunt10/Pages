class_name UiStateController

enum UiStates {ActionInput, ExecRound, PauseMenu, CharacterSheet, PlaceActors}

var _state_scripts = {
	UiStates.ActionInput: "res://assets/Scripts/Ui/UiStates/UiState_ActionInput.gd",
	UiStates.ExecRound: "res://assets/Scripts/Ui/UiStates/UiState_ExecRound.gd",
	UiStates.PauseMenu: "res://assets/Scripts/Ui/UiStates/UiState_PauseMenu.gd",
	UiStates.CharacterSheet: "res://assets/Scripts/Ui/UiStates/UiState_CharacterSheet.gd",
	UiStates.PlaceActors: "res://assets/Scripts/Ui/UiStates/UiState_PlaceActors.gd"
}

var current_ui_state:BaseUiState
var state_stack:Array = []
var last_state:BaseUiState:
	get:
		if state_stack.size() > 0:
			return state_stack[state_stack.size() -1] 
		return null

func update(delta):
	if current_ui_state:
		current_ui_state.update(delta)
	pass

func handle_input(event:InputEvent):
	if current_ui_state:
		current_ui_state.handle_input(event)

func set_ui_state(state:UiStates, args:Dictionary={}, clear_stack:bool=true):
	print("Setting UI State: %s" %[UiStates.keys()[int(state)]])
	var path = _state_scripts[state]
	set_ui_state_from_path(path, args, clear_stack)

func set_ui_state_from_path(path, args, clear_stack:bool=true):
	if clear_stack:
		state_stack.clear()
	if current_ui_state:
		current_ui_state.end_state()
		state_stack.append(current_ui_state)
		print("Last UiState set to: " + last_state._get_debug_name())
		current_ui_state = null
	var script = load(path)
	current_ui_state = script.new(self, args)
	current_ui_state.start_state()

func back_to_last_state():
	if !last_state:
		printerr("Last UiState Lost")
		state_stack.clear()
		return
	print("Returning to state: " + last_state._get_debug_name())
	if current_ui_state:
		current_ui_state.end_state()
		current_ui_state = null
	current_ui_state = last_state
	state_stack.remove_at(state_stack.size()-1)
	current_ui_state.start_state()

func clear_states():
	state_stack.clear()
	current_ui_state = null
	
func open_options_menu(actor:BaseActor, selecting_key:String, option_sets, queing_action_key:String=''):
	if option_sets is Dictionary:
		option_sets = option_sets.values()
	if not option_sets is Array:
		option_sets = [option_sets]
	var args = {
		"ActorId": actor.Id,
		"SelectionKey": selecting_key,
		"OptionSets": option_sets
	}
	if queing_action_key != '':
		args['ActionKey'] = queing_action_key
	set_ui_state_from_path("res://assets/Scripts/Ui/UiStates/UiState_SelectActionOption.gd", args)
	
