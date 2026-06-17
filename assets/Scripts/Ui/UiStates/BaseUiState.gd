class_name BaseUiState
extends GDScript

var ui_controller:UiStateController
var _args:Dictionary
var _logging:bool = false

func _get_debug_name()->String: 
	return "Unset"

func _init(controler:UiStateController, args:Dictionary) -> void:
	ui_controller = controler
	self._args = args

func start_state():
	if _logging: print ("Started BaseUiState")
	pass

func update(_delta:float):
	pass

func end_state():
	pass

func handle_input(_event):
	pass

func allow_pause_menu()->bool:
	return true
