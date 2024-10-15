class_name BaseUiState
extends GDScript

var ui_controller:UiStateController
var _logging:bool = false

func _get_debug_name()->String: 
	return "Unset"

func _init(controler:UiStateController, _args:Dictionary) -> void:
	ui_controller = controler

func start_state():
	pass

func update(_delta:float):
	pass

func end_state():
	pass

func handle_input(_event):
	pass
