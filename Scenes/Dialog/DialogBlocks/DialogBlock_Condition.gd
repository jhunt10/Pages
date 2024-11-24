class_name ConditionDialogBlock
extends BaseDialogBlock

var next_tag

func _init(parent, data)->void:
	data['WaitForButton'] = false
	super(parent, data)

func do_thing():
	var answer_condition:Dictionary = _block_data.get("AnswerConsition", {})
	var answer_key = answer_condition.get("AnswerKey")
	var answer_mapping:Dictionary = answer_condition.get("JumpToMapping", {})
	var value = _parent_dialog_control.meta_data.get(answer_key, null)
	if value and answer_mapping.keys().has(value):
		next_tag = answer_mapping[value]
	self._finished = true
	self.finished.emit()

func get_next_block_tag():
	return next_tag
