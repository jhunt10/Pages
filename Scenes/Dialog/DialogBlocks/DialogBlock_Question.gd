class_name QuestionDialogBlock
extends BaseDialogBlock

var dialog_block_control:QuestionDialogBlockControl

func _init(parent, data)->void:
	data['WaitForButton'] = MainRootNode.is_mobile
	super(parent, data)

func start():
	dialog_block_control = load("res://Scenes/Dialog/DialogBlockControls/question_dialog_block.tscn").instantiate()
	_parent_dialog_control.add_block_container(dialog_block_control)
	dialog_block_control.set_dailog_block(self)
	dialog_block_control.option_selected.connect(on_option_selected)
	dialog_block_control.start()
	
func try_skip()->bool:
	if !dialog_block_control._done_printing:
		dialog_block_control.print_all()
	return false
func delete():
	dialog_block_control.queue_free()
	pass

func on_option_selected(index:int):
	print("Selected Choice: %s" % [self._block_data.get("Options", [])[index]])
	self.finish()
