class_name TutorialConditionDialogBlock
extends BaseDialogBlock

var next_tag

func _init(parent, data)->void:
	data['WaitForButton'] = false
	super(parent, data)


func update(delta: float) -> void:
	var tag = _block_data.get("BlockTag", null)
	if tag == "FirstInput_Check":
		var player_que = CombatRootControl.Instance.ui_control.que_input._actor.Que
		if player_que.is_ready():
			var action_list = []
			for action in player_que.list_qued_actions():
				action_list.append(action.ActionKey)
			if (action_list.size() == 4 and 
				action_list[0] == "TurnRight" and
				action_list[1] == "MoveForward" and
				action_list[2] == "MoveForward" and
				action_list[3] == "MoveForward"):
					next_tag = "FirstInput_Success" 
			else:
					next_tag = "FirstInput_Failed"
			_parent_dialog_control.show()
			finish()
	pass

func do_thing():
	var tag = _block_data.get("BlockTag", null)
	if !tag:
		self.finish()
		return
	if tag == "FirstInput_Check":
		var player_que = CombatRootControl.Instance.ui_control.que_input._actor.Que
		if player_que:
			player_que.clear_que()
		_parent_dialog_control.hide()
	elif tag == 'ForceStart':
		_parent_dialog_control.hide()
		CombatRootControl.QueController.end_of_round.connect(on_round_finish)
		CombatUiControl.ui_state_controller.set_ui_state(UiStateController.UiStates.ExecRound)

func on_round_finish():
	var tag = _block_data.get("BlockTag", null)
	if tag == "ForceStart":
		_parent_dialog_control.show()
		finish()
	

func get_next_block_tag():
	return next_tag
