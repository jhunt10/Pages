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
			if (action_list.size() == 5 and 
				action_list[0] == "MoveForward" and
				action_list[1] == "TurnRight" and
				action_list[2] == "MoveForward" and
				action_list[3] == "MoveForward" and
				action_list[4] == "MoveForward"):
					next_tag = "FirstInput_Success" 
			else:
					next_tag = "FirstInput_Failed"
			_parent_dialog_control.dialog_box_holder.show()
			finish()
	if tag == "SecondInput_Check":
		var player_que = CombatRootControl.Instance.ui_control.que_input._actor.Que
		if player_que.is_ready():
			var action_list = []
			for action in player_que.list_qued_actions():
				action_list.append(action.ActionKey)
			if (action_list.size() == 5 and 
				action_list[0] == "MoveForward" and
				action_list[1] == "MoveForward" and
				action_list[2] == "MoveForward" and
				action_list[3] == "BasicWeaponAttack" and
				action_list[4] == "BasicWeaponAttack"):
					next_tag = "SecondInput_Success" 
			else:
					next_tag = "SecondInput_Failed"
			_parent_dialog_control.dialog_box_holder.show()
			finish()
	pass

func do_thing():
	if _block_data.keys().has("RemovePages"):
		for page_name in _block_data.get("RemovePages", []):
			var page = ActionLibrary.get_action(page_name)
			if page:
				var actor = CombatRootControl.Instance.ui_control.que_input._actor
				actor.pages.remove_page(page.ActionKey)
				self.finish()
	var tag = _block_data.get("BlockTag", null)
	if !tag:
		self.finish()
		return
	if tag == "Start":
		self.finish()
	elif tag == "End":
		self.finish()
	elif tag == "FirstInput_Check":
		var player_que = CombatRootControl.Instance.ui_control.que_input._actor.Que
		if player_que:
			player_que.clear_que()
		_parent_dialog_control.dialog_box_holder.hide()
	elif tag == "SecondInput_Check":
		var player_que = CombatRootControl.Instance.ui_control.que_input._actor.Que
		if player_que:
			player_que.clear_que()
		_parent_dialog_control.dialog_box_holder.hide()
	elif tag == 'ForceStart':
		_parent_dialog_control.hide()
		CombatRootControl.QueController.end_of_round.connect(on_round_finish)
		CombatUiControl.ui_state_controller.set_ui_state(UiStateController.UiStates.ExecRound)
	elif tag.begins_with("AddPage_"):
		for page_name in _block_data.get("Pages", []):
			var page = ActionLibrary.get_action(page_name)
			if page:
				var actor = CombatRootControl.Instance.ui_control.que_input._actor
				actor.pages.try_add_page(page)
				self.finish()

func on_round_finish():
	var tag = _block_data.get("BlockTag", null)
	if tag == "ForceStart":
		_parent_dialog_control.show()
		finish()
	

func get_next_block_tag():
	return next_tag
