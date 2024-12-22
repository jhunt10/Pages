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
	ActionQueController.SHORTCUT_QUE = false
	CombatRootControl.Instance.ui_control.que_collection_display.hide()
	CombatRootControl.Instance.ui_control.stats_collection_display.hide()
	if _block_data.keys().has("RemoveActions"):
		var actor = CombatRootControl.Instance.ui_control.que_input._actor
		for action_key in _block_data.get("RemoveActions", []):
			var page = actor.pages.get_page_item_for_action_key(action_key)
			if page:
				actor.pages.remove_item(page.Id)
		self.finish()
	if _block_data.keys().has("AddPages"):
		for page_name in _block_data.get("AddPages", []):
			var page = ItemLibrary.create_item(page_name, {})
			if page:
				var actor = CombatRootControl.Instance.ui_control.que_input._actor
				actor.pages.add_item_to_first_valid_slot(page)
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

func on_round_finish():
	var tag = _block_data.get("BlockTag", null)
	if tag == "ForceStart":
		_parent_dialog_control.show()
		finish()
	

func get_next_block_tag():
	return next_tag
