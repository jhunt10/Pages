class_name SpeechDialogBlock
extends BaseDialogBlock

var dialog_block_control:SpeechDialogBlockControl

var waiting:bool = false

func start():
	dialog_block_control = load("res://Scenes/Dialog/DialogBlockControls/speech_dialog_block.tscn").instantiate()
	_parent_dialog_control.add_block_container(dialog_block_control)
	dialog_block_control.set_dailog_block(self)
	dialog_block_control.start()
	

func update(delta: float) -> void:
	if waiting:
		if !_parent_dialog_control.waiting_for_button:
			dialog_block_control.resume()
	if dialog_block_control.is_finished:
		self.finish()
	pass

func try_skip()->bool:
	if dialog_block_control.is_finished:
		return true
	else:
		return dialog_block_control.try_skip()

func delete():
	#printerr("Deleting Speech Block")
	dialog_block_control.queue_free()
	pass

func wait_for_next_button():
	_parent_dialog_control.show_next_button()
	self.waiting = true
