class_name UiState_ActionInput
extends BaseUiState

func _init(controler:UiStateController, args:Dictionary) -> void:
	super(controler, args)
	pass
	

func start_state():
	print("Start UiState: Action Input")
	CombatRootControl.Instance.ActionInput.disenable_buttons(true)
	pass

func update(_delta:float):
	pass

func end_state():
	CombatRootControl.Instance.ActionInput.disenable_buttons(false)
	pass
