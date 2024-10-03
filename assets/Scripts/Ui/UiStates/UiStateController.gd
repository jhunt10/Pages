#class_name UiStateController_OLD
#
#var current_ui_state_name:String 
#var current_ui_state:BaseUiState
#
#enum UiStates {ActionInput, ExecRound}
#
#var _state_scripts = {
	#UiStates.ActionInput: "res://assets/Scripts/Ui/UiStates/UiState_ActionInput.gd",
	#UiStates.ExecRound: "res://assets/Scripts/Ui/UiStates/UiState_ExecRound.gd"
#}
#
#func update(delta:float):
	#if current_ui_state:
		#current_ui_state.update(delta)
#
#func set_state(state:UiStates):
	#var path = _state_scripts[state]
	#var args = {}
	#set_state_from_path(path, args)
#
#func set_state_from_path(path, args):
	#if current_ui_state:
		#current_ui_state.end_state()
		#current_ui_state = null
	#var script = load(path)
	#current_ui_state = script.new(self)
	#current_ui_state.start_state()
#
#func on_input(event):
	#if current_ui_state:
		#current_ui_state.handle_input(event)
