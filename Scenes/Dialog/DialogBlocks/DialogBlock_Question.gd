class_name QuestionDialogBlock
extends BaseDialogBlock

var dialog_block_control:QuestionDialogBlockControl

var _wait_for_confrim:bool:
	get: return MainRootNode.is_mobile


func _init(parent, data)->void:
	data['WaitForButton'] = false
	super(parent, data)

func start():
	dialog_block_control = load("res://Scenes/Dialog/DialogBlockControls/question_dialog_block.tscn").instantiate()
	_parent_dialog_control.add_block_container(dialog_block_control)
	dialog_block_control.set_dailog_block(self)
	dialog_block_control.option_selected.connect(on_option_selected)
	dialog_block_control.start()

func update(delta: float) -> void:
	if dialog_block_control._selected_index >= 0 and not _parent_dialog_control.waiting_for_button:
		self.finish()

func try_skip()->bool:
	if !dialog_block_control._done_printing:
		dialog_block_control.print_all()
	return false

func read_any_touch_as_next()->bool:
	return false

func delete():
	dialog_block_control.queue_free()
	pass

func on_option_selected(index:int):
	var choice = self._block_data.get("Options", [])[index]
	var key = self._block_data.get("AnswerKey")
	_parent_dialog_control.meta_data[key] = choice
	if not _wait_for_confrim: 
		self.finish()
	else:
		_parent_dialog_control.show_next_button()
